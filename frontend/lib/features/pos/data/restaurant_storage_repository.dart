// Anabhay Ventures — Restaurant Persistent Local Repository
// Phase 3: Shared Persistent Storage across POS, KDS, Tables and Dashboard

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/order_models.dart';

class RestaurantStorageRepository {
  static const String _keyOrders = 'anabhay_orders_v1';
  static const String _keyTables = 'anabhay_tables_v1';
  static const String _keyInvoices = 'anabhay_invoices_v1';
  static const String _keyMenu = 'anabhay_menu_v1';

  final SharedPreferences? _prefs;

  RestaurantStorageRepository([this._prefs]);

  static Future<RestaurantStorageRepository> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return RestaurantStorageRepository(prefs);
  }

  // ── Menu Operations ───────────────────────────────────────────────────────

  Future<List<MenuItem>> loadMenuItems() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultMenuItems();
    final jsonStr = prefs.getString(_keyMenu);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => MenuItem.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultMenuItems();
    await saveMenuItems(defaults);
    return defaults;
  }

  Future<void> saveMenuItems(List<MenuItem> items) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(items.map((i) => i.toJson()).toList());
    await prefs.setString(_keyMenu, jsonStr);
  }

  // ── Table Operations ──────────────────────────────────────────────────────

  Future<List<RestaurantTable>> loadTables() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultTables();
    final jsonStr = prefs.getString(_keyTables);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => RestaurantTable.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultTables();
    await saveTables(defaults);
    return defaults;
  }

  Future<void> saveTables(List<RestaurantTable> tables) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(tables.map((t) => t.toJson()).toList());
    await prefs.setString(_keyTables, jsonStr);
  }

  // ── Order Operations ──────────────────────────────────────────────────────

  Future<List<RestaurantOrder>> loadOrders() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultOrders();
    final jsonStr = prefs.getString(_keyOrders);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => RestaurantOrder.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultOrders();
    await saveOrders(defaults);
    return defaults;
  }

  Future<void> saveOrders(List<RestaurantOrder> orders) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(orders.map((o) => o.toJson()).toList());
    await prefs.setString(_keyOrders, jsonStr);
  }

  // ── Invoice Operations ────────────────────────────────────────────────────

  Future<List<Invoice>> loadInvoices() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultInvoices();
    final jsonStr = prefs.getString(_keyInvoices);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => Invoice.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultInvoices();
    await saveInvoices(defaults);
    return defaults;
  }

  Future<void> saveInvoices(List<Invoice> invoices) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(invoices.map((i) => i.toJson()).toList());
    await prefs.setString(_keyInvoices, jsonStr);
  }

  // ── Default Seed Data ─────────────────────────────────────────────────────

  static List<MenuItem> getDefaultMenuItems() {
    return [
      const MenuItem(
        id: 'm1',
        name: 'Chicken Dum Biryani',
        category: 'Biryani',
        basePrice: 480.0,
        isVeg: false,
        description: 'Slow-cooked aromatic basmati rice layered with tender saffron chicken.',
        variants: [
          ItemVariant(name: 'Regular', additionalPrice: 0.0),
          ItemVariant(name: 'Double Meat (Chef Spl)', additionalPrice: 120.0),
        ],
        addOns: [
          ItemAddOn(id: 'a1', name: 'Extra Burani Raita', price: 40.0),
          ItemAddOn(id: 'a2', name: 'Extra Mirchi Ka Salan', price: 50.0),
        ],
      ),
      const MenuItem(
        id: 'm2',
        name: 'Butter Naan',
        category: 'Breads',
        basePrice: 90.0,
        isVeg: true,
        description: 'Traditional clay oven baked flatbread brushed with organic butter.',
        variants: [
          ItemVariant(name: 'Single', additionalPrice: 0.0),
          ItemVariant(name: 'Garlic Butter Infused', additionalPrice: 20.0),
        ],
      ),
      const MenuItem(
        id: 'm3',
        name: 'Saffron Dum Biryani',
        category: 'Biryani',
        basePrice: 540.0,
        isVeg: false,
        description: 'Prime royal recipe with Kashmir saffron, whole spices, and caramelized shallots.',
        variants: [
          ItemVariant(name: 'Standard', additionalPrice: 0.0),
          ItemVariant(name: 'Nawabi Grand Portion', additionalPrice: 150.0),
        ],
        addOns: [
          ItemAddOn(id: 'a1', name: 'Extra Burani Raita', price: 40.0),
        ],
      ),
      const MenuItem(
        id: 'm4',
        name: 'Butter Garlic Naan',
        category: 'Breads',
        basePrice: 110.0,
        isVeg: true,
        description: 'Crisp and fluffy tandoori naan scented with roasted minced garlic and coriander.',
      ),
      const MenuItem(
        id: 'm5',
        name: 'Murgh Malai Tikka',
        category: 'Starters',
        basePrice: 460.0,
        isVeg: false,
        description: 'Tender chicken boneless chunks marinated in rich cream, cashew paste and green cardamom.',
        addOns: [
          ItemAddOn(id: 'a3', name: 'Extra Mint Chutney & Onions', price: 30.0),
        ],
      ),
      const MenuItem(
        id: 'm6',
        name: 'Paneer Tikka Angara',
        category: 'Starters',
        basePrice: 390.0,
        isVeg: true,
        description: 'Charcoal-smoked cottage cheese cubes tossed in Rajasthani chili marinade.',
      ),
      const MenuItem(
        id: 'm7',
        name: 'Dal Makhani Reserve',
        category: 'Main Course',
        basePrice: 380.0,
        isVeg: true,
        description: 'Slow simmered black lentils cooked overnight for 18 hours with white butter and tomatoes.',
      ),
      const MenuItem(
        id: 'm8',
        name: 'Butter Chicken Royale',
        category: 'Main Course',
        basePrice: 520.0,
        isVeg: false,
        description: 'Tandoori pulled chicken gently cooked in velvety mild tomato-fenugreek gravy.',
      ),
      const MenuItem(
        id: 'm9',
        name: 'Tandoori Roti',
        category: 'Breads',
        basePrice: 45.0,
        isVeg: true,
        description: 'Whole wheat flatbread blistered to perfection in the clay tandoor.',
      ),
      const MenuItem(
        id: 'm10',
        name: 'Gulab Jamun Flambé',
        category: 'Desserts',
        basePrice: 220.0,
        isVeg: true,
        description: 'Warm milk dumplings infused with old monk rum flambé and pistachio dust.',
      ),
      const MenuItem(
        id: 'm11',
        name: 'Kesari Phirni',
        category: 'Desserts',
        basePrice: 190.0,
        isVeg: true,
        description: 'Chilled ground rice pudding flavored with saffron threads and silver leaf.',
      ),
      const MenuItem(
        id: 'm12',
        name: 'Fresh Lime Soda',
        category: 'Beverages',
        basePrice: 120.0,
        isVeg: true,
        description: 'Refreshing citrus cooler with choice of sweet, salted or mixed soda.',
      ),
      const MenuItem(
        id: 'm13',
        name: 'Royal Masala Chai',
        category: 'Beverages',
        basePrice: 90.0,
        isVeg: true,
        description: 'Slow brewed Assam tea with crushed ginger, cloves, cinnamon and buffalo milk.',
      ),
    ];
  }

  static List<RestaurantTable> getDefaultTables() {
    return [
      const RestaurantTable(
        id: 't1',
        number: 'Table 01',
        code: 'T-01',
        zone: 'Main Dining Hall',
        capacity: 4,
        status: TableStatus.occupied,
        activeOrderId: 'ORD-101',
        currentBill: 2450.0,
        waiter: 'Ramesh K.',
      ),
      const RestaurantTable(
        id: 't2',
        number: 'Table 02',
        code: 'T-02',
        zone: 'Main Dining Hall',
        capacity: 2,
        status: TableStatus.available,
        waiter: '-',
      ),
      const RestaurantTable(
        id: 't3',
        number: 'Table 03',
        code: 'T-03',
        zone: 'Main Dining Hall',
        capacity: 4,
        status: TableStatus.billed,
        activeOrderId: 'ORD-102',
        currentBill: 4180.0,
        waiter: 'Ramesh K.',
      ),
      const RestaurantTable(
        id: 't4',
        number: 'Table 04',
        code: 'T-04',
        zone: 'Main Dining Hall',
        capacity: 6,
        status: TableStatus.occupied,
        activeOrderId: 'ORD-103',
        currentBill: 5890.0,
        waiter: 'Priya S.',
      ),
      // ── Key Demo Table 05: Initially Available ──
      const RestaurantTable(
        id: 't5',
        number: 'Table 05',
        code: 'T-05',
        zone: 'Terrace Garden',
        capacity: 4,
        status: TableStatus.available,
        currentBill: 0.0,
        waiter: '-',
      ),
      const RestaurantTable(
        id: 't6',
        number: 'Table 06',
        code: 'T-06',
        zone: 'Terrace Garden',
        capacity: 4,
        status: TableStatus.occupied,
        activeOrderId: 'ORD-104',
        currentBill: 1850.0,
        waiter: 'Priya S.',
      ),
      const RestaurantTable(
        id: 't7',
        number: 'Table 07',
        code: 'T-07',
        zone: 'Terrace Garden',
        capacity: 2,
        status: TableStatus.reserved,
        waiter: 'Priya S.',
      ),
      const RestaurantTable(
        id: 't8',
        number: 'Table 08',
        code: 'T-08',
        zone: 'Terrace Garden',
        capacity: 8,
        status: TableStatus.occupied,
        activeOrderId: 'ORD-105',
        currentBill: 7200.0,
        waiter: 'Ramesh K.',
      ),
      const RestaurantTable(
        id: 't9',
        number: 'VIP 01',
        code: 'VIP-01',
        zone: 'VIP Lounge',
        capacity: 8,
        status: TableStatus.occupied,
        activeOrderId: 'ORD-106',
        currentBill: 14500.0,
        waiter: 'Sanjay V.',
      ),
      const RestaurantTable(
        id: 't10',
        number: 'VIP 02',
        code: 'VIP-02',
        zone: 'VIP Lounge',
        capacity: 10,
        status: TableStatus.reserved,
        waiter: 'Sanjay V.',
      ),
      const RestaurantTable(
        id: 't11',
        number: 'Table 11',
        code: 'PDR-01',
        zone: 'Private Dining Room',
        capacity: 12,
        status: TableStatus.available,
        waiter: '-',
      ),
      const RestaurantTable(
        id: 't12',
        number: 'Table 12',
        code: 'PDR-02',
        zone: 'Private Dining Room',
        capacity: 16,
        status: TableStatus.occupied,
        activeOrderId: 'ORD-107',
        currentBill: 22800.0,
        waiter: 'Sanjay V.',
      ),
    ];
  }

  static List<RestaurantOrder> getDefaultOrders() {
    final now = DateTime.now();
    return [
      RestaurantOrder(
        id: 'ORD-103',
        kotNumber: 'KOT-104',
        orderType: OrderType.dineIn,
        tableId: 't4',
        tableNumber: 'Table 04',
        items: const [
          OrderItem(id: 'i1', menuItemId: 'm5', name: 'Murgh Malai Tikka', unitPrice: 460.0, quantity: 2, isVeg: false, isPrepared: true),
          OrderItem(id: 'i2', menuItemId: 'm3', name: 'Saffron Dum Biryani', unitPrice: 540.0, quantity: 1, isVeg: false),
          OrderItem(id: 'i3', menuItemId: 'm4', name: 'Butter Garlic Naan', unitPrice: 110.0, quantity: 2, isVeg: true),
        ],
        subtotal: 1680.0,
        cgstAmount: 42.0,
        sgstAmount: 42.0,
        grandTotal: 1764.0,
        orderStatus: OrderStatus.preparing,
        paymentStatus: PaymentStatus.pending,
        generalInstructions: 'Less spicy for child, serve naans piping hot.',
        createdAt: now.subtract(const Duration(minutes: 14)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
      ),
      RestaurantOrder(
        id: 'ORD-107',
        kotNumber: 'KOT-105',
        orderType: OrderType.dineIn,
        tableId: 't12',
        tableNumber: 'Table 12',
        items: const [
          OrderItem(id: 'i4', menuItemId: 'm7', name: 'Dal Makhani Reserve', unitPrice: 380.0, quantity: 2, isVeg: true, isPrepared: true),
          OrderItem(id: 'i5', menuItemId: 'm8', name: 'Butter Chicken Royale', unitPrice: 520.0, quantity: 2, isVeg: false),
          OrderItem(id: 'i6', menuItemId: 'm4', name: 'Butter Garlic Naan', unitPrice: 110.0, quantity: 4, isVeg: true),
        ],
        subtotal: 2240.0,
        cgstAmount: 56.0,
        sgstAmount: 56.0,
        grandTotal: 2352.0,
        orderStatus: OrderStatus.preparing,
        paymentStatus: PaymentStatus.pending,
        createdAt: now.subtract(const Duration(minutes: 8)),
        updatedAt: now.subtract(const Duration(minutes: 2)),
      ),
    ];
  }

  static List<Invoice> getDefaultInvoices() {
    final now = DateTime.now();
    return [
      Invoice(
        invoiceNumber: 'INV-2026-0920',
        orderId: 'ORD-098',
        tableNumber: 'Table 02',
        orderType: OrderType.dineIn,
        items: const [
          OrderItem(id: 'oi1', menuItemId: 'm1', name: 'Chicken Dum Biryani', unitPrice: 480.0, quantity: 2, isVeg: false),
          OrderItem(id: 'oi2', menuItemId: 'm2', name: 'Butter Naan', unitPrice: 90.0, quantity: 2, isVeg: true),
        ],
        subtotal: 1140.0,
        discountAmount: 0.0,
        cgstAmount: 28.5,
        sgstAmount: 28.5,
        grandTotal: 1197.0,
        paymentMethod: 'Demo UPI',
        issuedAt: now.subtract(const Duration(hours: 1)),
      ),
      Invoice(
        invoiceNumber: 'INV-2026-0921',
        orderId: 'ORD-099',
        tableNumber: 'Table 06',
        orderType: OrderType.dineIn,
        items: const [
          OrderItem(id: 'oi3', menuItemId: 'm8', name: 'Butter Chicken Royale', unitPrice: 520.0, quantity: 1, isVeg: false),
          OrderItem(id: 'oi4', menuItemId: 'm4', name: 'Butter Garlic Naan', unitPrice: 110.0, quantity: 3, isVeg: true),
        ],
        subtotal: 850.0,
        discountAmount: 0.0,
        cgstAmount: 21.25,
        sgstAmount: 21.25,
        grandTotal: 892.5,
        paymentMethod: 'Demo Cash',
        issuedAt: now.subtract(const Duration(minutes: 35)),
      ),
    ];
  }
}
