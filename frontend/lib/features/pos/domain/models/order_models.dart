// Anabhay Ventures — Restaurant Domain Models
// Phase 3: POS Billing, Kitchen KOT, Tables, and Invoices

import 'package:flutter/material.dart';
import 'package:restaurant_management/core/theme/theme.dart';
import 'package:restaurant_management/shared/widgets/status_badge.dart';

// ── Order Status & Enums ────────────────────────────────────────────────────

enum OrderStatus {
  newOrder('New'),
  preparing('Preparing'),
  ready('Ready'),
  served('Served'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;
  const OrderStatus(this.label);

  Color get color {
    switch (this) {
      case OrderStatus.newOrder:
        return AppColors.warningAmber;
      case OrderStatus.preparing:
        return AppColors.copper;
      case OrderStatus.ready:
        return AppColors.champagneGold;
      case OrderStatus.served:
        return AppColors.successGreen;
      case OrderStatus.completed:
        return AppColors.mutedGrey;
      case OrderStatus.cancelled:
        return AppColors.errorRed;
    }
  }

  BadgeVariant get badgeVariant {
    switch (this) {
      case OrderStatus.newOrder:
        return BadgeVariant.warning;
      case OrderStatus.preparing:
        return BadgeVariant.warning;
      case OrderStatus.ready:
        return BadgeVariant.info;
      case OrderStatus.served:
        return BadgeVariant.success;
      case OrderStatus.completed:
        return BadgeVariant.neutral;
      case OrderStatus.cancelled:
        return BadgeVariant.error;
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => OrderStatus.newOrder,
    );
  }
}

enum OrderType {
  dineIn('Dine-in'),
  takeaway('Takeaway'),
  delivery('Delivery');

  final String label;
  const OrderType(this.label);

  static OrderType fromString(String value) {
    return OrderType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => OrderType.dineIn,
    );
  }
}

enum PaymentStatus {
  pending('Pending'),
  paid('Paid (DEMO)'),
  refunded('Refunded');

  final String label;
  const PaymentStatus(this.label);

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => PaymentStatus.pending,
    );
  }
}

enum TableStatus {
  available('Available'),
  occupied('Occupied'),
  billed('Billed'),
  reserved('Reserved');

  final String label;
  const TableStatus(this.label);

  Color get color {
    switch (this) {
      case TableStatus.available:
        return AppColors.successGreen;
      case TableStatus.occupied:
        return AppColors.errorRed;
      case TableStatus.billed:
        return AppColors.champagneGold;
      case TableStatus.reserved:
        return AppColors.warningAmber;
    }
  }

  BadgeVariant get badgeVariant {
    switch (this) {
      case TableStatus.available:
        return BadgeVariant.success;
      case TableStatus.occupied:
        return BadgeVariant.error;
      case TableStatus.billed:
        return BadgeVariant.info;
      case TableStatus.reserved:
        return BadgeVariant.warning;
    }
  }

  static TableStatus fromString(String value) {
    return TableStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => TableStatus.available,
    );
  }
}

// ── Item Variant & AddOn Models ─────────────────────────────────────────────

class ItemVariant {
  final String name;
  final double additionalPrice;

  const ItemVariant({required this.name, this.additionalPrice = 0.0});

  Map<String, dynamic> toJson() => {'name': name, 'additionalPrice': additionalPrice};

  factory ItemVariant.fromJson(Map<String, dynamic> json) => ItemVariant(
        name: json['name'] as String? ?? 'Standard',
        additionalPrice: (json['additionalPrice'] as num?)?.toDouble() ?? 0.0,
      );
}

class ItemAddOn {
  final String id;
  final String name;
  final double price;

  const ItemAddOn({required this.id, required this.name, required this.price});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};

  factory ItemAddOn.fromJson(Map<String, dynamic> json) => ItemAddOn(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
      );
}

// ── Menu Item Model ─────────────────────────────────────────────────────────

