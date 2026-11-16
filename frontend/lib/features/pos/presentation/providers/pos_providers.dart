// Anabhay Ventures — Restaurant Shared State Providers (Riverpod)
// Phase 3: POS Billing, Kitchen KOT, Table Lifecycle, Invoices & Dashboard Synchronization

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/restaurant_storage_repository.dart';
import '../../domain/models/order_models.dart';
import '../../../inventory/domain/models/inventory_models.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
import 'package:restaurant_management/features/settings/presentation/providers/settings_providers.dart';

// ── Repository Provider ─────────────────────────────────────────────────────

final restaurantRepositoryProvider = Provider<RestaurantStorageRepository>((ref) {
  return RestaurantStorageRepository();
});

final restaurantStorageRepositoryProvider = restaurantRepositoryProvider;

// ── Menu Items Provider ─────────────────────────────────────────────────────

final menuItemsProvider = StateNotifierProvider<MenuItemsNotifier, List<MenuItem>>((ref) {
  final repo = ref.watch(restaurantRepositoryProvider);
  return MenuItemsNotifier(repo);
});

class MenuItemsNotifier extends StateNotifier<List<MenuItem>> {
  final RestaurantStorageRepository _repo;

  MenuItemsNotifier(this._repo) : super(RestaurantStorageRepository.getDefaultMenuItems()) {
    _load();
  }

  Future<void> _load() async {
    final items = await _repo.loadMenuItems();
    state = items;
  }

  void addMenuItem(MenuItem item) {
    state = [...state, item];
    _repo.saveMenuItems(state);
  }

  void updateMenuItem(MenuItem updated) {
    state = [
      for (final item in state)
        if (item.id == updated.id) updated else item,
    ];
    _repo.saveMenuItems(state);
  }

  void deleteMenuItem(String id) {
    state = state.where((item) => item.id != id).toList();
    _repo.saveMenuItems(state);
  }

  void toggleAvailability(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isAvailable: !item.isAvailable) else item,
    ];
    _repo.saveMenuItems(state);
  }

  void updatePrice(String id, double newPrice) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(basePrice: newPrice) else item,
    ];
    _repo.saveMenuItems(state);
  }
}

// ── Tables Provider ─────────────────────────────────────────────────────────

final tablesProvider = StateNotifierProvider<TablesNotifier, List<RestaurantTable>>((ref) {
  final repo = ref.watch(restaurantRepositoryProvider);
  return TablesNotifier(repo);
});

class TablesNotifier extends StateNotifier<List<RestaurantTable>> {
  final RestaurantStorageRepository _repo;

  TablesNotifier(this._repo) : super(RestaurantStorageRepository.getDefaultTables()) {
    _load();
  }

  Future<void> _load() async {
    final tables = await _repo.loadTables();
    state = tables;
  }

  void occupyTable(String tableNumber, String orderId, double billAmount) {
    state = [
      for (final table in state)
        if (table.number == tableNumber || table.code == tableNumber)
          table.copyWith(
            status: TableStatus.occupied,
            activeOrderId: orderId,
            currentBill: billAmount,
            occupiedSince: DateTime.now(),
          )
        else
          table,
    ];
    _repo.saveTables(state);
  }

  void updateTableBill(String tableNumber, double additionalAmount) {
    state = [
      for (final table in state)
        if (table.number == tableNumber || table.code == tableNumber)
          table.copyWith(
            currentBill: table.currentBill + additionalAmount,
          )
        else
          table,
    ];
    _repo.saveTables(state);
  }

  void markTableBilled(String tableNumber) {
    state = [
      for (final table in state)
        if (table.number == tableNumber || table.code == tableNumber)
          table.copyWith(status: TableStatus.billed)
        else
          table,
    ];
    _repo.saveTables(state);
  }

  void releaseTable(String tableNumber) {
    state = [
      for (final table in state)
        if (table.number == tableNumber || table.code == tableNumber)
          table.copyWith(
            status: TableStatus.available,
            activeOrderId: null,
            currentBill: 0.0,
            occupiedSince: null,
          )
        else
          table,
    ];
    _repo.saveTables(state);
  }
}

