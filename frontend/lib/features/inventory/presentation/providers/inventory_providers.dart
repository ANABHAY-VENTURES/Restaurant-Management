// Anabhay Ventures — Restaurant Inventory & Menu State Providers (Riverpod)
// Phase 4: Categories, Ingredients, Recipes, Stock Ledger, Suppliers & Purchases

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pos/data/restaurant_storage_repository.dart';
import '../../../pos/presentation/providers/pos_providers.dart';
import '../../domain/models/inventory_models.dart';

// ── Categories Provider ─────────────────────────────────────────────────────

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<MenuCategory>>((ref) {
  final repo = ref.watch(restaurantRepositoryProvider);
  return CategoriesNotifier(repo);
});

class CategoriesNotifier extends StateNotifier<List<MenuCategory>> {
  final RestaurantStorageRepository _repo;

  CategoriesNotifier(this._repo) : super(RestaurantStorageRepository.getDefaultCategories()) {
    _load();
  }

  Future<void> _load() async {
    final categories = await _repo.loadCategories();
    state = categories;
  }

  void addCategory(MenuCategory category) {
    state = [...state, category];
    _repo.saveCategories(state);
  }

  void updateCategory(MenuCategory updated) {
    state = [
      for (final cat in state)
        if (cat.id == updated.id) updated else cat,
    ];
    _repo.saveCategories(state);
  }

  void deleteCategory(String id) {
    state = state.where((cat) => cat.id != id).toList();
    _repo.saveCategories(state);
  }

  void toggleCategoryActive(String id) {
    state = [
      for (final cat in state)
        if (cat.id == id) cat.copyWith(isActive: !cat.isActive) else cat,
    ];
    _repo.saveCategories(state);
  }

  void reorderCategories(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final list = List<MenuCategory>.from(state);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    _repo.saveCategories(state);
  }
}

// ── Stock Movements Provider ────────────────────────────────────────────────

final stockMovementsProvider = StateNotifierProvider<StockMovementsNotifier, List<StockMovement>>((ref) {
  final repo = ref.watch(restaurantRepositoryProvider);
  return StockMovementsNotifier(repo);
});

class StockMovementsNotifier extends StateNotifier<List<StockMovement>> {
  final RestaurantStorageRepository _repo;

  StockMovementsNotifier(this._repo) : super(RestaurantStorageRepository.getDefaultStockMovements()) {
    _load();
  }

  Future<void> _load() async {
    final movements = await _repo.loadStockMovements();
    state = movements;
  }

  void recordMovement(StockMovement movement) {
    state = [movement, ...state];
    _repo.saveStockMovements(state);
  }
}

// ── Ingredients Provider ────────────────────────────────────────────────────

final ingredientsProvider = StateNotifierProvider<IngredientsNotifier, List<Ingredient>>((ref) {
  final repo = ref.watch(restaurantRepositoryProvider);
  return IngredientsNotifier(repo, ref);
});

class IngredientsNotifier extends StateNotifier<List<Ingredient>> {
  final RestaurantStorageRepository _repo;
  final Ref _ref;

  IngredientsNotifier(this._repo, this._ref) : super(RestaurantStorageRepository.getDefaultIngredients()) {
    _load();
  }

  Future<void> _load() async {
    final ingredients = await _repo.loadIngredients();
    state = ingredients;
  }

  void addIngredient(Ingredient ingredient) {
    state = [...state, ingredient];
    _repo.saveIngredients(state);
  }

  void updateIngredient(Ingredient updated) {
    state = [
      for (final ing in state)
        if (ing.id == updated.id) updated else ing,
    ];
    _repo.saveIngredients(state);
  }

  void deleteIngredient(String id) {
    state = state.where((ing) => ing.id != id).toList();
    _repo.saveIngredients(state);
  }

  /// Adjust stock (e.g. manual count, restock, or reduction)
  void adjustStock({
    required String ingredientId,
    required double deltaQuantity,
    required StockMovementType type,
    required String reason,
    String? referenceId,
  }) {
    final index = state.indexWhere((i) => i.id == ingredientId);
    if (index < 0) return;

    final current = state[index];
    final prevStock = current.currentStock;
    final newStock = (prevStock + deltaQuantity).clamp(0.0, double.infinity);

    final updated = current.copyWith(currentStock: newStock);
    final newList = List<Ingredient>.from(state);
    newList[index] = updated;
    state = newList;
    _repo.saveIngredients(state);

    // Record movement in audit ledger
    final movement = StockMovement(
      id: 'mov_${DateTime.now().millisecondsSinceEpoch}',
      ingredientId: current.id,
      ingredientName: current.name,
      type: type,
      quantity: deltaQuantity.abs(),
      unit: current.unit,
      previousStock: prevStock,
      newStock: newStock,
      reason: reason,
      referenceId: referenceId,
      timestamp: DateTime.now(),
    );

    _ref.read(stockMovementsProvider.notifier).recordMovement(movement);
  }

  /// Record kitchen wastage
  void recordWastage(String ingredientId, double quantity, String reason) {
    adjustStock(
      ingredientId: ingredientId,
      deltaQuantity: -quantity,
      type: StockMovementType.wastage,
      reason: reason.isEmpty ? 'Kitchen spoilage / wastage' : reason,
    );
  }

  /// Record damaged stock
  void recordDamaged(String ingredientId, double quantity, String reason) {
    adjustStock(
      ingredientId: ingredientId,
      deltaQuantity: -quantity,
      type: StockMovementType.damaged,
      reason: reason.isEmpty ? 'Damaged in transit / prep' : reason,
    );
  }
}

