// Anabhay Ventures — Restaurant Persistent Local Repository
// Phase 4: Shared Persistence for Menu, Categories, Ingredients, Recipes, Stock Movements, Suppliers, Purchases

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/order_models.dart';
import '../../inventory/domain/models/inventory_models.dart';
import '../../staff/domain/models/staff_models.dart';
import '../../customers/domain/models/customer_models.dart';
import '../../settings/domain/models/settings_models.dart';

class RestaurantStorageRepository {
  static const String _keyOrders = 'anabhay_orders_v1';
  static const String _keyTables = 'anabhay_tables_v1';
  static const String _keyInvoices = 'anabhay_invoices_v1';
  static const String _keyMenu = 'anabhay_menu_v2';
  static const String _keyCategories = 'anabhay_categories_v1';
  static const String _keyIngredients = 'anabhay_ingredients_v1';
  static const String _keyRecipes = 'anabhay_recipes_v1';
  static const String _keyStockMovements = 'anabhay_stock_movements_v1';
  static const String _keySuppliers = 'anabhay_suppliers_v1';
  static const String _keyPurchases = 'anabhay_purchases_v1';
  static const String _keyStaff = 'anabhay_staff_v1';
  static const String _keyAttendance = 'anabhay_attendance_v1';
  static const String _keyCustomers = 'anabhay_customers_v1';
  static const String _keyLoyalty = 'anabhay_loyalty_v1';
  static const String _keyProfile = 'anabhay_profile_v1';
  static const String _keyTaxBilling = 'anabhay_tax_billing_v1';
  static const String _keyInvoiceConfig = 'anabhay_invoice_config_v1';
  static const String _keyOrderPosConfig = 'anabhay_order_pos_v1';
  static const String _keyTableQrConfig = 'anabhay_table_qr_config_v1';
  static const String _keyThemeMode = 'anabhay_theme_mode_v1';
  static const String _keyLanguage = 'anabhay_language_v1';

  final SharedPreferences? _prefs;

  RestaurantStorageRepository([this._prefs]);