// ── Orders Provider ─────────────────────────────────────────────────────────

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<RestaurantOrder>>((ref) {
  final repo = ref.watch(restaurantRepositoryProvider);
  return OrdersNotifier(repo, ref);
});

class OrdersNotifier extends StateNotifier<List<RestaurantOrder>> {
  final RestaurantStorageRepository _repo;
  final Ref _ref;

  OrdersNotifier(this._repo, this._ref) : super(RestaurantStorageRepository.getDefaultOrders()) {
    _load();
  }

  Future<void> _load() async {
    final orders = await _repo.loadOrders();
    state = orders;
  }

  /// Create a new order and associate with table if Dine-in
  RestaurantOrder createOrder({
    required OrderType orderType,
    required String tableNumber,
    String? customerName,
    String? customerPhone,
    required List<OrderItem> items,
    double discountPercent = 0.0,
    double discountAmount = 0.0,
    String? generalInstructions,
  }) {
    final now = DateTime.now();
    final count = state.length + 101;
    final orderPosConfig = _ref.read(orderPosConfigProvider);
    final taxConfig = _ref.read(taxBillingConfigProvider);

    final orderId = '${orderPosConfig.orderPrefix}2026-$count';
    final kotNumber = '${orderPosConfig.kotPrefix}$count';

    // Calculate financials using dynamic tax configuration
    final subtotal = items.fold(0.0, (sum, i) => sum + i.totalPrice);
    final disc = discountAmount > 0 ? discountAmount : (subtotal * (discountPercent / 100));
    final taxable = (subtotal - disc).clamp(0.0, double.infinity);
    final cgstRate = taxConfig.isGstEnabled ? (taxConfig.taxRatePercent / 200.0) : 0.0;
    final sgstRate = taxConfig.isGstEnabled ? (taxConfig.taxRatePercent / 200.0) : 0.0;
    final cgst = taxable * cgstRate;
    final sgst = taxable * sgstRate;
    final grandTotal = taxable + cgst + sgst;

    final newOrder = RestaurantOrder(
      id: orderId,
      kotNumber: kotNumber,
      orderType: orderType,
      tableNumber: tableNumber,
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      subtotal: subtotal,
      discountPercent: discountPercent,
      discountAmount: disc,
      cgstRate: cgstRate,
      sgstRate: sgstRate,
      cgstAmount: cgst,
      sgstAmount: sgst,
      grandTotal: grandTotal,
      orderStatus: OrderStatus.newOrder,
      paymentStatus: PaymentStatus.pending,
      generalInstructions: generalInstructions,
      hasInventoryDeducted: true,
      createdAt: now,
      updatedAt: now,
    );

    state = [newOrder, ...state];
    _repo.saveOrders(state);

    // Automatic recipe inventory deduction!
    _deductRecipeInventory(newOrder);

    // If dine in, link & occupy table
    if (orderType == OrderType.dineIn) {
      _ref.read(tablesProvider.notifier).occupyTable(tableNumber, orderId, grandTotal);
    }

    return newOrder;
  }

  void _deductRecipeInventory(RestaurantOrder order) {
    final recipes = _ref.read(recipesProvider);
    final ingredientsNotifier = _ref.read(ingredientsProvider.notifier);

    for (final item in order.items) {
      final recipeIndex = recipes.indexWhere((r) => r.menuItemId == item.menuItemId);
      if (recipeIndex >= 0) {
        final recipe = recipes[recipeIndex];
        for (final recIng in recipe.ingredients) {
          double qtyToDeduct = recIng.quantity * item.quantity;
          if (recIng.unit == InventoryUnit.g) {
            qtyToDeduct = qtyToDeduct / 1000.0;
          } else if (recIng.unit == InventoryUnit.ml) {
            qtyToDeduct = qtyToDeduct / 1000.0;
          }

          ingredientsNotifier.adjustStock(
            ingredientId: recIng.ingredientId,
            deltaQuantity: -qtyToDeduct,
            type: StockMovementType.orderDeduction,
            reason: '${item.quantity}× ${item.name} (${order.tableNumber})',
            referenceId: order.id,
          );
        }
      }
    }
  }

