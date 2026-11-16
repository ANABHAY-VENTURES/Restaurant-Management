// Anabhay Ventures — Phase 4 Menu & Inventory Management Tests
// Unit & Integration Tests: Menu CRUD, Recipes, Automatic Deduction, Suppliers & Purchases

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_management/features/pos/domain/models/order_models.dart';
import 'package:restaurant_management/features/pos/presentation/providers/pos_providers.dart';
import 'package:restaurant_management/features/inventory/domain/models/inventory_models.dart';
import 'package:restaurant_management/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:restaurant_management/features/menu/presentation/screens/menu_management_screen.dart';
import 'package:restaurant_management/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:restaurant_management/features/customer_qr/presentation/screens/customer_qr_menu_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Phase 4: Menu & Category Management CRUD', () {
    test('Menu item addition, edit, toggle availability, and deletion', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialItems = container.read(menuItemsProvider);
      final count = initialItems.length;

      // 1. Add Food Item
      const newDish = MenuItem(
        id: 'm_test_pomfret',
        name: 'Tandoori Pomfret Royale',
        category: 'Starters',
        basePrice: 580.0,
        foodCost: 210.0,
        dietaryType: DietaryType.nonVeg,
        isVeg: false,
        prepTimeMinutes: 20,
        description: 'Whole silver pomfret marinated in yellow mustard and smoked in tandoor.',
      );

      container.read(menuItemsProvider.notifier).addMenuItem(newDish);
      var items = container.read(menuItemsProvider);
      expect(items.length, count + 1);
      expect(items.any((i) => i.id == 'm_test_pomfret'), isTrue);

      // 2. Edit price and margin
      container.read(menuItemsProvider.notifier).updatePrice('m_test_pomfret', 620.0);
      items = container.read(menuItemsProvider);
      final updated = items.firstWhere((i) => i.id == 'm_test_pomfret');
      expect(updated.basePrice, 620.0);
      expect(updated.foodCost, 210.0);
      expect(updated.grossProfit, 410.0);
      expect(updated.profitMarginPercent, closeTo(66.12, 0.1));

      // 3. Toggle availability (86ed)
      expect(updated.isAvailable, isTrue);
      container.read(menuItemsProvider.notifier).toggleAvailability('m_test_pomfret');
      expect(container.read(menuItemsProvider).firstWhere((i) => i.id == 'm_test_pomfret').isAvailable, isFalse);

      // 4. Delete item
      container.read(menuItemsProvider.notifier).deleteMenuItem('m_test_pomfret');
      expect(container.read(menuItemsProvider).any((i) => i.id == 'm_test_pomfret'), isFalse);
    });

    test('Category creation, reordering, and toggle active status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialCats = container.read(categoriesProvider);
      final count = initialCats.length;

      // Create Category
      const newCat = MenuCategory(
        id: 'cat_tandoor',
        name: 'Tandoori Grills',
        description: 'Live clay oven specialties',
      );
      container.read(categoriesProvider.notifier).addCategory(newCat);
      expect(container.read(categoriesProvider).length, count + 1);

      // Toggle active
      container.read(categoriesProvider.notifier).toggleCategoryActive('cat_tandoor');
      expect(container.read(categoriesProvider).firstWhere((c) => c.id == 'cat_tandoor').isActive, isFalse);

      // Delete
      container.read(categoriesProvider.notifier).deleteCategory('cat_tandoor');
      expect(container.read(categoriesProvider).any((c) => c.id == 'cat_tandoor'), isFalse);
    });
  });

  group('Phase 4: Recipe & Inventory Costing Engine', () {
    test('Calculates recipe total food cost and gross margin correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final recipes = container.read(recipesProvider);
      final biryaniRecipe = recipes.firstWhere((r) => r.menuItemId == 'm1');

      // Rice: 250g @ 140/kg = 35.0
      // Chicken: 200g @ 280/kg = 56.0
      // Onion: 50g @ 35/kg = 1.75
      // Oil: 20ml @ 135/L = 2.70
      // Spices: 15g @ 650/kg = 9.75
      // Butter: 20g @ 540/kg = 10.80
      // Total estimated cost = 35 + 56 + 1.75 + 2.70 + 9.75 + 10.80 = 116.0
      expect(biryaniRecipe.totalEstimatedFoodCost, closeTo(116.0, 0.1));
      expect(biryaniRecipe.costPerServing, closeTo(116.0, 0.1));
    });

    test('Unit conversions work accurately (g to kg, ml to litre)', () {
      const gIng = RecipeIngredient(
        ingredientId: 'ing_1',
        ingredientName: 'Cardamom',
        quantity: 500,
        unit: InventoryUnit.g,
        unitCost: 1000.0, // ₹1000 per kg
      );
      // 500g = 0.5kg * 1000 = ₹500
      expect(gIng.estimatedCost, 500.0);

      const mlIng = RecipeIngredient(
        ingredientId: 'ing_2',
        ingredientName: 'Rose Water',
        quantity: 250,
        unit: InventoryUnit.ml,
        unitCost: 200.0, // ₹200 per L
      );
      // 250ml = 0.25L * 200 = ₹50
      expect(mlIng.estimatedCost, 50.0);
    });
  });

  group('Phase 4: Automatic Inventory Deduction & Reversals', () {
    test('Placing POS order automatically deducts recipe ingredients and prevents duplicate deduction', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Check initial Basmati Rice stock
      final initialIngredients = container.read(ingredientsProvider);
      final initialRice = initialIngredients.firstWhere((i) => i.id == 'ing_rice');
      final initialStock = initialRice.currentStock; // e.g. 48.0 kg

      // Check Chicken Dum Biryani (m1)
      final biryani = container.read(menuItemsProvider).firstWhere((m) => m.id == 'm1');

      // Place POS order: 2 Chicken Dum Biryanis (each requires 250g = 0.25kg rice -> total 0.5kg)
      container.read(posCartProvider.notifier).setSelectedTable('Table 05');
      container.read(posCartProvider.notifier).addItem(biryani);
      container.read(posCartProvider.notifier).addItem(biryani);

      final order = container.read(posCartProvider.notifier).placeOrder();
      expect(order.hasInventoryDeducted, isTrue);

      // Verify Basmati Rice stock has decreased by exactly 0.50 kg
      final updatedIngredients = container.read(ingredientsProvider);
      final updatedRice = updatedIngredients.firstWhere((i) => i.id == 'ing_rice');
      expect(updatedRice.currentStock, closeTo(initialStock - 0.50, 0.001));

      // Verify stock movement ledger has recorded the deduction
      final movements = container.read(stockMovementsProvider);
      final deductionMovement = movements.firstWhere((m) => m.referenceId == order.id && m.ingredientId == 'ing_rice');
      expect(deductionMovement.type, StockMovementType.orderDeduction);
      expect(deductionMovement.quantity, 0.50);

      // CRITICAL: Changing KDS status (Preparing -> Ready -> Served) must NOT deduct stock again!
      container.read(ordersProvider.notifier).updateOrderStatus(order.id, OrderStatus.preparing);
      container.read(ordersProvider.notifier).updateOrderStatus(order.id, OrderStatus.ready);
      container.read(ordersProvider.notifier).updateOrderStatus(order.id, OrderStatus.served);

      final afterKdsRice = container.read(ingredientsProvider).firstWhere((i) => i.id == 'ing_rice');
      expect(afterKdsRice.currentStock, closeTo(initialStock - 0.50, 0.001));

      // Order Cancellation Reversal: cancelling order returns 0.50 kg to stock
      container.read(ordersProvider.notifier).cancelOrder(order.id);

      final afterCancelRice = container.read(ingredientsProvider).firstWhere((i) => i.id == 'ing_rice');
      expect(afterCancelRice.currentStock, closeTo(initialStock, 0.001));

      final reversalMovement = container.read(stockMovementsProvider).firstWhere(
            (m) => m.referenceId == order.id && m.type == StockMovementType.orderReversal,
          );
      expect(reversalMovement.quantity, 0.50);
    });
  });

  group('Phase 4: Supplier Procurement & Stock Receipt', () {
    test('Marking purchase order as received replenishes raw material stock', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialWheat = container.read(ingredientsProvider).firstWhere((i) => i.id == 'ing_maida');
      final prevStock = initialWheat.currentStock;

      // Create purchase order for 25 kg Maida
      final po = PurchaseOrder(
        id: 'PO-TEST-001',
        supplierId: 'sup_1',
        supplierName: 'Agro Royal Grains & Spices',
        orderDate: DateTime.now(),
        isReceived: false,
        totalAmount: 1125.0,
        items: const [
          PurchaseItem(
            ingredientId: 'ing_maida',
            ingredientName: 'Refined Wheat Maida (Grade A)',
            quantity: 25.0,
            unit: InventoryUnit.kg,
            unitPrice: 45.0,
          ),
        ],
      );

      container.read(purchasesProvider.notifier).createPurchaseOrder(po);
      expect(container.read(purchasesProvider).any((p) => p.id == 'PO-TEST-001'), isTrue);

      // Stock should not change before receipt
      expect(container.read(ingredientsProvider).firstWhere((i) => i.id == 'ing_maida').currentStock, prevStock);

      // Mark Received
      container.read(purchasesProvider.notifier).markAsReceived('PO-TEST-001');

      // Verify stock has increased by 25 kg
      final replenishedWheat = container.read(ingredientsProvider).firstWhere((i) => i.id == 'ing_maida');
      expect(replenishedWheat.currentStock, closeTo(prevStock + 25.0, 0.001));

      // Verify purchase order is now marked received
      final updatedPo = container.read(purchasesProvider).firstWhere((p) => p.id == 'PO-TEST-001');
      expect(updatedPo.isReceived, isTrue);
      expect(updatedPo.paymentStatus, 'Paid');
    });

    test('Wastage logging reduces stock and records movement audit', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialButter = container.read(ingredientsProvider).firstWhere((i) => i.id == 'ing_butter');
      final prevStock = initialButter.currentStock;

      container.read(ingredientsProvider.notifier).recordWastage('ing_butter', 2.0, 'Dropped / contaminated container');

      final afterWastage = container.read(ingredientsProvider).firstWhere((i) => i.id == 'ing_butter');
      expect(afterWastage.currentStock, closeTo(prevStock - 2.0, 0.001));

      final wastageMov = container.read(stockMovementsProvider).firstWhere(
            (m) => m.ingredientId == 'ing_butter' && m.type == StockMovementType.wastage,
          );
      expect(wastageMov.quantity, 2.0);
      expect(wastageMov.reason, 'Dropped / contaminated container');
    });
  });

  group('Phase 4: UI Widget Screen Tests', () {
    testWidgets('MenuManagementScreen renders food items catalog, metrics and tabs', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: MenuManagementScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Menu & Catalog Management'), findsOneWidget);
      expect(find.text('Add Food Item'), findsOneWidget);
      expect(find.text('Add Category'), findsOneWidget);
      expect(find.text('Food Items Catalog'), findsOneWidget);
      expect(find.text('Categories Management'), findsOneWidget);
      expect(find.text('Chicken Dum Biryani'), findsWidgets);
    });

    testWidgets('InventoryScreen renders stock ledger, recipes and procurement tabs', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: InventoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Inventory & Stock Management'), findsOneWidget);
      expect(find.text('New Ingredient'), findsOneWidget);
      expect(find.text('Stock Ledger & Ingredients'), findsOneWidget);
      expect(find.text('Recipe Management'), findsOneWidget);
      expect(find.text('Suppliers & Purchases'), findsOneWidget);
      expect(find.textContaining('Basmati Biryani Rice'), findsWidgets);
    });

    testWidgets('CustomerQRMenuScreen renders digital menu linked to catalog', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: CustomerQRMenuScreen(tableNumber: 'Table 05')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('The Royal Saffron'), findsOneWidget);
      expect(find.textContaining('Table 05'), findsOneWidget);
      expect(find.text('Veg Only'), findsOneWidget);
      expect(find.text('Chicken Dum Biryani'), findsWidgets);
    });
  });
}
