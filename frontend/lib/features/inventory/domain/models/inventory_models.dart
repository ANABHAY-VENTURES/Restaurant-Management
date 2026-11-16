// Anabhay Ventures — Restaurant Inventory & Menu Domain Models
// Phase 4: Menu Categories, Ingredients, Recipes, Stock Movements, Suppliers, and Purchases

import 'package:flutter/material.dart';
import 'package:restaurant_management/core/theme/theme.dart';
import 'package:restaurant_management/shared/widgets/status_badge.dart';

// ── Dietary Type Enum ───────────────────────────────────────────────────────

enum DietaryType {
  veg('Vegetarian'),
  nonVeg('Non-Vegetarian'),
  egg('Contains Egg');

  final String label;
  const DietaryType(this.label);

  Color get color {
    switch (this) {
      case DietaryType.veg:
        return AppColors.successGreen;
      case DietaryType.nonVeg:
        return AppColors.errorRed;
      case DietaryType.egg:
        return AppColors.warningAmber;
    }
  }

  static DietaryType fromString(String? val) {
    if (val == null) return DietaryType.veg;
    return DietaryType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.label.toLowerCase() == val.toLowerCase(),
      orElse: () => DietaryType.veg,
    );
  }
}

// ── Inventory Unit Enum ─────────────────────────────────────────────────────

enum InventoryUnit {
  kg('Kilogram', 'kg'),
  g('Gram', 'g'),
  litre('Litre', 'L'),
  ml('Millilitre', 'ml'),
  pieces('Pieces', 'pcs'),
  packets('Packets', 'pkt'),
  bottles('Bottles', 'btl');

  final String label;
  final String symbol;
  const InventoryUnit(this.label, this.symbol);

  static InventoryUnit fromString(String? val) {
    if (val == null) return InventoryUnit.kg;
    return InventoryUnit.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == val.toLowerCase() ||
          e.symbol.toLowerCase() == val.toLowerCase() ||
          e.label.toLowerCase() == val.toLowerCase(),
      orElse: () => InventoryUnit.kg,
    );
  }

  /// Converts a quantity from this unit to base unit (kg for g, litre for ml, or 1:1)
  double toBaseUnit(double qty) {
    if (this == InventoryUnit.g) return qty / 1000.0;
    if (this == InventoryUnit.ml) return qty / 1000.0;
    return qty;
  }
}

// ── Menu Category Model ─────────────────────────────────────────────────────

class MenuCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int displayOrder;
  final bool isActive;

  const MenuCategory({
    required this.id,
    required this.name,
    this.description = '',
    this.icon = Icons.restaurant_menu_rounded,
    this.displayOrder = 0,
    this.isActive = true,
  });

  MenuCategory copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    int? displayOrder,
    bool? isActive,
  }) {
    return MenuCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'displayOrder': displayOrder,
        'isActive': isActive,
      };

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        displayOrder: json['displayOrder'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
      );
}

// ── Ingredient Model ────────────────────────────────────────────────────────

class Ingredient {
  final String id;
  final String name;
  final String sku;
  final String category; // 'Grains', 'Meat & Poultry', 'Dairy', 'Produce', 'Spices', 'Oils & Fats'
  final InventoryUnit unit;
  final double currentStock;
  final double minStockLevel;
  final double unitCost; // in ₹ per unit
  final String? supplierId;
  final String? supplierName;
  final DateTime? expiryDate;

  const Ingredient({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.minStockLevel,
    required this.unitCost,
    this.supplierId,
    this.supplierName,
    this.expiryDate,
  });

  bool get isOutOfStock => currentStock <= 0;
  bool get isLowStock => currentStock > 0 && currentStock <= minStockLevel;
  double get totalValue => currentStock * unitCost;

  BadgeVariant get statusBadgeVariant {
    if (isOutOfStock) return BadgeVariant.error;
    if (isLowStock) return BadgeVariant.warning;
    return BadgeVariant.success;
  }

  String get statusLabel {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'Adequate';
  }