  void cancelOrder(String orderId) {
    final orderIndex = state.indexWhere((o) => o.id == orderId);
    if (orderIndex < 0) return;
    final order = state[orderIndex];

    if (order.hasInventoryDeducted) {
      final recipes = _ref.read(recipesProvider);
      final ingredientsNotifier = _ref.read(ingredientsProvider.notifier);

      for (final item in order.items) {
        final recipeIndex = recipes.indexWhere((r) => r.menuItemId == item.menuItemId);
        if (recipeIndex >= 0) {
          final recipe = recipes[recipeIndex];
          for (final recIng in recipe.ingredients) {
            double qtyToAdd = recIng.quantity * item.quantity;
            if (recIng.unit == InventoryUnit.g) {
              qtyToAdd = qtyToAdd / 1000.0;
            } else if (recIng.unit == InventoryUnit.ml) {
              qtyToAdd = qtyToAdd / 1000.0;
            }

            ingredientsNotifier.adjustStock(
              ingredientId: recIng.ingredientId,
              deltaQuantity: qtyToAdd,
              type: StockMovementType.orderReversal,
              reason: 'Reversal: Order ${order.id} cancelled',
              referenceId: order.id,
            );
          }
        }
      }
    }

    state = [
      for (final o in state)
        if (o.id == orderId)
          o.copyWith(
            orderStatus: OrderStatus.cancelled,
            hasInventoryDeducted: false,
            updatedAt: DateTime.now(),
          )
        else
          o,
    ];
    _repo.saveOrders(state);

    if (order.orderType == OrderType.dineIn) {
      _ref.read(tablesProvider.notifier).releaseTable(order.tableNumber);
    }
  }

