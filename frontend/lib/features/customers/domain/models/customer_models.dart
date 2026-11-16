// Anabhay Ventures — Customer Relationship & Loyalty Domain Models
// Phase 6: Customer CRM, Order History, Total Spend, and Loyalty Points System

class CustomerRecord {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? birthday;
  final String? address;
  final String? notes;
  final int totalOrders;
  final double totalSpend;
  final DateTime lastVisit;
  final int loyaltyPoints;
  final DateTime createdAt;

  const CustomerRecord({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.birthday,
    this.address,
    this.notes,
    this.totalOrders = 0,
    this.totalSpend = 0.0,
    required this.lastVisit,
    this.loyaltyPoints = 0,
    required this.createdAt,
  });

  bool get isReturning => totalOrders > 1;
  bool get isVip => totalSpend >= 5000.0 || totalOrders >= 5;

  CustomerRecord copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? birthday,
    String? address,
    String? notes,
    int? totalOrders,
    double? totalSpend,
    DateTime? lastVisit,
    int? loyaltyPoints,
    DateTime? createdAt,
  }) {
    return CustomerRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpend: totalSpend ?? this.totalSpend,
      lastVisit: lastVisit ?? this.lastVisit,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'birthday': birthday,
        'address': address,
        'notes': notes,
        'totalOrders': totalOrders,
        'totalSpend': totalSpend,
        'lastVisit': lastVisit.toIso8601String(),
        'loyaltyPoints': loyaltyPoints,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomerRecord.fromJson(Map<String, dynamic> json) => CustomerRecord(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
        birthday: json['birthday'] as String?,
        address: json['address'] as String?,
        notes: json['notes'] as String?,
        totalOrders: json['totalOrders'] as int? ?? 0,
        totalSpend: (json['totalSpend'] as num?)?.toDouble() ?? 0.0,
        lastVisit: json['lastVisit'] != null ? DateTime.parse(json['lastVisit'] as String) : DateTime.now(),
        loyaltyPoints: json['loyaltyPoints'] as int? ?? 0,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      );
}

class LoyaltyTransaction {
  final String id;
  final String customerId;
  final String? orderId;
  final int points;
  final String type; // 'earned', 'redeemed'
  final String description;
  final DateTime timestamp;

  const LoyaltyTransaction({
    required this.id,
    required this.customerId,
    this.orderId,
    required this.points,
    required this.type,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'orderId': orderId,
        'points': points,
        'type': type,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) => LoyaltyTransaction(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        orderId: json['orderId'] as String?,
        points: json['points'] as int? ?? 0,
        type: json['type'] as String? ?? 'earned',
        description: json['description'] as String? ?? '',
        timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp'] as String) : DateTime.now(),
      );
}