  static Future<RestaurantStorageRepository> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return RestaurantStorageRepository(prefs);
  }

  // ── Categories Operations ─────────────────────────────────────────────────

  Future<List<MenuCategory>> loadCategories() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultCategories();
    final jsonStr = prefs.getString(_keyCategories);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => MenuCategory.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultCategories();
    await saveCategories(defaults);
    return defaults;
  }

  Future<void> saveCategories(List<MenuCategory> categories) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_keyCategories, jsonStr);
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

  // ── Ingredient Operations ─────────────────────────────────────────────────

  Future<List<Ingredient>> loadIngredients() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultIngredients();
    final jsonStr = prefs.getString(_keyIngredients);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultIngredients();
    await saveIngredients(defaults);
    return defaults;
  }

  Future<void> saveIngredients(List<Ingredient> ingredients) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(ingredients.map((i) => i.toJson()).toList());
    await prefs.setString(_keyIngredients, jsonStr);
  }

  // ── Recipe Operations ─────────────────────────────────────────────────────

  Future<List<Recipe>> loadRecipes() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultRecipes();
    final jsonStr = prefs.getString(_keyRecipes);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultRecipes();
    await saveRecipes(defaults);
    return defaults;
  }

  Future<void> saveRecipes(List<Recipe> recipes) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(recipes.map((r) => r.toJson()).toList());
    await prefs.setString(_keyRecipes, jsonStr);
  }

  // ── Stock Movement Operations ─────────────────────────────────────────────

  Future<List<StockMovement>> loadStockMovements() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultStockMovements();
    final jsonStr = prefs.getString(_keyStockMovements);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => StockMovement.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultStockMovements();
    await saveStockMovements(defaults);
    return defaults;
  }

  Future<void> saveStockMovements(List<StockMovement> movements) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(movements.map((m) => m.toJson()).toList());
    await prefs.setString(_keyStockMovements, jsonStr);
  }

  // ── Supplier Operations ───────────────────────────────────────────────────

  Future<List<Supplier>> loadSuppliers() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultSuppliers();
    final jsonStr = prefs.getString(_keySuppliers);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => Supplier.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultSuppliers();
    await saveSuppliers(defaults);
    return defaults;
  }

  Future<void> saveSuppliers(List<Supplier> suppliers) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(suppliers.map((s) => s.toJson()).toList());
    await prefs.setString(_keySuppliers, jsonStr);
  }

  // ── Purchase Operations ───────────────────────────────────────────────────

  Future<List<PurchaseOrder>> loadPurchases() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultPurchases();
    final jsonStr = prefs.getString(_keyPurchases);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => PurchaseOrder.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultPurchases();
    await savePurchases(defaults);
    return defaults;
  }

  Future<void> savePurchases(List<PurchaseOrder> purchases) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(purchases.map((p) => p.toJson()).toList());
    await prefs.setString(_keyPurchases, jsonStr);
  }

  // ── Default Seed Data ─────────────────────────────────────────────────────

  static List<MenuCategory> getDefaultCategories() {
    return const [
      MenuCategory(id: 'cat_all', name: 'All', displayOrder: 0),
      MenuCategory(id: 'cat_biryani', name: 'Biryani', description: 'Royal dum cooked long-grain rice delicacies', icon: Icons.rice_bowl_rounded, displayOrder: 1),
      MenuCategory(id: 'cat_starters', name: 'Starters', description: 'Clay oven kebabs and appetizers', icon: Icons.outdoor_grill_rounded, displayOrder: 2),
      MenuCategory(id: 'cat_main', name: 'Main Course', description: 'Slow cooked curries and signature dishes', icon: Icons.dinner_dining_rounded, displayOrder: 3),
      MenuCategory(id: 'cat_breads', name: 'Breads', description: 'Fresh tandoori naans and rotis', icon: Icons.bakery_dining_rounded, displayOrder: 4),
      MenuCategory(id: 'cat_chinese', name: 'Chinese', description: 'Indo-Chinese wok-tossed delights', icon: Icons.ramen_dining_rounded, displayOrder: 5),
      MenuCategory(id: 'cat_desserts', name: 'Desserts', description: 'Traditional royal sweets and flambés', icon: Icons.icecream_rounded, displayOrder: 6),
      MenuCategory(id: 'cat_beverages', name: 'Beverages', description: 'Artisanal teas, sodas and coolers', icon: Icons.local_cafe_rounded, displayOrder: 7),
    ];
  }

  static List<MenuItem> getDefaultMenuItems() {
    return const [
      MenuItem(
        id: 'm1',
        name: 'Chicken Dum Biryani',
        category: 'Biryani',
        basePrice: 480.0,
        foodCost: 168.0,
        dietaryType: DietaryType.nonVeg,
        isVeg: false,
        prepTimeMinutes: 25,
        isFeatured: true,
        description: 'Slow-cooked aromatic basmati rice layered with tender saffron chicken and caramelized shallots.',
        variants: [
          ItemVariant(name: 'Regular', additionalPrice: 0.0),
          ItemVariant(name: 'Double Meat (Chef Spl)', additionalPrice: 120.0),
        ],
        addOns: [
          ItemAddOn(id: 'a1', name: 'Extra Burani Raita', price: 40.0),
          ItemAddOn(id: 'a2', name: 'Extra Mirchi Ka Salan', price: 50.0),
        ],
      ),
      MenuItem(
        id: 'm2',
        name: 'Butter Naan',
        category: 'Breads',
        basePrice: 90.0,
        foodCost: 22.0,
        dietaryType: DietaryType.veg,
        isVeg: true,
        prepTimeMinutes: 5,
        description: 'Traditional clay oven baked flatbread brushed with organic butter.',
        variants: [
          ItemVariant(name: 'Single', additionalPrice: 0.0),
          ItemVariant(name: 'Garlic Butter Infused', additionalPrice: 20.0),
        ],
      ),
      MenuItem(
        id: 'm3',
        name: 'Saffron Dum Biryani',
        category: 'Biryani',
        basePrice: 540.0,
        foodCost: 185.0,
        dietaryType: DietaryType.nonVeg,
        isVeg: false,
        prepTimeMinutes: 30,
        isFeatured: true,
        description: 'Prime royal recipe with Kashmir saffron, whole spices, and caramelized shallots.',
        variants: [
          ItemVariant(name: 'Standard', additionalPrice: 0.0),
          ItemVariant(name: 'Nawabi Grand Portion', additionalPrice: 150.0),
        ],
        addOns: [
          ItemAddOn(id: 'a1', name: 'Extra Burani Raita', price: 40.0),
        ],
      ),
      MenuItem(
        id: 'm4',
        name: 'Butter Garlic Naan',
        category: 'Breads',
        basePrice: 110.0,
        foodCost: 28.0,
        dietaryType: DietaryType.veg,
        isVeg: true,
        prepTimeMinutes: 6,
        description: 'Crisp and fluffy tandoori naan scented with roasted minced garlic and coriander.',
      ),
      MenuItem(
        id: 'm5',
        name: 'Murgh Malai Tikka',
        category: 'Starters',
        basePrice: 460.0,
        foodCost: 142.0,
        dietaryType: DietaryType.nonVeg,
        isVeg: false,
        prepTimeMinutes: 18,
        description: 'Tender chicken boneless chunks marinated in rich cream, cashew paste and green cardamom.',
        addOns: [
          ItemAddOn(id: 'a3', name: 'Extra Mint Chutney & Onions', price: 30.0),
        ],
      ),
      MenuItem(
        id: 'm6',
        name: 'Paneer Tikka Angara',
        category: 'Starters',
        basePrice: 390.0,
        foodCost: 115.0,
        dietaryType: DietaryType.veg,
        isVeg: true,
        prepTimeMinutes: 15,
        description: 'Charcoal-smoked cottage cheese cubes tossed in Rajasthani chili marinade.',
      ),
      MenuItem(
        id: 'm7',
        name: 'Dal Makhani Reserve',
        category: 'Main Course',
        basePrice: 380.0,
        foodCost: 95.0,
        dietaryType: DietaryType.veg,
        isVeg: true,
        prepTimeMinutes: 12,
        isFeatured: true,
        description: 'Slow simmered black lentils cooked overnight for 18 hours with white butter and tomatoes.',
      ),
      MenuItem(
        id: 'm8',
        name: 'Butter Chicken Royale',
        category: 'Main Course',
        basePrice: 520.0,
        foodCost: 165.0,
        dietaryType: DietaryType.nonVeg,
        isVeg: false,
        prepTimeMinutes: 20,
        isFeatured: true,
        description: 'Tandoori pulled chicken gently cooked in velvety mild tomato-fenugreek gravy.',
      ),
      MenuItem(
        id: 'm9',
        name: 'Tandoori Roti',
        category: 'Breads',
        basePrice: 45.0,
        foodCost: 10.0,
        dietaryType: DietaryType.veg,
        isVeg: true,
        prepTimeMinutes: 5,
        description: 'Whole wheat flatbread blistered to perfection in the clay tandoor.',
      ),
      MenuItem(
        id: 'm10',
        name: 'Gulab Jamun Flambé',
        category: 'Desserts',
        basePrice: 220.0,
        foodCost: 65.0,
        dietaryType: DietaryType.veg,
        isVeg: true,
        prepTimeMinutes: 10,
        description: 'Warm milk dumplings infused with old monk rum flambé and pistachio dust.',
      ),
      MenuItem(
        id: 'm11',
        name: 'Kesari Phirni',
        category: 'Desserts',
        basePrice: 190.0,
        foodCost: 55.0,
        dietaryType: DietaryType.veg,
        isVeg: true,
        prepTimeMinutes: 8,
        description: 'Chilled ground rice pudding flavored with saffron threads and silver leaf.',
      ),
      MenuItem(
        id: 'm12',
        name: 'Fresh Lime Soda',
        category: 'Beverages',
        basePrice: 120.0,
        foodCost: 20.0,
        dietaryType: DietaryType.veg,
        isVeg: true,
        prepTimeMinutes: 5,
        description: 'Refreshing citrus cooler with choice of sweet, salted or mixed soda.',
      ),
      MenuItem(
        id: 'm13',
        name: 'Royal Masala Chai',
        category: 'Beverages',
        basePrice: 90.0,
        foodCost: 18.0,
        dietaryType: DietaryType.veg,
        isVeg: true,
        prepTimeMinutes: 7,
        description: 'Slow brewed Assam tea with crushed ginger, cloves, cinnamon and buffalo milk.',
      ),
    ];
  }

  static List<Ingredient> getDefaultIngredients() {
    final now = DateTime.now();
    return [
      Ingredient(
        id: 'ing_rice',
        name: 'Basmati Biryani Rice (Daawat)',
        sku: 'SKU-GRA-001',
        category: 'Grains',
        unit: InventoryUnit.kg,
        currentStock: 48.0,
        minStockLevel: 30.0,
        unitCost: 140.0, // ₹140 per kg
        supplierId: 'sup_1',
        supplierName: 'Agro Royal Grains & Spices',
        expiryDate: now.add(const Duration(days: 180)),
      ),
      Ingredient(
        id: 'ing_chicken',
        name: 'Fresh Boneless Chicken Breast',
        sku: 'SKU-MEA-002',
        category: 'Meat & Poultry',
        unit: InventoryUnit.kg,
        currentStock: 28.5,
        minStockLevel: 20.0,
        unitCost: 280.0, // ₹280 per kg
        supplierId: 'sup_3',
        supplierName: 'Kolkata Fresh Poultry & Meats',
        expiryDate: now.add(const Duration(days: 3)),
      ),
      Ingredient(
        id: 'ing_paneer',
        name: 'Fresh Malai Paneer',
        sku: 'SKU-DAI-003',
        category: 'Dairy',
        unit: InventoryUnit.kg,
        currentStock: 16.0,
        minStockLevel: 15.0,
        unitCost: 380.0,
        supplierId: 'sup_2',
        supplierName: 'Bengal Dairy & Cheese Federation',
        expiryDate: now.add(const Duration(days: 4)),
      ),
      Ingredient(
        id: 'ing_butter',
        name: 'Amul Butter (Yellow)',
        sku: 'SKU-DAI-004',
        category: 'Dairy',
        unit: InventoryUnit.kg,
        currentStock: 14.0,
        minStockLevel: 10.0,
        unitCost: 540.0,
        supplierId: 'sup_2',
        supplierName: 'Bengal Dairy & Cheese Federation',
        expiryDate: now.add(const Duration(days: 60)),
      ),
      Ingredient(
        id: 'ing_cream',
        name: 'Amul Fresh Cooking Cream',
        sku: 'SKU-DAI-005',
        category: 'Dairy',
        unit: InventoryUnit.litre,
        currentStock: 7.5,
        minStockLevel: 12.0, // LOW STOCK!
        unitCost: 190.0,
        supplierId: 'sup_2',
        supplierName: 'Bengal Dairy & Cheese Federation',
        expiryDate: now.add(const Duration(days: 14)),
      ),
      Ingredient(
        id: 'ing_maida',
        name: 'Refined Wheat Maida (Grade A)',
        sku: 'SKU-GRA-006',
        category: 'Grains',
        unit: InventoryUnit.kg,
        currentStock: 35.0,
        minStockLevel: 25.0,
        unitCost: 45.0,
        supplierId: 'sup_1',
        supplierName: 'Agro Royal Grains & Spices',
        expiryDate: now.add(const Duration(days: 90)),
      ),
      Ingredient(
        id: 'ing_lentils',
        name: 'Black Urad Whole Lentils',
        sku: 'SKU-GRA-007',
        category: 'Grains',
        unit: InventoryUnit.kg,
        currentStock: 22.0,
        minStockLevel: 15.0,
        unitCost: 150.0,
        supplierId: 'sup_1',
        supplierName: 'Agro Royal Grains & Spices',
        expiryDate: now.add(const Duration(days: 120)),
      ),
      Ingredient(
        id: 'ing_onion',
        name: 'Nashik Red Onions',
        sku: 'SKU-PRO-008',
        category: 'Produce',
        unit: InventoryUnit.kg,
        currentStock: 40.0,
        minStockLevel: 25.0,
        unitCost: 35.0,
        supplierId: 'sup_1',
        supplierName: 'Agro Royal Grains & Spices',
        expiryDate: now.add(const Duration(days: 20)),
      ),
      Ingredient(
        id: 'ing_oil',
        name: 'Sunflower Cooking Oil (Fortune)',
        sku: 'SKU-OIL-009',
        category: 'Oils & Fats',
        unit: InventoryUnit.litre,
        currentStock: 32.0,
        minStockLevel: 20.0,
        unitCost: 135.0,
        supplierId: 'sup_1',
        supplierName: 'Agro Royal Grains & Spices',
        expiryDate: now.add(const Duration(days: 150)),
      ),
      Ingredient(
        id: 'ing_saffron',
        name: 'Kashmiri Mogra Saffron (Grade A)',
        sku: 'SKU-SPI-010',
        category: 'Spices',
        unit: InventoryUnit.g,
        currentStock: 18.0,
        minStockLevel: 25.0, // LOW STOCK!
        unitCost: 320.0, // ₹320 per gram
        supplierId: 'sup_4',
        supplierName: 'Everest & Badshah Herbals',
        expiryDate: now.add(const Duration(days: 365)),
      ),
      Ingredient(
        id: 'ing_khoya',
        name: 'Pure Mawa / Khoya',
        sku: 'SKU-DAI-011',
        category: 'Dairy',
        unit: InventoryUnit.kg,
        currentStock: 4.0,
        minStockLevel: 8.0, // LOW STOCK!
        unitCost: 420.0,
        supplierId: 'sup_2',
        supplierName: 'Bengal Dairy & Cheese Federation',
        expiryDate: now.add(const Duration(days: 5)),
      ),
      Ingredient(
        id: 'ing_spices',
        name: 'Royal Shahi Garam Masala Blend',
        sku: 'SKU-SPI-012',
        category: 'Spices',
        unit: InventoryUnit.kg,
        currentStock: 12.0,
        minStockLevel: 8.0,
        unitCost: 650.0,
        supplierId: 'sup_4',
        supplierName: 'Everest & Badshah Herbals',
        expiryDate: now.add(const Duration(days: 180)),
      ),
    ];
  }

  static List<Recipe> getDefaultRecipes() {
    return const [
      Recipe(
        id: 'rec_biryani',
        menuItemId: 'm1',
        menuItemName: 'Chicken Dum Biryani',
        servings: 1,
        preparationNotes: 'Marinate chicken 2 hours in curd and spices. Layer rice at 70% par-boiled.',
        ingredients: [
          RecipeIngredient(ingredientId: 'ing_rice', ingredientName: 'Basmati Biryani Rice', quantity: 250, unit: InventoryUnit.g, unitCost: 140.0), // 0.25 * 140 = 35.0
          RecipeIngredient(ingredientId: 'ing_chicken', ingredientName: 'Boneless Chicken Breast', quantity: 200, unit: InventoryUnit.g, unitCost: 280.0), // 0.20 * 280 = 56.0
          RecipeIngredient(ingredientId: 'ing_onion', ingredientName: 'Nashik Red Onions', quantity: 50, unit: InventoryUnit.g, unitCost: 35.0), // 0.05 * 35 = 1.75
          RecipeIngredient(ingredientId: 'ing_oil', ingredientName: 'Sunflower Cooking Oil', quantity: 20, unit: InventoryUnit.ml, unitCost: 135.0), // 0.02 * 135 = 2.70
          RecipeIngredient(ingredientId: 'ing_spices', ingredientName: 'Royal Shahi Garam Masala', quantity: 15, unit: InventoryUnit.g, unitCost: 650.0), // 0.015 * 650 = 9.75
          RecipeIngredient(ingredientId: 'ing_butter', ingredientName: 'Amul Butter', quantity: 20, unit: InventoryUnit.g, unitCost: 540.0), // 0.02 * 540 = 10.80
        ],
      ),
      Recipe(
        id: 'rec_naan',
        menuItemId: 'm2',
        menuItemName: 'Butter Naan',
        servings: 1,
        preparationNotes: 'Knead dough 4 hours prior. Bake in 400°C clay tandoor for 90 seconds.',
        ingredients: [
          RecipeIngredient(ingredientId: 'ing_maida', ingredientName: 'Refined Wheat Maida', quantity: 120, unit: InventoryUnit.g, unitCost: 45.0), // 0.12 * 45 = 5.40
          RecipeIngredient(ingredientId: 'ing_butter', ingredientName: 'Amul Butter', quantity: 25, unit: InventoryUnit.g, unitCost: 540.0), // 0.025 * 540 = 13.50
        ],
      ),
      Recipe(
        id: 'rec_dal_makhani',
        menuItemId: 'm7',
        menuItemName: 'Dal Makhani Reserve',
        servings: 1,
        preparationNotes: 'Simmer black lentils 18 hours with butter and cream on slow charcoal embers.',
        ingredients: [
          RecipeIngredient(ingredientId: 'ing_lentils', ingredientName: 'Black Urad Lentils', quantity: 150, unit: InventoryUnit.g, unitCost: 150.0), // 0.15 * 150 = 22.50
          RecipeIngredient(ingredientId: 'ing_butter', ingredientName: 'Amul Butter', quantity: 40, unit: InventoryUnit.g, unitCost: 540.0), // 0.04 * 540 = 21.60
          RecipeIngredient(ingredientId: 'ing_cream', ingredientName: 'Fresh Cooking Cream', quantity: 30, unit: InventoryUnit.ml, unitCost: 190.0), // 0.03 * 190 = 5.70
          RecipeIngredient(ingredientId: 'ing_spices', ingredientName: 'Royal Shahi Garam Masala', quantity: 10, unit: InventoryUnit.g, unitCost: 650.0), // 0.01 * 650 = 6.50
        ],
      ),
      Recipe(
        id: 'rec_gulab_jamun',
        menuItemId: 'm10',
        menuItemName: 'Gulab Jamun Flambé',
        servings: 2,
        preparationNotes: 'Roll khoya gently, fry at low temperature in ghee, steep in rose-cardamom syrup.',
        ingredients: [
          RecipeIngredient(ingredientId: 'ing_khoya', ingredientName: 'Pure Mawa / Khoya', quantity: 100, unit: InventoryUnit.g, unitCost: 420.0), // 0.1 * 420 = 42.0
          RecipeIngredient(ingredientId: 'ing_maida', ingredientName: 'Refined Wheat Maida', quantity: 30, unit: InventoryUnit.g, unitCost: 45.0), // 0.03 * 45 = 1.35
        ],
      ),
    ];
  }

  static List<StockMovement> getDefaultStockMovements() {
    final now = DateTime.now();
    return [
      StockMovement(
        id: 'mov_1',
        ingredientId: 'ing_rice',
        ingredientName: 'Basmati Biryani Rice (Daawat)',
        type: StockMovementType.purchase,
        quantity: 50.0,
        unit: InventoryUnit.kg,
        previousStock: 0.0,
        newStock: 50.0,
        reason: 'Monthly grain procurement from Agro Royal',
        referenceId: 'PO-2026-001',
        timestamp: now.subtract(const Duration(days: 3)),
      ),
      StockMovement(
        id: 'mov_2',
        ingredientId: 'ing_rice',
        ingredientName: 'Basmati Biryani Rice (Daawat)',
        type: StockMovementType.orderDeduction,
        quantity: 2.0,
        unit: InventoryUnit.kg,
        previousStock: 50.0,
        newStock: 48.0,
        reason: 'Kitchen POS Orders (8 Biryanis prepared)',
        referenceId: 'ORD-2026-098',
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
      StockMovement(
        id: 'mov_3',
        ingredientId: 'ing_cream',
        ingredientName: 'Amul Fresh Cooking Cream',
        type: StockMovementType.wastage,
        quantity: 1.5,
        unit: InventoryUnit.litre,
        previousStock: 9.0,
        newStock: 7.5,
        reason: 'Exceeded refrigerator cold-chain duration (spoilage)',
        timestamp: now.subtract(const Duration(hours: 12)),
      ),
    ];
  }

  static List<Supplier> getDefaultSuppliers() {
    return const [
      Supplier(
        id: 'sup_1',
        name: 'Agro Royal Grains & Spices',
        contactPerson: 'Suresh Singhania',
        phone: '+91 98310 44550',
        email: 'orders@agroroyal.in',
        category: 'Grains, Flour & Oils',
        address: 'Bara Bazaar Wholesale Market, Kolkata - 700007',
        gstin: '19AAECR9988A1Z1',
      ),
      Supplier(
        id: 'sup_2',
        name: 'Bengal Dairy & Cheese Federation',
        contactPerson: 'Amit Mondal',
        phone: '+91 98322 88990',
        email: 'supplies@bengaldairy.org',
        category: 'Dairy, Butter & Cream',
        address: 'Dankuni Industrial Estate, Howrah - 712311',
        gstin: '19BBDCR4455B2Z3',
      ),
      Supplier(
        id: 'sup_3',
        name: 'Kolkata Fresh Poultry & Meats',
        contactPerson: 'Md. Tariq Khan',
        phone: '+91 98305 11223',
        email: 'tariq@kolkatafreshmeats.com',
        category: 'Poultry & Fresh Meats',
        address: 'Beckbagan Central Abattoir, Kolkata - 700017',
        gstin: '19CCPKM3322C3Z5',
      ),
      Supplier(
        id: 'sup_4',
        name: 'Everest & Badshah Herbals',
        contactPerson: 'Harsh Vardhan',
        phone: '+91 98301 77665',
        email: 'sales@everestspices.co.in',
        category: 'Pure Spices & Saffron',
        address: 'Strand Road Spice Arcade, Kolkata - 700001',
        gstin: '19DDHBS7788D4Z7',
      ),
    ];
  }

  static List<PurchaseOrder> getDefaultPurchases() {
    final now = DateTime.now();
    return [
      PurchaseOrder(
        id: 'PO-2026-001',
        supplierId: 'sup_1',
        supplierName: 'Agro Royal Grains & Spices',
        orderDate: now.subtract(const Duration(days: 4)),
        receivedDate: now.subtract(const Duration(days: 3)),
        isReceived: true,
        totalAmount: 11500.0,
        paymentStatus: 'Paid',
        notes: 'Monthly staples consignment. Received in prime condition.',
        items: const [
          PurchaseItem(ingredientId: 'ing_rice', ingredientName: 'Basmati Biryani Rice', quantity: 50.0, unit: InventoryUnit.kg, unitPrice: 140.0),
          PurchaseItem(ingredientId: 'ing_maida', ingredientName: 'Refined Wheat Maida', quantity: 50.0, unit: InventoryUnit.kg, unitPrice: 45.0),
          PurchaseItem(ingredientId: 'ing_lentils', ingredientName: 'Black Urad Lentils', quantity: 15.0, unit: InventoryUnit.kg, unitPrice: 150.0),
        ],
      ),
      PurchaseOrder(
        id: 'PO-2026-002',
        supplierId: 'sup_2',
        supplierName: 'Bengal Dairy & Cheese Federation',
        orderDate: now.subtract(const Duration(days: 1)),
        isReceived: false,
        totalAmount: 5800.0,
        paymentStatus: 'Pending',
        notes: 'Weekly fresh dairy restock (Butter & Cream). Delivery expected tomorrow 8:00 AM.',
        items: const [
          PurchaseItem(ingredientId: 'ing_butter', ingredientName: 'Amul Butter', quantity: 8.0, unit: InventoryUnit.kg, unitPrice: 540.0),
          PurchaseItem(ingredientId: 'ing_cream', ingredientName: 'Fresh Cooking Cream', quantity: 8.0, unit: InventoryUnit.litre, unitPrice: 190.0),
        ],
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
        hasInventoryDeducted: true,
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
        hasInventoryDeducted: true,
        createdAt: now.subtract(const Duration(minutes: 8)),
        updatedAt: now.subtract(const Duration(minutes: 2)),
      ),
    ];
  }

  static List<Invoice> getDefaultInvoices() {
    return [
      Invoice(
        invoiceNumber: 'INV-2026-0924',
        orderId: 'ORD-092',
        tableNumber: 'T-04',
        orderType: OrderType.dineIn,
        items: const [],
        subtotal: 1200.0,
        discountAmount: 0.0,
        cgstAmount: 30.0,
        sgstAmount: 30.0,
        grandTotal: 1260.0,
        paymentMethod: 'UPI',
        paymentStatus: 'paid',
        issuedAt: DateTime.now().subtract(const Duration(hours: 2)),
        restaurantName: 'The Royal Saffron',
        restaurantAddress: '12 Park Street, Kolkata',
        gstin: '19AABCR1234F1Z5',
        fssai: '12823019000456',
      ),
    ];
  }

  // ── Staff & Attendance Operations ──────────────────────────────────────────

  Future<List<StaffMember>> loadStaff() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultStaff();
    final jsonStr = prefs.getString(_keyStaff);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => StaffMember.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultStaff();
    await saveStaff(defaults);
    return defaults;
  }

  Future<void> saveStaff(List<StaffMember> staff) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(staff.map((s) => s.toJson()).toList());
    await prefs.setString(_keyStaff, jsonStr);
  }

  Future<List<StaffAttendance>> loadAttendance() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultAttendance();
    final jsonStr = prefs.getString(_keyAttendance);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => StaffAttendance.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultAttendance();
    await saveAttendance(defaults);
    return defaults;
  }

  Future<void> saveAttendance(List<StaffAttendance> attendance) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(attendance.map((a) => a.toJson()).toList());
    await prefs.setString(_keyAttendance, jsonStr);
  }

  // ── Customer & Loyalty Operations ─────────────────────────────────────────

  Future<List<CustomerRecord>> loadCustomers() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultCustomers();
    final jsonStr = prefs.getString(_keyCustomers);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => CustomerRecord.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultCustomers();
    await saveCustomers(defaults);
    return defaults;
  }

  Future<void> saveCustomers(List<CustomerRecord> customers) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(customers.map((c) => c.toJson()).toList());
    await prefs.setString(_keyCustomers, jsonStr);
  }

  Future<List<LoyaltyTransaction>> loadLoyalty() async {
    final prefs = _prefs;
    if (prefs == null) return getDefaultLoyalty();
    final jsonStr = prefs.getString(_keyLoyalty);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => LoyaltyTransaction.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    final defaults = getDefaultLoyalty();
    await saveLoyalty(defaults);
    return defaults;
  }

  Future<void> saveLoyalty(List<LoyaltyTransaction> transactions) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonStr = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_keyLoyalty, jsonStr);
  }

  static List<StaffMember> getDefaultStaff() {
    final now = DateTime.now();
    return [
      StaffMember(
        id: 'stf-1',
        name: 'Vikramaditya Roy',
        phone: '+91 98765 43210',
        email: 'vikram@royalsaffron.com',
        address: 'Connaught Place, New Delhi',
        role: StaffRole.manager,
        joiningDate: now.subtract(const Duration(days: 360)),
        monthlySalary: 75000.0,
        ordersHandled: 48,
        notes: 'General Manager & Hospitality Lead',
      ),
      StaffMember(
        id: 'stf-2',
        name: 'Chef Sanjeev Anand',
        phone: '+91 98765 43211',
        email: 'chef.sanjeev@royalsaffron.com',
        address: 'Mayur Vihar, New Delhi',
        role: StaffRole.chef,
        joiningDate: now.subtract(const Duration(days: 300)),
        monthlySalary: 65000.0,
        ordersHandled: 165,
        notes: 'Executive Awadhi Head Chef',
      ),
      StaffMember(
        id: 'stf-3',
        name: 'Anita Roy',
        phone: '+91 98765 43212',
        email: 'anita@royalsaffron.com',
        address: 'Karol Bagh, New Delhi',
        role: StaffRole.cashier,
        joiningDate: now.subtract(const Duration(days: 220)),
        monthlySalary: 32000.0,
        ordersHandled: 120,
        notes: 'Chief Cashier & Register Controller',
      ),
      StaffMember(
        id: 'stf-4',
        name: 'Ramesh Kumar',
        phone: '+91 98765 43213',
        email: 'ramesh.k@royalsaffron.com',
        address: 'Laxmi Nagar, New Delhi',
        role: StaffRole.waiter,
        joiningDate: now.subtract(const Duration(days: 180)),
        monthlySalary: 28000.0,
        ordersHandled: 142,
        notes: 'Main Hall Senior Captain',
      ),
      StaffMember(
        id: 'stf-5',
        name: 'Deepak Verma',
        phone: '+91 98765 43214',
        email: 'deepak.v@royalsaffron.com',
        address: 'Rohini, New Delhi',
        role: StaffRole.kitchenHelper,
        joiningDate: now.subtract(const Duration(days: 150)),
        monthlySalary: 22000.0,
        ordersHandled: 95,
        notes: 'Station Assistant & Tandoor Specialist',
      ),
      StaffMember(
        id: 'stf-6',
        name: 'Priya Nambiar',
        phone: '+91 98765 43215',
        email: 'priya.n@royalsaffron.com',
        address: 'Saket, New Delhi',
        role: StaffRole.waiter,
        joiningDate: now.subtract(const Duration(days: 110)),
        monthlySalary: 26000.0,
        ordersHandled: 88,
        notes: 'VIP Lounge Hostess & Service Steward',
      ),
      StaffMember(
        id: 'stf-7',
        name: 'Farhan Akhtar',
        phone: '+91 98765 43216',
        email: 'farhan@royalsaffron.com',
        address: 'Daryaganj, New Delhi',
        role: StaffRole.deliveryStaff,
        joiningDate: now.subtract(const Duration(days: 90)),
        monthlySalary: 24000.0,
        ordersHandled: 64,
        notes: 'Direct Delivery & Packaging Dispatcher',
      ),
      StaffMember(
        id: 'stf-8',
        name: 'Baldev Singh',
        phone: '+91 98765 43217',
        email: 'baldev@royalsaffron.com',
        address: 'Paharganj, New Delhi',
        role: StaffRole.cleaner,
        joiningDate: now.subtract(const Duration(days: 200)),
        monthlySalary: 18000.0,
        ordersHandled: 0,
        notes: 'Sanitation & Hygiene Lead',
      ),
    ];
  }

  static List<StaffAttendance> getDefaultAttendance() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      StaffAttendance(id: 'att-1', staffId: 'stf-1', staffName: 'Vikramaditya Roy', date: today, status: AttendanceStatus.present, checkInTime: '09:00 AM', checkOutTime: '07:30 PM'),
      StaffAttendance(id: 'att-2', staffId: 'stf-2', staffName: 'Chef Sanjeev Anand', date: today, status: AttendanceStatus.present, checkInTime: '10:30 AM', checkOutTime: null),
      StaffAttendance(id: 'att-3', staffId: 'stf-3', staffName: 'Anita Roy', date: today, status: AttendanceStatus.present, checkInTime: '10:45 AM', checkOutTime: null),
      StaffAttendance(id: 'att-4', staffId: 'stf-4', staffName: 'Ramesh Kumar', date: today, status: AttendanceStatus.present, checkInTime: '11:00 AM', checkOutTime: null),
      StaffAttendance(id: 'att-5', staffId: 'stf-5', staffName: 'Deepak Verma', date: today, status: AttendanceStatus.present, checkInTime: '10:15 AM', checkOutTime: null),
      StaffAttendance(id: 'att-6', staffId: 'stf-6', staffName: 'Priya Nambiar', date: today, status: AttendanceStatus.halfDay, checkInTime: '11:30 AM', checkOutTime: '03:30 PM', notes: 'Leave approved for doctor appointment'),
      StaffAttendance(id: 'att-7', staffId: 'stf-7', staffName: 'Farhan Akhtar', date: today, status: AttendanceStatus.present, checkInTime: '11:15 AM', checkOutTime: null),
      StaffAttendance(id: 'att-8', staffId: 'stf-8', staffName: 'Baldev Singh', date: today, status: AttendanceStatus.absent, notes: 'Casual Sick Leave'),
    ];
  }

  static List<CustomerRecord> getDefaultCustomers() {
    final now = DateTime.now();
    return [
      CustomerRecord(
        id: 'cust-1',
        name: 'Aarav Malhotra',
        phone: '+91 98765 43210',
        email: 'aarav.malhotra@gmail.com',
        birthday: '14 May',
        address: 'Jor Bagh, New Delhi',
        notes: 'Prefers Table 05 in Main Hall. Allergic to peanuts.',
        totalOrders: 6,
        totalSpend: 7420.0,
        lastVisit: now.subtract(const Duration(days: 1)),
        loyaltyPoints: 370,
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      CustomerRecord(
        id: 'cust-2',
        name: 'Dr. Sunita Mehra',
        phone: '+91 98111 22334',
        email: 'drsunita@aiims.edu',
        birthday: '22 October',
        address: 'Green Park, New Delhi',
        notes: 'VIP Patron. Loves Murgh Awadhi Dum Biryani extra spicy.',
        totalOrders: 5,
        totalSpend: 5680.0,
        lastVisit: now.subtract(const Duration(days: 3)),
        loyaltyPoints: 284,
        createdAt: now.subtract(const Duration(days: 75)),
      ),
      CustomerRecord(
        id: 'cust-3',
        name: 'Rohan Singhania',
        phone: '+91 98222 33445',
        email: 'rohan.s@singhania.org',
        birthday: '08 December',
        address: 'Golf Links, New Delhi',
        notes: 'Corporate lunches. Usually requests GST invoice.',
        totalOrders: 4,
        totalSpend: 4890.0,
        lastVisit: now.subtract(const Duration(days: 6)),
        loyaltyPoints: 244,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      CustomerRecord(
        id: 'cust-4',
        name: 'Kavita Deshmukh',
        phone: '+91 98333 44556',
        email: 'kavita.d@outlook.com',
        birthday: '30 January',
        address: 'Vasant Vihar, New Delhi',
        notes: 'Family dining with children. Prefers mild spices.',
        totalOrders: 3,
        totalSpend: 3150.0,
        lastVisit: now.subtract(const Duration(days: 12)),
        loyaltyPoints: 157,
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      CustomerRecord(
        id: 'cust-5',
        name: 'Ananya Roy',
        phone: '+91 98444 55667',
        email: 'ananya.roy@techfirm.in',
        birthday: '18 August',
        address: 'Chanakyapuri, New Delhi',
        notes: 'Terrace garden regular.',
        totalOrders: 2,
        totalSpend: 1980.0,
        lastVisit: now.subtract(const Duration(days: 18)),
        loyaltyPoints: 99,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  static List<LoyaltyTransaction> getDefaultLoyalty() {
    final now = DateTime.now();
    return [
      LoyaltyTransaction(
        id: 'lt-1',
        customerId: 'cust-1',
        orderId: 'ORD-092',
        points: 60,
        type: 'earned',
        description: 'Earned 60 pts on Dine-in Bill ₹1,200',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      LoyaltyTransaction(
        id: 'lt-2',
        customerId: 'cust-1',
        orderId: 'ORD-080',
        points: -50,
        type: 'redeemed',
        description: 'Redeemed 50 pts for ₹50 instant discount',
        timestamp: now.subtract(const Duration(days: 10)),
      ),
      LoyaltyTransaction(
        id: 'lt-3',
        customerId: 'cust-2',
        orderId: 'ORD-085',
        points: 75,
        type: 'earned',
        description: 'Earned 75 pts on Bill ₹1,500',
        timestamp: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  // ── Settings & Configuration Operations ──────────────────────────────────

  Future<RestaurantProfile> loadProfile() async {
    final prefs = _prefs;
    if (prefs == null) return const RestaurantProfile();
    final jsonStr = prefs.getString(_keyProfile);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return RestaurantProfile.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      } catch (_) {}
    }
    return const RestaurantProfile();
  }

  Future<void> saveProfile(RestaurantProfile profile) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  Future<TaxBillingConfig> loadTaxBilling() async {
    final prefs = _prefs;
    if (prefs == null) return const TaxBillingConfig();
    final jsonStr = prefs.getString(_keyTaxBilling);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return TaxBillingConfig.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      } catch (_) {}
    }
    return const TaxBillingConfig();
  }

  Future<void> saveTaxBilling(TaxBillingConfig config) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_keyTaxBilling, jsonEncode(config.toJson()));
  }

  Future<InvoiceReceiptConfig> loadInvoiceConfig() async {
    final prefs = _prefs;
    if (prefs == null) return const InvoiceReceiptConfig();
    final jsonStr = prefs.getString(_keyInvoiceConfig);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return InvoiceReceiptConfig.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      } catch (_) {}
    }
    return const InvoiceReceiptConfig();
  }

  Future<void> saveInvoiceConfig(InvoiceReceiptConfig config) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_keyInvoiceConfig, jsonEncode(config.toJson()));
  }

  Future<OrderPosConfig> loadOrderPosConfig() async {
    final prefs = _prefs;
    if (prefs == null) return const OrderPosConfig();
    final jsonStr = prefs.getString(_keyOrderPosConfig);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return OrderPosConfig.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      } catch (_) {}
    }
    return const OrderPosConfig();
  }

  Future<void> saveOrderPosConfig(OrderPosConfig config) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_keyOrderPosConfig, jsonEncode(config.toJson()));
  }

  Future<TableQrConfig> loadTableQrConfig() async {
    final prefs = _prefs;
    if (prefs == null) return const TableQrConfig();
    final jsonStr = prefs.getString(_keyTableQrConfig);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return TableQrConfig.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      } catch (_) {}
    }
    return const TableQrConfig();
  }

  Future<void> saveTableQrConfig(TableQrConfig config) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_keyTableQrConfig, jsonEncode(config.toJson()));
  }

  Future<String> loadThemeMode() async {
    final prefs = _prefs;
    if (prefs == null) return 'dark';
    return prefs.getString(_keyThemeMode) ?? 'dark';
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_keyThemeMode, mode);
  }

  Future<String> loadLanguage() async {
    final prefs = _prefs;
    if (prefs == null) return 'en';
    return prefs.getString(_keyLanguage) ?? 'en';
  }

  Future<void> saveLanguage(String code) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_keyLanguage, code);
  }

  // ── Database Export, Import & Reset ────────────────────────────────────────

  Future<String> exportFullDatabaseJson() async {
    final profile = await loadProfile();
    final taxBilling = await loadTaxBilling();
    final invoiceConfig = await loadInvoiceConfig();
    final orderPosConfig = await loadOrderPosConfig();
    final tableQrConfig = await loadTableQrConfig();
    final menu = await loadMenuItems();
    final categories = await loadCategories();
    final ingredients = await loadIngredients();
    final recipes = await loadRecipes();
    final staff = await loadStaff();
    final customers = await loadCustomers();

    final data = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profile.toJson(),
      'taxBilling': taxBilling.toJson(),
      'invoiceConfig': invoiceConfig.toJson(),
      'orderPosConfig': orderPosConfig.toJson(),
      'tableQrConfig': tableQrConfig.toJson(),
      'menu': menu.map((m) => m.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'recipes': recipes.map((r) => r.toJson()).toList(),
      'staff': staff.map((s) => s.toJson()).toList(),
      'customers': customers.map((c) => c.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<bool> importFullDatabaseJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      if (!data.containsKey('profile') || !data.containsKey('menu')) {
        return false;
      }

      if (data['profile'] != null) {
        await saveProfile(RestaurantProfile.fromJson(data['profile'] as Map<String, dynamic>));
      }
      if (data['taxBilling'] != null) {
        await saveTaxBilling(TaxBillingConfig.fromJson(data['taxBilling'] as Map<String, dynamic>));
      }
      if (data['invoiceConfig'] != null) {
        await saveInvoiceConfig(InvoiceReceiptConfig.fromJson(data['invoiceConfig'] as Map<String, dynamic>));
      }
      if (data['orderPosConfig'] != null) {
        await saveOrderPosConfig(OrderPosConfig.fromJson(data['orderPosConfig'] as Map<String, dynamic>));
      }
      if (data['tableQrConfig'] != null) {
        await saveTableQrConfig(TableQrConfig.fromJson(data['tableQrConfig'] as Map<String, dynamic>));
      }
      if (data['menu'] != null) {
        final list = (data['menu'] as List<dynamic>).map((m) => MenuItem.fromJson(m as Map<String, dynamic>)).toList();
        await saveMenuItems(list);
      }
      if (data['categories'] != null) {
        final list = (data['categories'] as List<dynamic>).map((c) => MenuCategory.fromJson(c as Map<String, dynamic>)).toList();
        await saveCategories(list);
      }
      if (data['staff'] != null) {
        final list = (data['staff'] as List<dynamic>).map((s) => StaffMember.fromJson(s as Map<String, dynamic>)).toList();
        await saveStaff(list);
      }
      if (data['customers'] != null) {
        final list = (data['customers'] as List<dynamic>).map((c) => CustomerRecord.fromJson(c as Map<String, dynamic>)).toList();
        await saveCustomers(list);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> resetDatabaseToDefaults() async {
    await saveProfile(const RestaurantProfile());
    await saveTaxBilling(const TaxBillingConfig());
    await saveInvoiceConfig(const InvoiceReceiptConfig());
    await saveOrderPosConfig(const OrderPosConfig());
    await saveTableQrConfig(const TableQrConfig());
    await saveCategories(getDefaultCategories());
    await saveMenuItems(getDefaultMenuItems());
    await saveIngredients(getDefaultIngredients());
    await saveRecipes(getDefaultRecipes());
    await saveStaff(getDefaultStaff());
    await saveAttendance(getDefaultAttendance());
    await saveCustomers(getDefaultCustomers());
    await saveLoyalty(getDefaultLoyalty());
    await saveThemeMode('dark');
    await saveLanguage('en');
  }
}