  /// Update Kitchen Status: newOrder -> preparing -> ready -> served -> completed
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    state = [
      for (final o in state)
        if (o.id == orderId)
          o.copyWith(
            orderStatus: newStatus,
            updatedAt: DateTime.now(),
          )
        else
          o,
    ];
    _repo.saveOrders(state);
  }

  /// Toggle item preparation in KOT
  void toggleItemPrepared(String orderId, String itemId) {
    state = [
      for (final o in state)
        if (o.id == orderId)
          o.copyWith(
            items: [
              for (final item in o.items)
                if (item.id == itemId)
                  item.copyWith(isPrepared: !item.isPrepared)
                else
                  item,
            ],
            updatedAt: DateTime.now(),
          )
        else
          o,
    ];
    _repo.saveOrders(state);
  }

  /// Append more items to an existing active order (Dine-in top-up)
  void appendItemsToOrder(String orderId, List<OrderItem> newItems) {
    state = [
      for (final o in state)
        if (o.id == orderId) ...[
          () {
            final combinedItems = [...o.items, ...newItems];
            final subtotal = combinedItems.fold(0.0, (sum, i) => sum + i.totalPrice);
            final disc = o.discountAmount;
            final taxable = (subtotal - disc).clamp(0.0, double.infinity);
            final cgst = taxable * 0.025;
            final sgst = taxable * 0.025;
            final grandTotal = taxable + cgst + sgst;

            // update table bill
            _ref.read(tablesProvider.notifier).updateTableBill(o.tableNumber, grandTotal - o.grandTotal);

            return o.copyWith(
              items: combinedItems,
              subtotal: subtotal,
              cgstAmount: cgst,
              sgstAmount: sgst,
              grandTotal: grandTotal,
              orderStatus: OrderStatus.newOrder, // notify kitchen of new items!
              updatedAt: DateTime.now(),
            );
          }()
        ] else
          o,
    ];
    _repo.saveOrders(state);
  }

  /// Settle and pay order with demo cash/upi/card
  Invoice settleOrder(String orderId, {required String paymentMethod}) {
    final orderIndex = state.indexWhere((o) => o.id == orderId);
    if (orderIndex < 0) {
      throw Exception('Order $orderId not found');
    }
    final order = state[orderIndex];
    final invoiceConfig = _ref.read(invoiceReceiptConfigProvider);
    final invoiceNumber = '${invoiceConfig.invoicePrefix}${DateTime.now().millisecondsSinceEpoch % 10000}';

    final updatedOrder = order.copyWith(
      paymentStatus: PaymentStatus.paid,
      orderStatus: OrderStatus.completed,
      paymentMethod: paymentMethod,
      invoiceNumber: invoiceNumber,
      updatedAt: DateTime.now(),
    );

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == orderIndex) updatedOrder else state[i],
    ];
    _repo.saveOrders(state);

    // Release table
    if (order.orderType == OrderType.dineIn) {
      _ref.read(tablesProvider.notifier).releaseTable(order.tableNumber);
    }

    // Create and save invoice
    final invoice = Invoice(
      invoiceNumber: invoiceNumber,
      orderId: order.id,
      tableNumber: order.tableNumber,
      orderType: order.orderType,
      items: List.from(order.items),
      subtotal: order.subtotal,
      discountAmount: order.discountAmount,
      cgstAmount: order.cgstAmount,
      sgstAmount: order.sgstAmount,
      grandTotal: order.grandTotal,
      paymentMethod: paymentMethod,
      issuedAt: DateTime.now(),
    );

    _ref.read(invoicesProvider.notifier).addInvoice(invoice);

    // Update Customer CRM & loyalty points if customer phone exists
    if (order.customerPhone != null && order.customerPhone!.isNotEmpty) {
      _ref.read(customersProvider.notifier).addOrUpdateFromOrder(
            name: order.customerName ?? 'Guest Patron',
            phone: order.customerPhone!,
            orderAmount: order.grandTotal,
            orderId: order.id,
          );
    }

    return invoice;
  }

  /// Record payment for an order (e.g. Demo UPI / Demo Cash)
  void recordPayment({required String orderId, required String method, required double amount}) {
    state = [
      for (final o in state)
        if (o.id == orderId)
          o.copyWith(
            paymentStatus: PaymentStatus.paid,
            paymentMethod: method,
            updatedAt: DateTime.now(),
          )
        else
          o,
    ];
    _repo.saveOrders(state);

    final order = state.firstWhere((o) => o.id == orderId, orElse: () => state.first);
    if (order.customerPhone != null && order.customerPhone!.isNotEmpty) {
      _ref.read(customersProvider.notifier).addOrUpdateFromOrder(
            name: order.customerName ?? 'Guest Patron',
            phone: order.customerPhone!,
            orderAmount: amount,
            orderId: order.id,
          );
    }
  }
}

// ── Invoices Provider ───────────────────────────────────────────────────────

final invoicesProvider = StateNotifierProvider<InvoicesNotifier, List<Invoice>>((ref) {
  final repo = ref.watch(restaurantRepositoryProvider);
  return InvoicesNotifier(repo);
});

class InvoicesNotifier extends StateNotifier<List<Invoice>> {
  final RestaurantStorageRepository _repo;

  InvoicesNotifier(this._repo) : super(RestaurantStorageRepository.getDefaultInvoices()) {
    _load();
  }

  Future<void> _load() async {
    final list = await _repo.loadInvoices();
    state = list;
  }

  void addInvoice(Invoice invoice) {
    state = [invoice, ...state];
    _repo.saveInvoices(state);
  }
}

// ── Active POS Cart State & Notifier ────────────────────────────────────────

class PosCartState {
  final OrderType orderType;
  final String selectedTable;
  final String? customerName;
  final String? customerPhone;
  final List<OrderItem> items;
  final double discountPercent;
  final double fixedDiscountAmount;
  final String specialInstructions;
  final String? activeExistingOrderId; // If loaded for an occupied table

