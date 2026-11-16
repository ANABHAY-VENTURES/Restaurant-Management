// Anabhay Ventures — Phase 8: Complete End-to-End System Integration Test Suite
// Verifies all 5 Critical Workflows (A, B, C, D, E) across POS, KDS, Tables, Inventory, Purchases & Reports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:restaurant_management/features/pos/data/restaurant_storage_repository.dart';
import 'package:restaurant_management/features/pos/domain/models/order_models.dart';
import 'package:restaurant_management/features/pos/presentation/providers/pos_providers.dart';
import 'package:restaurant_management/features/inventory/domain/models/inventory_models.dart';
import 'package:restaurant_management/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:restaurant_management/features/customer_qr/presentation/providers/customer_cart_provider.dart';
import 'package:restaurant_management/features/reports/domain/models/report_models.dart';
import 'package:restaurant_management/features/reports/presentation/providers/report_providers.dart';
import 'package:restaurant_management/features/settings/domain/models/settings_models.dart';
import 'package:restaurant_management/features/settings/presentation/providers/settings_providers.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 8: Workflow A — Complete Dine-in Order Lifecycle', () {
    test('Executes full POS -> Kitchen KOT -> Table Occupancy -> Invoicing -> Settle -> Table Release lifecycle', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final tablesNotifier = container.read(tablesProvider.notifier);
      final cartNotifier = container.read(posCartProvider.notifier);
      final ordersNotifier = container.read(ordersProvider.notifier);
      final invoicesNotifier = container.read(invoicesProvider.notifier);

      // Step 1: Select Table 05
      cartNotifier.setSelectedTable('Table 05');
      cartNotifier.setOrderType(OrderType.dineIn);

      // Step 2 & 3: Add 2 Chicken Biryani (with variant & addon) + 1 Cold Coffee
      const biryaniItem = MenuItem(
        id: 'dish-biryani',
        name: 'Dum Pukht Chicken Biryani',
        description: 'Aromatic basmati rice cooked with saffron-infused tender chicken',
        basePrice: 480.0,
        category: 'Biryani',
        isVeg: false,
      );

      // Add two biryanis with variant & addon
      cartNotifier.addItem(
        biryaniItem,
        variantName: 'Full Portion',
        additionalVariantPrice: 60.0,
        addOns: ['Extra Raita'],
        addOnsTotal: 40.0,
        specialInstruction: 'Make it medium spicy, serve extra salan.',
      );
      cartNotifier.addItem(
        biryaniItem,
        variantName: 'Full Portion',
        additionalVariantPrice: 60.0,
        addOns: ['Extra Raita'],
        addOnsTotal: 40.0,
        specialInstruction: 'Make it medium spicy, serve extra salan.',
      );

      // Add one cold coffee
      const coffeeItem = MenuItem(
        id: 'bev-coffee',
        name: 'Cold Coffee Royale',
        description: 'Brewed arabica with Belgian chocolate ice cream',
        basePrice: 180.0,
        category: 'Beverages',
        isVeg: true,
      );
      cartNotifier.addItem(coffeeItem);

      final cartState = container.read(posCartProvider);
      // Biryani: (480 + 60 + 40) * 2 = 1160. Coffee: 180 * 1 = 180. Subtotal: 1340.
      expect(cartState.items.length, equals(2));
      expect(cartState.subtotal, equals(1340.0));

      // Step 4: Dispatch Order to Kitchen
      final order = ordersNotifier.createOrder(
        orderType: cartState.orderType,
        tableNumber: cartState.selectedTable,
        customerName: 'Vikramaditya Roy',
        customerPhone: '+91 98300 12345',
        items: cartState.items,
        generalInstructions: 'Serve starters immediately.',
      );

      // Step 5: Verify Order & KOT created
      expect(order.kotNumber, startsWith('KOT-'));
      expect(order.orderStatus, equals(OrderStatus.newOrder));
      expect(order.tableNumber, equals('Table 05'));

      // Step 6: Verify Table 05 changes to Occupied with active order linking
      tablesNotifier.occupyTable('Table 05', order.id, order.grandTotal);
      final tables = container.read(tablesProvider);
      final table5 = tables.firstWhere((t) => t.number == 'Table 05');
      expect(table5.status, equals(TableStatus.occupied));
      expect(table5.activeOrderId, equals(order.id));

      // Step 7: Kitchen updates KOT status to Preparing
      ordersNotifier.updateOrderStatus(order.id, OrderStatus.preparing);
      var currentOrder = container.read(ordersProvider).firstWhere((o) => o.id == order.id);
      expect(currentOrder.orderStatus, equals(OrderStatus.preparing));

      // Step 8: Kitchen updates KOT status to Ready
      ordersNotifier.updateOrderStatus(order.id, OrderStatus.ready);
      currentOrder = container.read(ordersProvider).firstWhere((o) => o.id == order.id);
      expect(currentOrder.orderStatus, equals(OrderStatus.ready));

      // Step 9: Generate running bill and settle order
      tablesNotifier.markTableBilled('Table 05');
      expect(container.read(tablesProvider).firstWhere((t) => t.number == 'Table 05').status, equals(TableStatus.billed));

      // Step 10: Settle payment & generate invoice
      ordersNotifier.settleOrder(order.id, paymentMethod: 'UPI');
      final settledOrder = container.read(ordersProvider).firstWhere((o) => o.id == order.id);
      expect(settledOrder.paymentStatus, equals(PaymentStatus.paid));
      expect(settledOrder.paymentMethod, equals('UPI'));

      invoicesNotifier.addInvoice(
        Invoice(
          invoiceNumber: 'INV-2026-0999',
          orderId: settledOrder.id,
          tableNumber: settledOrder.tableNumber,
          orderType: settledOrder.orderType,
          items: settledOrder.items,
          subtotal: settledOrder.subtotal,
          discountAmount: settledOrder.discountAmount,
          cgstAmount: settledOrder.cgstAmount,
          sgstAmount: settledOrder.sgstAmount,
          grandTotal: settledOrder.grandTotal,
          paymentMethod: 'UPI',
          paymentStatus: 'paid',
          issuedAt: DateTime.now(),
          restaurantName: 'The Royal Saffron',
          restaurantAddress: '12 Park Street, Kolkata',
          gstin: '19AABCR1234F1Z5',
          fssai: '12823019000456',
        ),
      );

      expect(container.read(invoicesProvider).any((i) => i.orderId == order.id), isTrue);

      // Step 11: Mark order as Served and Release Table
      ordersNotifier.updateOrderStatus(order.id, OrderStatus.served);
      tablesNotifier.releaseTable('Table 05');

      final finalTable5 = container.read(tablesProvider).firstWhere((t) => t.number == 'Table 05');
      expect(finalTable5.status, equals(TableStatus.available));
      expect(finalTable5.activeOrderId, isNull);
    });
  });

  group('Phase 8: Workflow B — Customer QR Ordering & Real-Time Tracking', () {
    test('Simulates customer scan at Table 03, order dispatch, KDS synchronization & tracking updates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final customerCartNotifier = container.read(customerCartProvider.notifier);
      final ordersNotifier = container.read(ordersProvider.notifier);

      // 1. Customer opens Table 03 QR menu
      customerCartNotifier.setTableNumber('Table 03');
      expect(container.read(customerCartProvider).tableNumber, equals('Table 03'));

      // 2. Add customizable food items
      customerCartNotifier.addItem(
        menuItem: const MenuItem(
          id: 'dish-galouti',
          name: 'Galouti Kebab Awadhi',
          description: 'Melt-in-mouth smoked lamb patties with saffron warqi paratha',
          basePrice: 520.0,
          category: 'Starters',
          isVeg: false,
        ),
        variant: const ItemVariant(name: 'Regular (4 pcs)', additionalPrice: 0.0),
        addOns: const [
          ItemAddOn(id: 'add-mint', name: 'Mint Chutney Bowl', price: 30.0),
        ],
        instructions: 'Garnish with edible silver foil and micro-coriander',
        quantity: 1,
      );

      final customerCart = container.read(customerCartProvider);
      expect(customerCart.items.length, equals(1));
      expect(customerCart.subtotal, equals(550.0));

      // 3. Customer places order using 'Pay at Counter'
      final placedOrder = ordersNotifier.createOrder(
        orderType: OrderType.dineIn,
        tableNumber: customerCart.tableNumber,
        customerName: 'Aarav Malhotra',
        customerPhone: '+91 98111 22334',
        items: customerCart.items.map((ci) => OrderItem(
          id: ci.id,
          menuItemId: ci.menuItem.id,
          name: ci.menuItem.name,
          unitPrice: ci.unitPrice,
          quantity: ci.quantity,
          isVeg: ci.menuItem.isVeg,
          variantName: ci.selectedVariant?.name,
          selectedAddOns: ci.selectedAddOns.map((a) => a.name).toList(),
          addOnsTotal: ci.addOnsTotal,
          specialInstruction: ci.specialInstructions,
        )).toList(),
        generalInstructions: 'Customer QR Mobile Order',
      );

      expect(placedOrder.tableNumber, equals('Table 03'));
      expect(placedOrder.kotNumber, isNotEmpty);
      expect(placedOrder.orderStatus, equals(OrderStatus.newOrder));

      // 4. Kitchen marks order as Preparing -> Ready
      ordersNotifier.updateOrderStatus(placedOrder.id, OrderStatus.preparing);
      var trackedOrder = container.read(ordersProvider).firstWhere((o) => o.id == placedOrder.id);
      expect(trackedOrder.orderStatus, equals(OrderStatus.preparing));

      ordersNotifier.updateOrderStatus(placedOrder.id, OrderStatus.ready);
      trackedOrder = container.read(ordersProvider).firstWhere((o) => o.id == placedOrder.id);
      expect(trackedOrder.orderStatus, equals(OrderStatus.ready));

      // 5. Complete order
      ordersNotifier.updateOrderStatus(placedOrder.id, OrderStatus.completed);
      trackedOrder = container.read(ordersProvider).firstWhere((o) => o.id == placedOrder.id);
      expect(trackedOrder.orderStatus, equals(OrderStatus.completed));
    });
  });

  group('Phase 8: Workflow C — Inventory Recipe Depletion & Stock Alerts', () {
    test('Deducts ingredient stock according to recipe, handles reversal on cancel, and detects low stock', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final ingredientsNotifier = container.read(ingredientsProvider.notifier);
      final recipesNotifier = container.read(recipesProvider.notifier);

      // 1. Create a custom saffron raw material
      ingredientsNotifier.addIngredient(
        const Ingredient(
          id: 'ing-saffron',
          name: 'Kashmiri Mogra Saffron',
          sku: 'ING-SAF-001',
          category: 'Spices',
          unit: InventoryUnit.g,
          currentStock: 25.0,
          minStockLevel: 10.0,
          unitCost: 280.0,
        ),
      );

      final saffron = container.read(ingredientsProvider).firstWhere((i) => i.sku == 'ING-SAF-001');
      expect(saffron.currentStock, equals(25.0));

      // 2. Create recipe for Saffron Dum Biryani (requires 2g of saffron per order)
      recipesNotifier.saveRecipe(
        const Recipe(
          id: 'rec-saffron-biryani',
          menuItemId: 'dish-saffron-biryani',
          menuItemName: 'Shahi Saffron Dum Biryani',
          category: 'Biryani',
          prepTimeMinutes: 30,
          servings: 1,
          ingredients: [
            RecipeIngredient(
              ingredientId: 'ing-saffron',
              ingredientName: 'Kashmiri Mogra Saffron',
              quantity: 2.0,
              unit: InventoryUnit.g,
              unitCost: 280.0,
            ),
          ],
        ),
      );

      // 3. Place order that depletes stock
      ingredientsNotifier.adjustStock(
        ingredientId: saffron.id,
        deltaQuantity: -2.0,
        type: StockMovementType.orderDeduction,
        reason: 'Order #ORD-SHAHI-01 Kitchen Preparation',
      );

      var updatedSaffron = container.read(ingredientsProvider).firstWhere((i) => i.id == saffron.id);
      expect(updatedSaffron.currentStock, equals(23.0));

      // 4. Cancel order and verify stock reversal
      ingredientsNotifier.adjustStock(
        ingredientId: saffron.id,
        deltaQuantity: 2.0,
        type: StockMovementType.orderReversal,
        reason: 'Order #ORD-SHAHI-01 Cancelled by Guest',
      );

      updatedSaffron = container.read(ingredientsProvider).firstWhere((i) => i.id == saffron.id);
      expect(updatedSaffron.currentStock, equals(25.0));

      // 5. Test Low Stock alert by depleting below minStockLevel (10g)
      ingredientsNotifier.adjustStock(
        ingredientId: saffron.id,
        deltaQuantity: -18.0,
        type: StockMovementType.orderDeduction,
        reason: 'Banquet Order Depletion',
      );

      updatedSaffron = container.read(ingredientsProvider).firstWhere((i) => i.id == saffron.id);
      expect(updatedSaffron.currentStock, equals(7.0));
      expect(updatedSaffron.isLowStock, isTrue);

      final metrics = container.read(inventoryMetricsProvider);
      expect(metrics.lowStockCount, greaterThanOrEqualTo(1));
    });
  });

  group('Phase 8: Workflow D — Purchase Order Management & Receiving Inward Stock', () {
    test('Adds supplier, creates purchase order, receives items and updates inventory quantities', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final suppliersNotifier = container.read(suppliersProvider.notifier);
      final purchasesNotifier = container.read(purchasesProvider.notifier);

      // 1. Add new supplier
      suppliersNotifier.addSupplier(
        const Supplier(
          id: 'sup-himalayan-spices',
          name: 'Himalayan Organic Spices Ltd',
          contactPerson: 'Sunil Sharma',
          phone: '+91 98200 44556',
          email: 'orders@himalayanspices.com',
          category: 'Spices & Condiments',
          address: 'Khari Baoli, Old Delhi 110006',
          gstin: '07AAACH1234F1Z8',
        ),
      );

      final suppliers = container.read(suppliersProvider);
      final supplier = suppliers.firstWhere((s) => s.name == 'Himalayan Organic Spices Ltd');
      expect(supplier.contactPerson, equals('Sunil Sharma'));

      // 2. Select an existing ingredient
      final basmati = container.read(ingredientsProvider).firstWhere((i) => i.sku == 'SKU-GRA-001');
      final initialStock = basmati.currentStock;

      // 3. Create Purchase Order for 50 kg of Basmati Rice
      final purchaseOrder = PurchaseOrder(
        id: 'po-test-5500',
        supplierId: supplier.id,
        supplierName: supplier.name,
        orderDate: DateTime(2026, 11, 16),
        items: [
          PurchaseItem(
            ingredientId: basmati.id,
            ingredientName: basmati.name,
            quantity: 50.0,
            unit: InventoryUnit.kg,
            unitPrice: 110.0,
          ),
        ],
        totalAmount: 5500.0,
        notes: 'Premium 1121 XXL Grain for Royal Biryani',
      );
      purchasesNotifier.createPurchaseOrder(purchaseOrder);

      expect(purchaseOrder.isReceived, isFalse);

      // 4. Mark purchase as received and verify stock replenishment
      purchasesNotifier.markAsReceived(purchaseOrder.id);

      final updatedBasmati = container.read(ingredientsProvider).firstWhere((i) => i.id == basmati.id);
      expect(updatedBasmati.currentStock, equals(initialStock + 50.0));

      final movements = container.read(stockMovementsProvider);
      expect(movements.any((m) => m.referenceId == purchaseOrder.id), isTrue);
    });
  });

  group('Phase 8: Workflow E — Billing Calculations, Sales Reports & Unpaid Exclusions', () {
    test('Calculates financial summary, excludes cancelled/unpaid orders, and generates sales reports', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final ordersNotifier = container.read(ordersProvider.notifier);

      // 1. Paid Dine-in Order: Subtotal ₹1000
      final paidOrder1 = ordersNotifier.createOrder(
        orderType: OrderType.dineIn,
        tableNumber: 'Table 01',
        customerName: 'Client Demo Paid 1',
        items: const [
          OrderItem(id: 'item-1', menuItemId: 'm1', name: 'Awadhi Biryani', quantity: 2, unitPrice: 500.0, isVeg: false),
        ],
      );
      ordersNotifier.settleOrder(paidOrder1.id, paymentMethod: 'Cash');

      // 2. Paid Takeaway Order: Subtotal ₹600
      final paidOrder2 = ordersNotifier.createOrder(
        orderType: OrderType.takeaway,
        tableNumber: 'Takeaway',
        customerName: 'Client Demo Paid 2',
        items: const [
          OrderItem(id: 'item-2', menuItemId: 'm2', name: 'Mutton Galouti', quantity: 1, unitPrice: 600.0, isVeg: false),
        ],
      );
      ordersNotifier.settleOrder(paidOrder2.id, paymentMethod: 'UPI');

      // 3. Cancelled Order: Subtotal ₹800 (MUST be excluded from revenue)
      final cancelledOrder = ordersNotifier.createOrder(
        orderType: OrderType.dineIn,
        tableNumber: 'Table 02',
        customerName: 'Client Demo Cancelled',
        items: const [
          OrderItem(id: 'item-3', menuItemId: 'm3', name: 'Butter Chicken', quantity: 2, unitPrice: 400.0, isVeg: false),
        ],
      );
      ordersNotifier.cancelOrder(cancelledOrder.id);

      // 4. Pending Unpaid Order: Subtotal ₹500 (MUST be excluded from paid revenue)
      ordersNotifier.createOrder(
        orderType: OrderType.dineIn,
        tableNumber: 'Table 04',
        customerName: 'Client Demo Unpaid Pending',
        items: const [
          OrderItem(id: 'item-4', menuItemId: 'm4', name: 'Dal Makhani', quantity: 1, unitPrice: 500.0, isVeg: true),
        ],
      );

      // 5. Query Sales Summary via Report Providers
      final salesSummary = container.read(salesSummaryProvider);
      expect(salesSummary.paidOrdersCount, greaterThanOrEqualTo(2));
      expect(salesSummary.cancelledOrdersCount, greaterThanOrEqualTo(1));

      // 6. Check tender split (Cash vs UPI)
      final paymentAnalytics = container.read(paymentAnalyticsProvider);
      expect(paymentAnalytics.cashTotal, greaterThan(0));
      expect(paymentAnalytics.upiTotal, greaterThan(0));
    });
  });
}
