// Anabhay Ventures — Shared Domain Models

library shared_models;

enum UserRole {
  saasSuperAdmin,
  restaurantOwner,
  restaurantAdmin,
  branchManager,
  cashier,
  waiter,
  kitchenStaff,
  inventoryManager,
  accountant,
  customer;

  String get value {
    switch (this) {
      case UserRole.saasSuperAdmin: return 'super_admin';
      case UserRole.restaurantOwner: return 'restaurant_owner';
      case UserRole.restaurantAdmin: return 'restaurant_admin';
      case UserRole.branchManager: return 'branch_manager';
      case UserRole.cashier: return 'cashier';
      case UserRole.waiter: return 'waiter';
      case UserRole.kitchenStaff: return 'kitchen_staff';
      case UserRole.inventoryManager: return 'inventory_manager';
      case UserRole.accountant: return 'accountant';
      case UserRole.customer: return 'customer';
    }
  }

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.value == role,
      orElse: () => UserRole.cashier,
    );
  }
}

enum TableStatus {
  available,
  occupied,
  reserved,
  cleaning;

  String get displayName {
    switch (this) {
      case TableStatus.available: return 'Available';
      case TableStatus.occupied: return 'Occupied';
      case TableStatus.reserved: return 'Reserved';
      case TableStatus.cleaning: return 'Billed';
    }
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  served,
  completed,
  cancelled;
}

enum OrderType {
  dineIn,
  takeaway,
  delivery,
  qrOrder;

  String get displayName {
    switch (this) {
      case OrderType.dineIn: return 'Dine-In';
      case OrderType.takeaway: return 'Takeaway';
      case OrderType.delivery: return 'Delivery';
      case OrderType.qrOrder: return 'QR Order';
    }
  }
}

// ── Tenant ──────────────────────────────────────────────────
class Tenant {
  final String id;
  final String name;
  final String slug;
  final String businessType;
  final String ownerName;
  final String ownerEmail;
  final String ownerPhone;
  final String currency;
  final String subscriptionPlan;
  final bool isActive;