  const PosCartState({
    this.orderType = OrderType.dineIn,
    this.selectedTable = 'Table 05',
    this.customerName,
    this.customerPhone,
    this.items = const [],
    this.discountPercent = 0.0,
    this.fixedDiscountAmount = 0.0,
    this.specialInstructions = '',
    this.activeExistingOrderId,
  });

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.totalPrice);

  double get discountAmount {
    if (fixedDiscountAmount > 0) return fixedDiscountAmount;
    if (discountPercent > 0) return subtotal * (discountPercent / 100);
    return 0.0;
  }

  double get taxableAmount => (subtotal - discountAmount).clamp(0.0, double.infinity);
  double get cgst => taxableAmount * 0.025; // 2.5%
  double get sgst => taxableAmount * 0.025; // 2.5%
  double get grandTotal => taxableAmount + cgst + sgst;
  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  PosCartState copyWith({
    OrderType? orderType,
    String? selectedTable,
    String? customerName,
    String? customerPhone,
    List<OrderItem>? items,
    double? discountPercent,
    double? fixedDiscountAmount,
    String? specialInstructions,
    String? activeExistingOrderId,
    bool clearActiveExistingOrderId = false,
  }) {
    return PosCartState(
      orderType: orderType ?? this.orderType,
      selectedTable: selectedTable ?? this.selectedTable,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      discountPercent: discountPercent ?? this.discountPercent,
      fixedDiscountAmount: fixedDiscountAmount ?? this.fixedDiscountAmount,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      activeExistingOrderId: clearActiveExistingOrderId ? null : (activeExistingOrderId ?? this.activeExistingOrderId),
    );
  }
}

final posCartProvider = StateNotifierProvider<PosCartNotifier, PosCartState>((ref) {
  return PosCartNotifier(ref);
});

class PosCartNotifier extends StateNotifier<PosCartState> {
  final Ref _ref;

  PosCartNotifier(this._ref)
      : super(
          const PosCartState(
            selectedTable: 'Table 05', // Default to Table 05 for easy demo flow!
            items: [],
          ),
        );

  void setOrderType(OrderType type) {
    state = state.copyWith(orderType: type);
  }

  void setSelectedTable(String table) {
    // Check if table has an active order
    final tables = _ref.read(tablesProvider);
    final selectedTbl = tables.firstWhere(
      (t) => t.number == table || t.code == table,
      orElse: () => tables.first,
    );

    if (selectedTbl.status == TableStatus.occupied && selectedTbl.activeOrderId != null) {
      // Find order
      final orders = _ref.read(ordersProvider);
      final activeOrder = orders.firstWhere(
        (o) => o.id == selectedTbl.activeOrderId,
        orElse: () => orders.first,
      );
      state = state.copyWith(
        selectedTable: table,
        activeExistingOrderId: activeOrder.id,
        items: List.from(activeOrder.items),
        specialInstructions: activeOrder.generalInstructions ?? '',
      );
    } else {
      state = state.copyWith(
        selectedTable: table,
        clearActiveExistingOrderId: true,
      );
    }
  }

  void setCustomerDetails({String? name, String? phone}) {
    state = state.copyWith(customerName: name, customerPhone: phone);
  }

  void setSpecialInstructions(String notes) {
    state = state.copyWith(specialInstructions: notes);
  }

  void setDiscount({double? percent, double? fixedAmount}) {
    state = state.copyWith(
      discountPercent: percent ?? state.discountPercent,
      fixedDiscountAmount: fixedAmount ?? state.fixedDiscountAmount,
    );
  }

