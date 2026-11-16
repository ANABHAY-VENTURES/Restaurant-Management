// Anabhay Ventures — Customer Mobile Cart State Provider
// Preserves customer cart selections, variants, add-ons, special notes, and calculates tax breakdown

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pos/domain/models/order_models.dart';

class CustomerCartItem {
  final String id;
  final MenuItem menuItem;
  final ItemVariant? selectedVariant;
  final List<ItemAddOn> selectedAddOns;
  final String specialInstructions;
  final int quantity;

  const CustomerCartItem({
    required this.id,
    required this.menuItem,
    this.selectedVariant,
    this.selectedAddOns = const [],
    this.specialInstructions = '',
    this.quantity = 1,
  });

  double get unitPrice => menuItem.basePrice + (selectedVariant?.additionalPrice ?? 0.0);

  double get addOnsTotal => selectedAddOns.fold(0.0, (sum, a) => sum + a.price);

  double get totalPrice => (unitPrice + addOnsTotal) * quantity;

  CustomerCartItem copyWith({
    String? id,
    MenuItem? menuItem,
    ItemVariant? selectedVariant,
    List<ItemAddOn>? selectedAddOns,
    String? specialInstructions,
    int? quantity,
  }) {
    return CustomerCartItem(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedAddOns: selectedAddOns ?? this.selectedAddOns,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CustomerCartState {
  final String tableNumber;
  final OrderType orderType;
  final List<CustomerCartItem> items;
  final String customerName;
  final String customerPhone;
  final String paymentMethod; // 'Pay at Counter', 'Demo UPI'
  final double taxRatePercent;
  final bool isGstEnabled;

  const CustomerCartState({
    this.tableNumber = 'Table 05',
    this.orderType = OrderType.dineIn,
    this.items = const [],
    this.customerName = '',
    this.customerPhone = '',
    this.paymentMethod = 'Pay at Counter',
    this.taxRatePercent = 5.0,
    this.isGstEnabled = true,
  });

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.totalPrice);

  double get cgstAmount => isGstEnabled ? (subtotal * (taxRatePercent / 200.0)) : 0.0;
  double get sgstAmount => isGstEnabled ? (subtotal * (taxRatePercent / 200.0)) : 0.0;

  double get grandTotal => subtotal + cgstAmount + sgstAmount;

  CustomerCartState copyWith({
    String? tableNumber,
    OrderType? orderType,
    List<CustomerCartItem>? items,
    String? customerName,
    String? customerPhone,
    String? paymentMethod,
    double? taxRatePercent,
    bool? isGstEnabled,
  }) {
    return CustomerCartState(
      tableNumber: tableNumber ?? this.tableNumber,
      orderType: orderType ?? this.orderType,
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      taxRatePercent: taxRatePercent ?? this.taxRatePercent,
      isGstEnabled: isGstEnabled ?? this.isGstEnabled,
    );
  }
}

class CustomerCartNotifier extends StateNotifier<CustomerCartState> {
  CustomerCartNotifier() : super(const CustomerCartState());

  void setTableNumber(String table) {
    state = state.copyWith(tableNumber: table);
  }

  void setOrderType(OrderType type) {
    state = state.copyWith(orderType: type);
  }

  void setCustomerInfo({String? name, String? phone}) {
    state = state.copyWith(
      customerName: name ?? state.customerName,
      customerPhone: phone ?? state.customerPhone,
    );
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setTaxConfig({required double taxRatePercent, required bool isGstEnabled}) {
    state = state.copyWith(taxRatePercent: taxRatePercent, isGstEnabled: isGstEnabled);
  }

  void addItem({
    required MenuItem menuItem,
    ItemVariant? variant,
    List<ItemAddOn>? addOns,
    String instructions = '',
    int quantity = 1,
  }) {
    final effectiveVariant = variant ?? (menuItem.variants.isNotEmpty ? menuItem.variants.first : null);
    final effectiveAddOns = addOns ?? [];

    // Check if an identical item configuration already exists in cart
    final existingIndex = state.items.indexWhere((i) {
      if (i.menuItem.id != menuItem.id) return false;
      if (i.selectedVariant?.name != effectiveVariant?.name) return false;
      if (i.specialInstructions != instructions) return false;
      if (i.selectedAddOns.length != effectiveAddOns.length) return false;
      final set1 = i.selectedAddOns.map((a) => a.id).toSet();
      final set2 = effectiveAddOns.map((a) => a.id).toSet();
      return set1.containsAll(set2);
    });

    if (existingIndex >= 0) {
      final updated = List<CustomerCartItem>.from(state.items);
      updated[existingIndex] = updated[existingIndex].copyWith(
        quantity: updated[existingIndex].quantity + quantity,
      );
      state = state.copyWith(items: updated);
    } else {
      final newItem = CustomerCartItem(
        id: 'cart-${DateTime.now().millisecondsSinceEpoch}-${state.items.length}',
        menuItem: menuItem,
        selectedVariant: effectiveVariant,
        selectedAddOns: effectiveAddOns,
        specialInstructions: instructions,
        quantity: quantity,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void updateQuantity(int index, int delta) {
    if (index < 0 || index >= state.items.length) return;
    final item = state.items[index];
    final newQty = item.quantity + delta;

    final updated = List<CustomerCartItem>.from(state.items);
    if (newQty <= 0) {
      updated.removeAt(index);
    } else {
      updated[index] = item.copyWith(quantity: newQty);
    }
    state = state.copyWith(items: updated);
  }

  void removeItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final updated = List<CustomerCartItem>.from(state.items);
    updated.removeAt(index);
    state = state.copyWith(items: updated);
  }

  void clearCart() {
    state = state.copyWith(items: const []);
  }
}

final customerCartProvider = StateNotifierProvider<CustomerCartNotifier, CustomerCartState>((ref) {
  return CustomerCartNotifier();
});