// ── Recipes Provider ────────────────────────────────────────────────────────

final recipesProvider = StateNotifierProvider<RecipesNotifier, List<Recipe>>((ref) {
  final repo = ref.watch(restaurantRepositoryProvider);
  return RecipesNotifier(repo);
});

class RecipesNotifier extends StateNotifier<List<Recipe>> {
  final RestaurantStorageRepository _repo;

  RecipesNotifier(this._repo) : super(RestaurantStorageRepository.getDefaultRecipes()) {
    _load();
  }

  Future<void> _load() async {
    final recipes = await _repo.loadRecipes();
    state = recipes;
  }

  void saveRecipe(Recipe recipe) {
    final index = state.indexWhere((r) => r.menuItemId == recipe.menuItemId);
    if (index >= 0) {
      final list = List<Recipe>.from(state);
      list[index] = recipe;
      state = list;
    } else {
      state = [...state, recipe];
    }
    _repo.saveRecipes(state);
  }

  void deleteRecipe(String recipeId) {
    state = state.where((r) => r.id != recipeId).toList();
    _repo.saveRecipes(state);
  }

  Recipe? getRecipeForMenuItem(String menuItemId) {
    try {
      return state.firstWhere((r) => r.menuItemId == menuItemId);
    } catch (_) {
      return null;
    }
  }
}

// ── Suppliers Provider ──────────────────────────────────────────────────────

final suppliersProvider = StateNotifierProvider<SuppliersNotifier, List<Supplier>>((ref) {
  final repo = ref.watch(restaurantRepositoryProvider);
  return SuppliersNotifier(repo);
});

class SuppliersNotifier extends StateNotifier<List<Supplier>> {
  final RestaurantStorageRepository _repo;

  SuppliersNotifier(this._repo) : super(RestaurantStorageRepository.getDefaultSuppliers()) {
    _load();
  }

  Future<void> _load() async {
    final suppliers = await _repo.loadSuppliers();
    state = suppliers;
  }

  void addSupplier(Supplier supplier) {
    state = [...state, supplier];
    _repo.saveSuppliers(state);
  }

  void updateSupplier(Supplier updated) {
    state = [
      for (final s in state)
        if (s.id == updated.id) updated else s,
    ];
    _repo.saveSuppliers(state);
  }

  void deleteSupplier(String id) {
    state = state.where((s) => s.id != id).toList();
    _repo.saveSuppliers(state);
  }
}

// ── Purchases Provider ──────────────────────────────────────────────────────

final purchasesProvider = StateNotifierProvider<PurchasesNotifier, List<PurchaseOrder>>((ref) {
  final repo = ref.watch(restaurantRepositoryProvider);
  return PurchasesNotifier(repo, ref);
});

class PurchasesNotifier extends StateNotifier<List<PurchaseOrder>> {
  final RestaurantStorageRepository _repo;
  final Ref _ref;

  PurchasesNotifier(this._repo, this._ref) : super(RestaurantStorageRepository.getDefaultPurchases()) {
    _load();
  }

  Future<void> _load() async {
    final purchases = await _repo.loadPurchases();
    state = purchases;
  }

  void createPurchaseOrder(PurchaseOrder order) {
    state = [order, ...state];
    _repo.savePurchases(state);
  }

  /// Mark purchase as received and automatically replenish ingredient stock!
  void markAsReceived(String purchaseOrderId) {
    final index = state.indexWhere((p) => p.id == purchaseOrderId);
    if (index < 0) return;

    final purchase = state[index];
    if (purchase.isReceived) return; // Prevent duplicate stock receipt

    final updated = purchase.copyWith(
      isReceived: true,
      receivedDate: DateTime.now(),
      paymentStatus: 'Paid',
    );

    final list = List<PurchaseOrder>.from(state);
    list[index] = updated;
    state = list;
    _repo.savePurchases(state);

    // Replenish stock for each received purchase item!
    for (final item in purchase.items) {
      _ref.read(ingredientsProvider.notifier).adjustStock(
            ingredientId: item.ingredientId,
            deltaQuantity: item.quantity,
            type: StockMovementType.purchase,
            reason: 'Consignment received from ${purchase.supplierName}',
            referenceId: purchase.id,
          );
    }
  }
}

// ── Inventory Dashboard Metrics Provider ────────────────────────────────────

class InventoryMetrics {
  final int totalIngredients;
  final double totalStockValue;
  final int lowStockCount;
  final int outOfStockCount;
  final List<Ingredient> lowStockItems;
  final List<StockMovement> recentMovements;

  const InventoryMetrics({
    required this.totalIngredients,
    required this.totalStockValue,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.lowStockItems,
    required this.recentMovements,
  });
}

final inventoryMetricsProvider = Provider<InventoryMetrics>((ref) {
  final ingredients = ref.watch(ingredientsProvider);
  final movements = ref.watch(stockMovementsProvider);

  final totalValue = ingredients.fold(0.0, (sum, i) => sum + i.totalValue);
  final lowStock = ingredients.where((i) => i.isLowStock).toList();
  final outOfStock = ingredients.where((i) => i.isOutOfStock).toList();

  return InventoryMetrics(
    totalIngredients: ingredients.length,
    totalStockValue: totalValue,
    lowStockCount: lowStock.length,
    outOfStockCount: outOfStock.length,
    lowStockItems: [...outOfStock, ...lowStock],
    recentMovements: movements.take(15).toList(),
  );
});