  void addItem(
    MenuItem menuItem, {
    String? variantName,
    double additionalVariantPrice = 0.0,
    List<String> addOns = const [],
    double addOnsTotal = 0.0,
    String? specialInstruction,
  }) {
    final effectivePrice = menuItem.basePrice + additionalVariantPrice;
    final existingIndex = state.items.indexWhere(
      (item) =>
          item.menuItemId == menuItem.id &&
          item.variantName == variantName &&
          item.selectedAddOns.length == addOns.length &&
          item.selectedAddOns.every(addOns.contains),
    );

    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final updated = existing.copyWith(quantity: existing.quantity + 1);
      final newItems = List<OrderItem>.from(state.items);
      newItems[existingIndex] = updated;
      state = state.copyWith(items: newItems);
    } else {
      final newItem = OrderItem(
        id: 'item_${DateTime.now().millisecondsSinceEpoch}_${state.items.length}',
        menuItemId: menuItem.id,
        name: menuItem.name,
        unitPrice: effectivePrice,
        quantity: 1,
        isVeg: menuItem.isVeg,
        variantName: variantName,
        selectedAddOns: addOns,
        addOnsTotal: addOnsTotal,
        specialInstruction: specialInstruction,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void incrementItem(String itemId) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == itemId) item.copyWith(quantity: item.quantity + 1) else item,
      ],
    );
  }

  void decrementItem(String itemId) {
    final existing = state.items.firstWhere((i) => i.id == itemId);
    if (existing.quantity > 1) {
      state = state.copyWith(
        items: [
          for (final item in state.items)
            if (item.id == itemId) item.copyWith(quantity: item.quantity - 1) else item,
        ],
      );
    } else {
      removeItem(itemId);
    }
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != itemId).toList(),
    );
  }

  void clearCart() {
    state = state.copyWith(
      items: [],
      specialInstructions: '',
      discountPercent: 0.0,
      fixedDiscountAmount: 0.0,
      clearActiveExistingOrderId: true,
    );
  }

  /// Submit order to Kitchen
  RestaurantOrder placeOrder() {
    if (state.items.isEmpty) {
      throw Exception('Cart is empty');
    }

    // If adding more items to an existing active order
    if (state.activeExistingOrderId != null) {
      _ref.read(ordersProvider.notifier).appendItemsToOrder(
            state.activeExistingOrderId!,
            state.items,
          );
      final updated = _ref.read(ordersProvider).firstWhere((o) => o.id == state.activeExistingOrderId);
      clearCart();
      return updated;
    }

    final order = _ref.read(ordersProvider.notifier).createOrder(
          orderType: state.orderType,
          tableNumber: state.selectedTable,
          customerName: state.customerName,
          customerPhone: state.customerPhone,
          items: state.items,
          discountPercent: state.discountPercent,
          discountAmount: state.discountAmount,
          generalInstructions: state.specialInstructions.isEmpty ? null : state.specialInstructions,
        );

    clearCart();
    return order;
  }
}

// ── Live Dashboard Reactive Metrics Provider ────────────────────────────────

class DashboardMetrics {
  final double todaySales;
  final int totalOrders;
  final int activeTablesCount;
  final int kitchenQueueCount;
  final int lowStockAlertCount;
  final List<RestaurantOrder> activeKitchenTickets;
  final List<Invoice> recentTransactions;

  const DashboardMetrics({
    required this.todaySales,
    required this.totalOrders,
    required this.activeTablesCount,
    required this.kitchenQueueCount,
    required this.lowStockAlertCount,
    required this.activeKitchenTickets,
    required this.recentTransactions,
  });
}

final dashboardMetricsProvider = Provider<DashboardMetrics>((ref) {
  final orders = ref.watch(ordersProvider);
  final tables = ref.watch(tablesProvider);
  final invoices = ref.watch(invoicesProvider);
  final ingredients = ref.watch(ingredientsProvider);

  // Today sales from all paid invoices (base demo ₹1,48,250 + live new invoices)
  const baseSales = 148250.0;
  final liveInvoicesTotal = invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
  final todaySales = baseSales + liveInvoicesTotal;

  // Total orders (base demo 342 + live orders)
  final totalOrders = 342 + orders.length;

  // Active tables (Occupied or Billed)
  final activeTablesCount = tables.where((t) => t.status == TableStatus.occupied || t.status == TableStatus.billed).length;

  // Kitchen queue: orders in newOrder or preparing state
  final activeKitchenTickets = orders.where((o) => o.orderStatus == OrderStatus.newOrder || o.orderStatus == OrderStatus.preparing).toList();

  // Low stock alert count
  final lowStockAlertCount = ingredients.where((i) => i.isLowStock || i.isOutOfStock).length;

  return DashboardMetrics(
    todaySales: todaySales,
    totalOrders: totalOrders,
    activeTablesCount: activeTablesCount,
    kitchenQueueCount: activeKitchenTickets.length,
    lowStockAlertCount: lowStockAlertCount,
    activeKitchenTickets: activeKitchenTickets,
    recentTransactions: invoices,
  );
});