  const Tenant({
    required this.id,
    required this.name,
    required this.slug,
    this.businessType = 'fine_dining',
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerPhone,
    this.currency = 'INR',
    this.subscriptionPlan = 'professional',
    this.isActive = true,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
    id: json['id'] as String,
    name: json['name'] as String,
    slug: json['slug'] as String,
    businessType: json['business_type'] as String? ?? 'fine_dining',
    ownerName: json['owner_name'] as String,
    ownerEmail: json['owner_email'] as String,
    ownerPhone: json['owner_phone'] as String,
    currency: json['currency'] as String? ?? 'INR',
    subscriptionPlan: json['subscription_plan'] as String? ?? 'professional',
    isActive: json['is_active'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'business_type': businessType,
    'owner_name': ownerName,
    'owner_email': ownerEmail,
    'owner_phone': ownerPhone,
    'currency': currency,
    'subscription_plan': subscriptionPlan,
    'is_active': isActive,
  };
}

// ── Branch ──────────────────────────────────────────────────
class Branch {
  final String id;
  final String tenantId;
  final String name;
  final String branchCode;
  final String address;
  final String city;
  final String state;
  final String phone;
  final String? gstin;
  final String? fssai;
  final bool isMainBranch;
  final bool isActive;

  const Branch({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.branchCode,
    required this.address,
    required this.city,
    required this.state,
    required this.phone,
    this.gstin,
    this.fssai,
    this.isMainBranch = false,
    this.isActive = true,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    id: json['id'] as String,
    tenantId: json['tenant_id'] as String,
    name: json['name'] as String,
    branchCode: json['branch_code'] as String,
    address: json['address'] as String,
    city: json['city'] as String,
    state: json['state'] as String,
    phone: json['phone'] as String,
    gstin: json['gstin'] as String?,
    fssai: json['fssai'] as String?,
    isMainBranch: json['is_main_branch'] as bool? ?? false,
    isActive: json['is_active'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tenant_id': tenantId,
    'name': name,
    'branch_code': branchCode,
    'address': address,
    'city': city,
    'state': state,
    'phone': phone,
    'gstin': gstin,
    'fssai': fssai,
    'is_main_branch': isMainBranch,
    'is_active': isActive,
  };
}

// ── User ────────────────────────────────────────────────────
class User {
  final String id;
  final String? tenantId;
  final String? branchId;
  final String email;
  final String fullName;
  final String? phone;
  final UserRole role;
  final bool isActive;

  const User({
    required this.id,
    this.tenantId,
    this.branchId,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    tenantId: json['tenant_id'] as String?,
    branchId: json['branch_id'] as String?,
    email: json['email'] as String,
    fullName: json['full_name'] as String,
    phone: json['phone'] as String?,
    role: UserRole.fromString(json['role'] as String? ?? 'cashier'),
    isActive: json['is_active'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tenant_id': tenantId,
    'branch_id': branchId,
    'email': email,
    'full_name': fullName,
    'phone': phone,
    'role': role.value,
    'is_active': isActive,
  };
}

// ── Table ───────────────────────────────────────────────────
class RestaurantTable {
  final String id;
  final String tableNumber;
  final int capacity;
  final String floorZone;
  final TableStatus status;
  final String? currentWaiterName;
  final double currentBillAmount;

  const RestaurantTable({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.floorZone,
    this.status = TableStatus.available,
    this.currentWaiterName,
    this.currentBillAmount = 0.0,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) => RestaurantTable(
    id: json['id'] as String,
    tableNumber: json['table_number'] as String,
    capacity: json['capacity'] as int? ?? 4,
    floorZone: json['floor_zone'] as String? ?? 'Main Dining',
    status: TableStatus.values.firstWhere(
      (s) => s.name == (json['status'] as String? ?? 'available'),
      orElse: () => TableStatus.available,
    ),
    currentWaiterName: json['current_waiter_name'] as String?,
    currentBillAmount: (json['current_bill_amount'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'table_number': tableNumber,
    'capacity': capacity,
    'floor_zone': floorZone,
    'status': status.name,
    'current_waiter_name': currentWaiterName,
    'current_bill_amount': currentBillAmount,
  };
}

// ── Menu Item ───────────────────────────────────────────────
class MenuItem {
  final String id;
  final String name;
  final String? description;
  final String categoryName;
  final double price;
  final double taxRate;
  final bool isVeg;
  final bool isAvailable;

  const MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.categoryName,
    required this.price,
    this.taxRate = 5.0,
    this.isVeg = true,
    this.isAvailable = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    categoryName: json['category_name'] as String? ?? 'General',
    price: (json['price'] as num).toDouble(),
    taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 5.0,
    isVeg: json['is_veg'] as bool? ?? true,
    isAvailable: json['is_available'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category_name': categoryName,
    'price': price,
    'tax_rate': taxRate,
    'is_veg': isVeg,
    'is_available': isAvailable,
  };
}

// ── Order Item ──────────────────────────────────────────────
class OrderItem {
  final String id;
  final String menuItemId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double taxRate;
  final String? notes;

  const OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 5.0,
    this.notes,
  });

  double get subtotal => unitPrice * quantity;
  double get taxAmount => subtotal * (taxRate / 100);
  double get total => subtotal + taxAmount;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] as String,
    menuItemId: json['menu_item_id'] as String,
    name: json['name'] as String,
    quantity: json['quantity'] as int? ?? 1,
    unitPrice: (json['unit_price'] as num).toDouble(),
    taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 5.0,
    notes: json['notes'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'menu_item_id': menuItemId,
    'name': name,
    'quantity': quantity,
    'unit_price': unitPrice,
    'tax_rate': taxRate,
    'notes': notes,
  };
}

// ── Order ───────────────────────────────────────────────────
class Order {
  final String id;
  final String orderNumber;
  final OrderType type;
  final OrderStatus status;
  final String? tableNumber;
  final List<OrderItem> items;
  final double subtotal;
  final double cgst;
  final double sgst;
  final double totalAmount;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.type,
    required this.status,
    this.tableNumber,
    required this.items,
    required this.subtotal,
    required this.cgst,
    required this.sgst,
    required this.totalAmount,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    orderNumber: json['order_number'] as String,
    type: OrderType.values.firstWhere(
      (t) => t.name == (json['type'] as String? ?? 'dineIn'),
      orElse: () => OrderType.dineIn,
    ),
    status: OrderStatus.values.firstWhere(
      (s) => s.name == (json['status'] as String? ?? 'pending'),
      orElse: () => OrderStatus.pending,
    ),
    tableNumber: json['table_number'] as String?,
    items: ((json['items'] as List<dynamic>?) ?? [])
        .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
        .toList(),
    subtotal: (json['subtotal'] as num).toDouble(),
    cgst: (json['cgst'] as num).toDouble(),
    sgst: (json['sgst'] as num).toDouble(),
    totalAmount: (json['total_amount'] as num).toDouble(),
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_number': orderNumber,
    'type': type.name,
    'status': status.name,
    'table_number': tableNumber,
    'items': items.map((i) => i.toJson()).toList(),
    'subtotal': subtotal,
    'cgst': cgst,
    'sgst': sgst,
    'total_amount': totalAmount,
    'created_at': createdAt.toIso8601String(),
  };
}

// ── Inventory Stock Item ────────────────────────────────────
class StockItem {
  final String id;
  final String name;
  final String category;
  final double currentStock;
  final double minThreshold;
  final String unit;
  final double unitCost;

  const StockItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minThreshold,
    required this.unit,
    required this.unitCost,
  });

  bool get isLowStock => currentStock <= minThreshold;

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    currentStock: (json['current_stock'] as num).toDouble(),
    minThreshold: (json['min_threshold'] as num).toDouble(),
    unit: json['unit'] as String,
    unitCost: (json['unit_cost'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'current_stock': currentStock,
    'min_threshold': minThreshold,
    'unit': unit,
    'unit_cost': unitCost,
  };
}