  Ingredient copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    InventoryUnit? unit,
    double? currentStock,
    double? minStockLevel,
    double? unitCost,
    String? supplierId,
    String? supplierName,
    DateTime? expiryDate,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      unitCost: unitCost ?? this.unitCost,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'category': category,
        'unit': unit.name,
        'currentStock': currentStock,
        'minStockLevel': minStockLevel,
        'unitCost': unitCost,
        'supplierId': supplierId,
        'supplierName': supplierName,
        'expiryDate': expiryDate?.toIso8601String(),
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: json['id'] as String,
        name: json['name'] as String,
        sku: json['sku'] as String? ?? 'SKU-${json['id']}',
        category: json['category'] as String? ?? 'General',
        unit: InventoryUnit.fromString(json['unit'] as String?),
        currentStock: (json['currentStock'] as num).toDouble(),
        minStockLevel: (json['minStockLevel'] as num).toDouble(),
        unitCost: (json['unitCost'] as num).toDouble(),
        supplierId: json['supplierId'] as String?,
        supplierName: json['supplierName'] as String?,
        expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate'] as String) : null,
      );
}

// ── Recipe Ingredient & Recipe Models ───────────────────────────────────────

class RecipeIngredient {
  final String ingredientId;
  final String ingredientName;
  final double quantity; // in the recipe's unit (e.g. 250 for grams)
  final InventoryUnit unit;
  final double unitCost; // cost per unit of inventory

  const RecipeIngredient({
    required this.ingredientId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    required this.unitCost,
  });

  /// Cost of this ingredient in the recipe (adjusting grams/kg and ml/L)
  double get estimatedCost {
    if (unit == InventoryUnit.g) {
      // If ingredient inventory unit cost is per kg, then (quantity / 1000) * unitCost
      return (quantity / 1000.0) * unitCost;
    } else if (unit == InventoryUnit.ml) {
      return (quantity / 1000.0) * unitCost;
    }
    return quantity * unitCost;
  }

  RecipeIngredient copyWith({
    String? ingredientId,
    String? ingredientName,
    double? quantity,
    InventoryUnit? unit,
    double? unitCost,
  }) {
    return RecipeIngredient(
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientName: ingredientName ?? this.ingredientName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitCost: unitCost ?? this.unitCost,
    );
  }

  Map<String, dynamic> toJson() => {
        'ingredientId': ingredientId,
        'ingredientName': ingredientName,
        'quantity': quantity,
        'unit': unit.name,
        'unitCost': unitCost,
      };

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => RecipeIngredient(
        ingredientId: json['ingredientId'] as String,
        ingredientName: json['ingredientName'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: InventoryUnit.fromString(json['unit'] as String?),
        unitCost: (json['unitCost'] as num).toDouble(),
      );
}

class Recipe {
  final String id;
  final String menuItemId;
  final String menuItemName;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final String preparationNotes;

  const Recipe({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    this.servings = 1,
    required this.ingredients,
    this.preparationNotes = '',
  });

  double get totalEstimatedFoodCost =>
      ingredients.fold(0.0, (sum, ing) => sum + ing.estimatedCost);

  double get costPerServing => servings > 0 ? (totalEstimatedFoodCost / servings) : totalEstimatedFoodCost;

  Recipe copyWith({
    String? id,
    String? menuItemId,
    String? menuItemName,
    int? servings,
    List<RecipeIngredient>? ingredients,
    String? preparationNotes,
  }) {
    return Recipe(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      menuItemName: menuItemName ?? this.menuItemName,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      preparationNotes: preparationNotes ?? this.preparationNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'menuItemId': menuItemId,
        'menuItemName': menuItemName,
        'servings': servings,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'preparationNotes': preparationNotes,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        menuItemId: json['menuItemId'] as String,
        menuItemName: json['menuItemName'] as String,
        servings: json['servings'] as int? ?? 1,
        ingredients: (json['ingredients'] as List<dynamic>?)
                ?.map((i) => RecipeIngredient.fromJson(i as Map<String, dynamic>))
                .toList() ??
            const [],
        preparationNotes: json['preparationNotes'] as String? ?? '',
      );
}

// ── Stock Movement Models ───────────────────────────────────────────────────

enum StockMovementType {
  purchase('Stock Received', true),
  orderDeduction('POS Order Prepared', false),
  wastage('Kitchen Spoilage / Wastage', false),
  damaged('Damaged Goods', false),
  manualAdjustment('Manual Stock Count Adjustment', null),
  orderReversal('Order Cancelled / Returned', true);

  final String label;
  final bool? isPositive; // true: adds, false: deducts, null: depends
  const StockMovementType(this.label, this.isPositive);
}

class StockMovement {
  final String id;
  final String ingredientId;
  final String ingredientName;
  final StockMovementType type;
  final double quantity; // absolute quantity change
  final InventoryUnit unit;
  final double previousStock;
  final double newStock;
  final String reason;
  final String? referenceId; // Order ID or Purchase Order ID
  final DateTime timestamp;