class MenuItem {
  final String id;
  final String name;
  final String category;
  final double basePrice;
  final bool isVeg;
  final String description;
  final bool isAvailable;
  final List<ItemVariant> variants;
  final List<ItemAddOn> addOns;

  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.basePrice,
    required this.isVeg,
    this.description = '',
    this.isAvailable = true,
    this.variants = const [],
    this.addOns = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'basePrice': basePrice,
        'isVeg': isVeg,
        'description': description,
        'isAvailable': isAvailable,
        'variants': variants.map((v) => v.toJson()).toList(),
        'addOns': addOns.map((a) => a.toJson()).toList(),
      };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        basePrice: (json['basePrice'] as num).toDouble(),
        isVeg: json['isVeg'] as bool? ?? true,
        description: json['description'] as String? ?? '',
        isAvailable: json['isAvailable'] as bool? ?? true,
        variants: (json['variants'] as List<dynamic>?)
                ?.map((v) => ItemVariant.fromJson(v as Map<String, dynamic>))
                .toList() ??
            const [],
        addOns: (json['addOns'] as List<dynamic>?)
                ?.map((a) => ItemAddOn.fromJson(a as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

// ── Order Item Model ────────────────────────────────────────────────────────

class OrderItem {
  final String id;
  final String menuItemId;
  final String name;
  final double unitPrice;
  final int quantity;
  final bool isVeg;
  final String? variantName;
  final List<String> selectedAddOns;
  final double addOnsTotal;
  final String? specialInstruction;
  final bool isPrepared;

  const OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.isVeg,
    this.variantName,
    this.selectedAddOns = const [],
    this.addOnsTotal = 0.0,
    this.specialInstruction,
    this.isPrepared = false,
  });

  double get totalPrice => (unitPrice + addOnsTotal) * quantity;

  OrderItem copyWith({
    String? id,
    String? menuItemId,
    String? name,
    double? unitPrice,
    int? quantity,
    bool? isVeg,
    String? variantName,
    List<String>? selectedAddOns,
    double? addOnsTotal,
    String? specialInstruction,
    bool? isPrepared,
  }) {
    return OrderItem(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      isVeg: isVeg ?? this.isVeg,
      variantName: variantName ?? this.variantName,
      selectedAddOns: selectedAddOns ?? this.selectedAddOns,
      addOnsTotal: addOnsTotal ?? this.addOnsTotal,
      specialInstruction: specialInstruction ?? this.specialInstruction,
      isPrepared: isPrepared ?? this.isPrepared,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'menuItemId': menuItemId,
        'name': name,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'isVeg': isVeg,
        'variantName': variantName,
        'selectedAddOns': selectedAddOns,
        'addOnsTotal': addOnsTotal,
        'specialInstruction': specialInstruction,
        'isPrepared': isPrepared,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'] as String,
        menuItemId: json['menuItemId'] as String,
        name: json['name'] as String,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        quantity: json['quantity'] as int? ?? 1,
        isVeg: json['isVeg'] as bool? ?? true,
        variantName: json['variantName'] as String?,
        selectedAddOns: (json['selectedAddOns'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        addOnsTotal: (json['addOnsTotal'] as num?)?.toDouble() ?? 0.0,
        specialInstruction: json['specialInstruction'] as String?,
        isPrepared: json['isPrepared'] as bool? ?? false,
      );
}

// ── Restaurant Order Model ──────────────────────────────────────────────────

class RestaurantOrder {
  final String id;
  final String kotNumber;
  final OrderType orderType;
  final String? tableId;
  final String tableNumber;
  final String? customerName;
  final String? customerPhone;
  final List<OrderItem> items;
  final double subtotal;
  final double discountPercent;
  final double discountAmount;
  final double cgstRate; // 0.025 = 2.5%
  final double sgstRate; // 0.025 = 2.5%
  final double cgstAmount;
  final double sgstAmount;
  final double grandTotal;
  final OrderStatus orderStatus;
  final PaymentStatus paymentStatus;
  final String? paymentMethod; // 'Demo Cash', 'Demo UPI', 'Demo Card'
  final String? generalInstructions;
  final String? invoiceNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RestaurantOrder({
    required this.id,
    required this.kotNumber,
    required this.orderType,
    this.tableId,
    required this.tableNumber,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.subtotal,
    this.discountPercent = 0.0,
    this.discountAmount = 0.0,
    this.cgstRate = 0.025,
    this.sgstRate = 0.025,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.grandTotal,
    required this.orderStatus,
    required this.paymentStatus,
    this.paymentMethod,
    this.generalInstructions,
    this.invoiceNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  RestaurantOrder copyWith({
    String? id,
    String? kotNumber,
    OrderType? orderType,
    String? tableId,
    String? tableNumber,
    String? customerName,
    String? customerPhone,
    List<OrderItem>? items,
    double? subtotal,
    double? discountPercent,
    double? discountAmount,
    double? cgstRate,
    double? sgstRate,
    double? cgstAmount,
    double? sgstAmount,
    double? grandTotal,
    OrderStatus? orderStatus,
    PaymentStatus? paymentStatus,
    String? paymentMethod,
    String? generalInstructions,
    String? invoiceNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantOrder(
      id: id ?? this.id,
      kotNumber: kotNumber ?? this.kotNumber,
      orderType: orderType ?? this.orderType,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      generalInstructions: generalInstructions ?? this.generalInstructions,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kotNumber': kotNumber,
        'orderType': orderType.name,
        'tableId': tableId,
        'tableNumber': tableNumber,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'discountPercent': discountPercent,
        'discountAmount': discountAmount,
        'cgstRate': cgstRate,
        'sgstRate': sgstRate,
        'cgstAmount': cgstAmount,
        'sgstAmount': sgstAmount,
        'grandTotal': grandTotal,
        'orderStatus': orderStatus.name,
        'paymentStatus': paymentStatus.name,
        'paymentMethod': paymentMethod,
        'generalInstructions': generalInstructions,
        'invoiceNumber': invoiceNumber,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory RestaurantOrder.fromJson(Map<String, dynamic> json) => RestaurantOrder(
        id: json['id'] as String,
        kotNumber: json['kotNumber'] as String? ?? 'KOT-101',
        orderType: OrderType.fromString(json['orderType'] as String? ?? 'dineIn'),
        tableId: json['tableId'] as String?,
        tableNumber: json['tableNumber'] as String? ?? 'Takeaway',
        customerName: json['customerName'] as String?,
        customerPhone: json['customerPhone'] as String?,
        items: (json['items'] as List<dynamic>?)
                ?.map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
                .toList() ??
            const [],
        subtotal: (json['subtotal'] as num).toDouble(),
        discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0.0,
        discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
        cgstRate: (json['cgstRate'] as num?)?.toDouble() ?? 0.025,
        sgstRate: (json['sgstRate'] as num?)?.toDouble() ?? 0.025,
        cgstAmount: (json['cgstAmount'] as num).toDouble(),
        sgstAmount: (json['sgstAmount'] as num).toDouble(),
        grandTotal: (json['grandTotal'] as num).toDouble(),
        orderStatus: OrderStatus.fromString(json['orderStatus'] as String? ?? 'newOrder'),
        paymentStatus: PaymentStatus.fromString(json['paymentStatus'] as String? ?? 'pending'),
        paymentMethod: json['paymentMethod'] as String?,
        generalInstructions: json['generalInstructions'] as String?,
        invoiceNumber: json['invoiceNumber'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

// ── Restaurant Table Model ──────────────────────────────────────────────────

class RestaurantTable {
  final String id;
  final String number; // e.g. "Table 05"
  final String code; // e.g. "T-05"
  final String zone; // "Main Dining Hall", "Terrace Garden", etc.
  final int capacity;
  final TableStatus status;
  final String? activeOrderId;
  final double currentBill;
  final String? waiter;
  final DateTime? occupiedSince;

  const RestaurantTable({
    required this.id,
    required this.number,
    required this.code,
    required this.zone,
    required this.capacity,
    required this.status,
    this.activeOrderId,
    this.currentBill = 0.0,
    this.waiter,
    this.occupiedSince,
  });

  RestaurantTable copyWith({
    String? id,
    String? number,
    String? code,
    String? zone,
    int? capacity,
    TableStatus? status,
    String? activeOrderId,
    double? currentBill,
    String? waiter,
    DateTime? occupiedSince,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      number: number ?? this.number,
      code: code ?? this.code,
      zone: zone ?? this.zone,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      activeOrderId: activeOrderId,
      currentBill: currentBill ?? this.currentBill,
      waiter: waiter ?? this.waiter,
      occupiedSince: occupiedSince ?? this.occupiedSince,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'code': code,
        'zone': zone,
        'capacity': capacity,
        'status': status.name,
        'activeOrderId': activeOrderId,
        'currentBill': currentBill,
        'waiter': waiter,
        'occupiedSince': occupiedSince?.toIso8601String(),
      };

  factory RestaurantTable.fromJson(Map<String, dynamic> json) => RestaurantTable(
        id: json['id'] as String,
        number: json['number'] as String,
        code: json['code'] as String? ?? json['number'] as String,
        zone: json['zone'] as String,
        capacity: json['capacity'] as int? ?? 4,
        status: TableStatus.fromString(json['status'] as String? ?? 'available'),
        activeOrderId: json['activeOrderId'] as String?,
        currentBill: (json['currentBill'] as num?)?.toDouble() ?? 0.0,
        waiter: json['waiter'] as String?,
        occupiedSince: json['occupiedSince'] != null ? DateTime.tryParse(json['occupiedSince'] as String) : null,
      );
}

// ── Invoice Model ───────────────────────────────────────────────────────────

class Invoice {
  final String invoiceNumber; // "INV-2026-0924"
  final String orderId;
  final String tableNumber;
  final OrderType orderType;
  final List<OrderItem> items;
  final double subtotal;
  final double discountAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double grandTotal;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime issuedAt;
  final String restaurantName;
  final String restaurantAddress;
  final String gstin;
  final String fssai;

  const Invoice({
    required this.invoiceNumber,
    required this.orderId,
    required this.tableNumber,
    required this.orderType,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.grandTotal,
    required this.paymentMethod,
    this.paymentStatus = 'PAID (DEMO)',
    required this.issuedAt,
    this.restaurantName = 'THE ROYAL SAFFRON • ANABHAY VENTURES',
    this.restaurantAddress = 'Park Street Flagship • Kolkata - 700016\nPhone: +91 98300 12345',
    this.gstin = '19AAECR1234F1Z5',
    this.fssai = '12821019000123',
  });

  Map<String, dynamic> toJson() => {
        'invoiceNumber': invoiceNumber,
        'orderId': orderId,
        'tableNumber': tableNumber,
        'orderType': orderType.name,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'discountAmount': discountAmount,
        'cgstAmount': cgstAmount,
        'sgstAmount': sgstAmount,
        'grandTotal': grandTotal,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'issuedAt': issuedAt.toIso8601String(),
        'restaurantName': restaurantName,
        'restaurantAddress': restaurantAddress,
        'gstin': gstin,
        'fssai': fssai,
      };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        invoiceNumber: json['invoiceNumber'] as String,
        orderId: json['orderId'] as String,
        tableNumber: json['tableNumber'] as String,
        orderType: OrderType.fromString(json['orderType'] as String? ?? 'dineIn'),
        items: (json['items'] as List<dynamic>?)
                ?.map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
                .toList() ??
            const [],
        subtotal: (json['subtotal'] as num).toDouble(),
        discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
        cgstAmount: (json['cgstAmount'] as num).toDouble(),
        sgstAmount: (json['sgstAmount'] as num).toDouble(),
        grandTotal: (json['grandTotal'] as num).toDouble(),
        paymentMethod: json['paymentMethod'] as String? ?? 'Demo Cash',
        paymentStatus: json['paymentStatus'] as String? ?? 'PAID (DEMO)',
        issuedAt: DateTime.parse(json['issuedAt'] as String),
        restaurantName: json['restaurantName'] as String? ?? 'THE ROYAL SAFFRON • ANABHAY VENTURES',
        restaurantAddress: json['restaurantAddress'] as String? ?? 'Park Street Flagship • Kolkata - 700016',
        gstin: json['gstin'] as String? ?? '19AAECR1234F1Z5',
        fssai: json['fssai'] as String? ?? '12821019000123',
      );
}