  const StockMovement({
    required this.id,
    required this.ingredientId,
    required this.ingredientName,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.previousStock,
    required this.newStock,
    required this.reason,
    this.referenceId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ingredientId': ingredientId,
        'ingredientName': ingredientName,
        'type': type.name,
        'quantity': quantity,
        'unit': unit.name,
        'previousStock': previousStock,
        'newStock': newStock,
        'reason': reason,
        'referenceId': referenceId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory StockMovement.fromJson(Map<String, dynamic> json) => StockMovement(
        id: json['id'] as String,
        ingredientId: json['ingredientId'] as String,
        ingredientName: json['ingredientName'] as String,
        type: StockMovementType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => StockMovementType.manualAdjustment,
        ),
        quantity: (json['quantity'] as num).toDouble(),
        unit: InventoryUnit.fromString(json['unit'] as String?),
        previousStock: (json['previousStock'] as num).toDouble(),
        newStock: (json['newStock'] as num).toDouble(),
        reason: json['reason'] as String? ?? '',
        referenceId: json['referenceId'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

// ── Supplier & Purchase Order Models ────────────────────────────────────────

class Supplier {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String category;
  final String address;
  final String gstin;

  const Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.category,
    required this.address,
    required this.gstin,
  });

  Supplier copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? category,
    String? address,
    String? gstin,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      category: category ?? this.category,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contactPerson': contactPerson,
        'phone': phone,
        'email': email,
        'category': category,
        'address': address,
        'gstin': gstin,
      };

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'] as String,
        name: json['name'] as String,
        contactPerson: json['contactPerson'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        category: json['category'] as String? ?? 'General',
        address: json['address'] as String? ?? '',
        gstin: json['gstin'] as String? ?? '',
      );
}

class PurchaseItem {
  final String ingredientId;
  final String ingredientName;
  final double quantity;
  final InventoryUnit unit;
  final double unitPrice;

  const PurchaseItem({
    required this.ingredientId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
        'ingredientId': ingredientId,
        'ingredientName': ingredientName,
        'quantity': quantity,
        'unit': unit.name,
        'unitPrice': unitPrice,
      };

  factory PurchaseItem.fromJson(Map<String, dynamic> json) => PurchaseItem(
        ingredientId: json['ingredientId'] as String,
        ingredientName: json['ingredientName'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: InventoryUnit.fromString(json['unit'] as String?),
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );
}

class PurchaseOrder {
  final String id;
  final String supplierId;
  final String supplierName;
  final DateTime orderDate;
  final DateTime? receivedDate;
  final bool isReceived;
  final List<PurchaseItem> items;
  final double totalAmount;
  final String paymentStatus; // 'Paid', 'Pending'
  final String notes;

  const PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.orderDate,
    this.receivedDate,
    this.isReceived = false,
    required this.items,
    required this.totalAmount,
    this.paymentStatus = 'Paid',
    this.notes = '',
  });

  PurchaseOrder copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    DateTime? orderDate,
    DateTime? receivedDate,
    bool? isReceived,
    List<PurchaseItem>? items,
    double? totalAmount,
    String? paymentStatus,
    String? notes,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      orderDate: orderDate ?? this.orderDate,
      receivedDate: receivedDate ?? this.receivedDate,
      isReceived: isReceived ?? this.isReceived,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'supplierId': supplierId,
        'supplierName': supplierName,
        'orderDate': orderDate.toIso8601String(),
        'receivedDate': receivedDate?.toIso8601String(),
        'isReceived': isReceived,
        'items': items.map((i) => i.toJson()).toList(),
        'totalAmount': totalAmount,
        'paymentStatus': paymentStatus,
        'notes': notes,
      };

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) => PurchaseOrder(
        id: json['id'] as String,
        supplierId: json['supplierId'] as String,
        supplierName: json['supplierName'] as String,
        orderDate: DateTime.parse(json['orderDate'] as String),
        receivedDate: json['receivedDate'] != null ? DateTime.tryParse(json['receivedDate'] as String) : null,
        isReceived: json['isReceived'] as bool? ?? false,
        items: (json['items'] as List<dynamic>?)
                ?.map((i) => PurchaseItem.fromJson(i as Map<String, dynamic>))
                .toList() ??
            const [],
        totalAmount: (json['totalAmount'] as num).toDouble(),
        paymentStatus: json['paymentStatus'] as String? ?? 'Paid',
        notes: json['notes'] as String? ?? '',
      );
}
