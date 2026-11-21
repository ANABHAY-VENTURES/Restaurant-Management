// Anabhay Ventures — Premium Inventory Management Screen
// Phase 4: Stock Ledger, Recipe Management, Automatic Deduction, Suppliers & Purchases

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_management/core/theme/theme.dart';
import 'package:restaurant_management/shared/widgets/widgets.dart';
import 'package:restaurant_management/features/pos/presentation/providers/pos_providers.dart';
import 'package:restaurant_management/features/inventory/domain/models/inventory_models.dart';
import 'package:restaurant_management/features/inventory/presentation/providers/inventory_providers.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _ingredientCategories = [
    'All',
    'Grains',
    'Meat & Poultry',
    'Dairy',
    'Produce',
    'Spices',
    'Oils & Fats',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Modals & Dialogs ──────────────────────────────────────────────────────

  void _showAddStockDialog(Ingredient ingredient) {
    final qtyCtrl = TextEditingController();
    final reasonCtrl = TextEditingController(text: 'Routine Kitchen Restock');

    AppDialog.show(
      context: context,
      title: 'Inward Stock: ${ingredient.name}',
      subtitle: 'Current: ${ingredient.currentStock} ${ingredient.unit.symbol} (Min: ${ingredient.minStockLevel})',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'Quantity to Add (${ingredient.unit.symbol})',
            hintText: 'e.g. 10',
            controller: qtyCtrl,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.add_circle_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Inward Reason / PO Ref',
            hintText: 'e.g. Received from Supplier / Direct Purchase',
            controller: reasonCtrl,
            prefixIcon: Icons.notes_rounded,
          ),
        ],
      ),
      confirmLabel: 'Add to Stock',
      onConfirm: () {
        final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
        if (qty <= 0) return;

        ref.read(ingredientsProvider.notifier).adjustStock(
              ingredientId: ingredient.id,
              deltaQuantity: qty,
              type: StockMovementType.manualAdjustment,
              reason: reasonCtrl.text.trim(),
            );

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $qty ${ingredient.unit.symbol} of ${ingredient.name}!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      },
    );
  }

  void _showRecordWastageDialog(Ingredient ingredient) {
    final qtyCtrl = TextEditingController();
    final reasonCtrl = TextEditingController(text: 'Spoilage / Expiry in cold storage');

    AppDialog.show(
      context: context,
      title: 'Record Wastage: ${ingredient.name}',
      subtitle: 'Log kitchen loss or damaged raw material',
      isDestructive: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'Wastage Quantity (${ingredient.unit.symbol})',
            hintText: 'e.g. 1.5',
            controller: qtyCtrl,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.remove_circle_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Wastage Reason',
            hintText: 'e.g. Cold storage temperature fluctuation / burnt during prep',
            controller: reasonCtrl,
            prefixIcon: Icons.report_problem_outlined,
          ),
        ],
      ),
      confirmLabel: 'Log Wastage',
      onConfirm: () {
        final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
        if (qty <= 0) return;

        ref.read(ingredientsProvider.notifier).recordWastage(
              ingredient.id,
              qty,
              reasonCtrl.text.trim(),
            );

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged $qty ${ingredient.unit.symbol} wastage for ${ingredient.name}'),
            backgroundColor: AppColors.warningAmber,
          ),
        );
      },
    );
  }

  void _showAddEditIngredientDialog([Ingredient? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final skuCtrl = TextEditingController(text: existing?.sku ?? 'SKU-${DateTime.now().millisecondsSinceEpoch % 1000}');
    final stockCtrl = TextEditingController(text: existing != null ? existing.currentStock.toString() : '');
    final minCtrl = TextEditingController(text: existing != null ? existing.minStockLevel.toString() : '');
    final costCtrl = TextEditingController(text: existing != null ? existing.unitCost.toString() : '');

    String category = existing?.category ?? 'Grains';
    InventoryUnit unit = existing?.unit ?? InventoryUnit.kg;

    showDialog(
      context: context,
      barrierColor: AppColors.matteBlack.withValues(alpha: 0.85),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existing == null ? 'Add New Raw Ingredient' : 'Edit Ingredient',
                      style: AppTypography.headlineMedium.copyWith(color: AppColors.champagneGold),
                    ),
                    const Divider(color: AppColors.borderSubtle, height: 16),
                    AppTextField(label: 'Ingredient Name', hintText: 'e.g. Kashmiri Saffron', controller: nameCtrl),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(child: AppTextField(label: 'SKU Code', hintText: 'SKU-001', controller: skuCtrl)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Unit of Measurement', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<InventoryUnit>(
                                    value: unit,
                                    isExpanded: true,
                                    dropdownColor: AppColors.surfaceElevated,
                                    items: InventoryUnit.values.map((u) => DropdownMenuItem(value: u, child: Text('${u.label} (${u.symbol})'))).toList(),
                                    onChanged: (val) {
                                      if (val != null) setDialogState(() => unit = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(child: AppTextField(label: 'Current Stock', hintText: '25', controller: stockCtrl, keyboardType: TextInputType.number)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: AppTextField(label: 'Min Stock Level', hintText: '10', controller: minCtrl, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(child: AppTextField(label: 'Unit Cost (₹)', hintText: '140', controller: costCtrl, keyboardType: TextInputType.number)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _ingredientCategories.contains(category) && category != 'All' ? category : 'Grains',
                                    isExpanded: true,
                                    dropdownColor: AppColors.surfaceElevated,
                                    items: _ingredientCategories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                    onChanged: (val) {
                                      if (val != null) setDialogState(() => category = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                        const SizedBox(width: AppSpacing.sm),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.champagneGold, foregroundColor: AppColors.matteBlack),
                          onPressed: () {
                            if (nameCtrl.text.trim().isEmpty) return;
                            final stock = double.tryParse(stockCtrl.text.trim()) ?? 0.0;
                            final min = double.tryParse(minCtrl.text.trim()) ?? 10.0;
                            final cost = double.tryParse(costCtrl.text.trim()) ?? 50.0;

                            if (existing == null) {
                              final newIng = Ingredient(
                                id: 'ing_${DateTime.now().millisecondsSinceEpoch}',
                                name: nameCtrl.text.trim(),
                                sku: skuCtrl.text.trim(),
                                category: category,
                                unit: unit,
                                currentStock: stock,
                                minStockLevel: min,
                                unitCost: cost,
                              );
                              ref.read(ingredientsProvider.notifier).addIngredient(newIng);
                            } else {
                              final updated = existing.copyWith(
                                name: nameCtrl.text.trim(),
                                sku: skuCtrl.text.trim(),
                                category: category,
                                unit: unit,
                                currentStock: stock,
                                minStockLevel: min,
                                unitCost: cost,
                              );
                              ref.read(ingredientsProvider.notifier).updateIngredient(updated);
                            }
                            Navigator.of(ctx).pop();
                          },
                          child: Text(existing == null ? 'Save Ingredient' : 'Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateRecipeDialog() {
    final menuItems = ref.read(menuItemsProvider);
    final ingredients = ref.read(ingredientsProvider);

    String selectedMenuItemId = menuItems.first.id;
    final List<RecipeIngredient> recipeIngredients = [];
    final qtyCtrl = TextEditingController();
    String selectedIngId = ingredients.first.id;

    showDialog(
      context: context,
      barrierColor: AppColors.matteBlack.withValues(alpha: 0.85),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final chosenMenuItem = menuItems.firstWhere((m) => m.id == selectedMenuItemId);
          final chosenIng = ingredients.firstWhere((i) => i.id == selectedIngId);
          final totalCost = recipeIngredients.fold(0.0, (sum, i) => sum + i.estimatedCost);

          return Dialog(
            backgroundColor: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create Dish Recipe', style: AppTypography.headlineMedium.copyWith(color: AppColors.champagneGold)),
                    const SizedBox(height: 2),
                    Text('Map menu item to raw inventory ingredients for automatic deduction', style: AppTypography.bodySmall),
                    const Divider(color: AppColors.borderSubtle, height: 16),

                    // Menu Item Selector
                    Text('Select Menu Dish', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMenuItemId,
                          isExpanded: true,
                          dropdownColor: AppColors.surfaceElevated,
                          items: menuItems.map((m) => DropdownMenuItem(value: m.id, child: Text('${m.name} (₹${m.basePrice.toStringAsFixed(0)})'))).toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedMenuItemId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Add Ingredient to Recipe Row
                    Text('Add Required Ingredient', style: AppTypography.labelMedium.copyWith(color: AppColors.champagneGold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedIngId,
                                isExpanded: true,
                                dropdownColor: AppColors.surfaceElevated,
                                items: ingredients.map((i) => DropdownMenuItem(value: i.id, child: Text('${i.name} (${i.unit.symbol})'))).toList(),
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => selectedIngId = val);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: AppTextField(
                            hintText: 'Qty (${chosenIng.unit.symbol})',
                            controller: qtyCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceElevated, foregroundColor: AppColors.champagneGold),
                          onPressed: () {
                            final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
                            if (qty > 0) {
                              setDialogState(() {
                                recipeIngredients.add(
                                  RecipeIngredient(
                                    ingredientId: chosenIng.id,
                                    ingredientName: chosenIng.name,
                                    quantity: qty,
                                    unit: chosenIng.unit,
                                    unitCost: chosenIng.unitCost,
                                  ),
                                );
                                qtyCtrl.clear();
                              });
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Recipe Ingredients List
                    Expanded(
                      child: recipeIngredients.isEmpty
                          ? const Center(child: Text('No ingredients added to this recipe yet.', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)))
                          : ListView.separated(
                              itemCount: recipeIngredients.length,
                              separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                              itemBuilder: (context, index) {
                                final ri = recipeIngredients[index];
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(ri.ingredientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmIvory)),
                                  subtitle: Text('${ri.quantity} ${ri.unit.symbol} • Est. Cost: ₹${ri.estimatedCost.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.errorRed),
                                    onPressed: () => setDialogState(() => recipeIngredients.removeAt(index)),
                                  ),
                                );
                              },
                            ),
                    ),

                    const Divider(color: AppColors.borderSubtle, height: 16),

                    // Cost Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estimated Food Cost: ₹${totalCost.toStringAsFixed(1)}', style: AppTypography.titleMedium.copyWith(color: AppColors.champagneGold)),
                            Text('Selling Price: ₹${chosenMenuItem.basePrice.toStringAsFixed(0)} • Margin: ${chosenMenuItem.basePrice > 0 ? (((chosenMenuItem.basePrice - totalCost) / chosenMenuItem.basePrice) * 100).toStringAsFixed(0) : 0}%',
                                style: const TextStyle(fontSize: 11, color: AppColors.successGreen)),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.champagneGold, foregroundColor: AppColors.matteBlack),
                          onPressed: () {
                            if (recipeIngredients.isEmpty) return;
                            final newRecipe = Recipe(
                              id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
                              menuItemId: chosenMenuItem.id,
                              menuItemName: chosenMenuItem.name,
                              ingredients: recipeIngredients,
                            );
                            ref.read(recipesProvider.notifier).saveRecipe(newRecipe);

                            // Update foodCost on the MenuItem itself
                            final updatedMenuItem = chosenMenuItem.copyWith(foodCost: totalCost);
                            ref.read(menuItemsProvider.notifier).updateMenuItem(updatedMenuItem);

                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Recipe saved for ${chosenMenuItem.name}!'), backgroundColor: AppColors.successGreen),
                            );
                          },
                          child: const Text('Save Recipe'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreatePurchaseDialog() {
    final suppliers = ref.read(suppliersProvider);
    final ingredients = ref.read(ingredientsProvider);

    String selectedSupId = suppliers.first.id;
    final List<PurchaseItem> purchaseItems = [];
    String selectedIngId = ingredients.first.id;
    final qtyCtrl = TextEditingController();
    final rateCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierColor: AppColors.matteBlack.withValues(alpha: 0.85),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final chosenSup = suppliers.firstWhere((s) => s.id == selectedSupId);
          final chosenIng = ingredients.firstWhere((i) => i.id == selectedIngId);
          final totalAmount = purchaseItems.fold(0.0, (sum, i) => sum + i.totalPrice);

          return Dialog(
            backgroundColor: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580, maxHeight: 650),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Purchase Entry (Stock In)', style: AppTypography.headlineMedium.copyWith(color: AppColors.champagneGold)),
                    const SizedBox(height: 2),
                    Text('Order replenishment from registered suppliers', style: AppTypography.bodySmall),
                    const Divider(color: AppColors.borderSubtle, height: 16),

                    Text('Vendor / Supplier', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSupId,
                          isExpanded: true,
                          dropdownColor: AppColors.surfaceElevated,
                          items: suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.category})'))).toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedSupId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Text('Add Raw Material Line Item', style: AppTypography.labelMedium.copyWith(color: AppColors.champagneGold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedIngId,
                                isExpanded: true,
                                dropdownColor: AppColors.surfaceElevated,
                                items: ingredients.map((i) => DropdownMenuItem(value: i.id, child: Text('${i.name} (${i.unit.symbol})'))).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() {
                                      selectedIngId = val;
                                      rateCtrl.text = ingredients.firstWhere((ing) => ing.id == val).unitCost.toStringAsFixed(0);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: AppTextField(hintText: 'Qty', controller: qtyCtrl, keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: AppTextField(hintText: '₹ Rate', controller: rateCtrl, keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceElevated, foregroundColor: AppColors.champagneGold),
                          onPressed: () {
                            final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
                            final rate = double.tryParse(rateCtrl.text.trim()) ?? chosenIng.unitCost;
                            if (qty > 0) {
                              setDialogState(() {
                                purchaseItems.add(
                                  PurchaseItem(
                                    ingredientId: chosenIng.id,
                                    ingredientName: chosenIng.name,
                                    quantity: qty,
                                    unit: chosenIng.unit,
                                    unitPrice: rate,
                                  ),
                                );
                                qtyCtrl.clear();
                              });
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Expanded(
                      child: purchaseItems.isEmpty
                          ? const Center(child: Text('No line items added yet.', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)))
                          : ListView.separated(
                              itemCount: purchaseItems.length,
                              separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                              itemBuilder: (context, index) {
                                final pi = purchaseItems[index];
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(pi.ingredientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmIvory)),
                                  subtitle: Text('${pi.quantity} ${pi.unit.symbol} @ ₹${pi.unitPrice.toStringAsFixed(0)} = ₹${pi.totalPrice.toStringAsFixed(0)}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.errorRed),
                                    onPressed: () => setDialogState(() => purchaseItems.removeAt(index)),
                                  ),
                                );
                              },
                            ),
                    ),

                    const Divider(color: AppColors.borderSubtle, height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Consignment: ₹${totalAmount.toStringAsFixed(2)}', style: AppTypography.titleLarge.copyWith(color: AppColors.champagneGold)),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.champagneGold, foregroundColor: AppColors.matteBlack),
                          onPressed: () {
                            if (purchaseItems.isEmpty) return;
                            final po = PurchaseOrder(
                              id: 'PO-2026-${DateTime.now().millisecondsSinceEpoch % 10000}',
                              supplierId: chosenSup.id,
                              supplierName: chosenSup.name,
                              orderDate: DateTime.now(),
                              isReceived: false,
                              items: purchaseItems,
                              totalAmount: totalAmount,
                              paymentStatus: 'Pending',
                            );
                            ref.read(purchasesProvider.notifier).createPurchaseOrder(po);
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Purchase order ${po.id} created!'), backgroundColor: AppColors.successGreen),
                            );
                          },
                          icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                          label: const Text('Create PO'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Main Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(inventoryMetricsProvider);
    final allIngredients = ref.watch(ingredientsProvider);
    final allRecipes = ref.watch(recipesProvider);
    final allSuppliers = ref.watch(suppliersProvider);
    final allPurchases = ref.watch(purchasesProvider);
    final allMovements = ref.watch(stockMovementsProvider);

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 750;
                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inventory & Stock', style: AppTypography.headlineMedium.copyWith(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text('Raw materials, recipe depletion & procurement', style: AppTypography.bodySmall),
                      const SizedBox(height: AppSpacing.sm),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.champagneGold,
                                side: const BorderSide(color: AppColors.champagneGold),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              onPressed: _showCreateRecipeDialog,
                              icon: const Icon(Icons.menu_book_rounded, size: 14),
                              label: const Text('Add Recipe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.champagneGold,
                                side: const BorderSide(color: AppColors.champagneGold),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              onPressed: _showCreatePurchaseDialog,
                              icon: const Icon(Icons.receipt_long_rounded, size: 14),
                              label: const Text('Purchase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.champagneGold,
                                foregroundColor: AppColors.matteBlack,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: () => _showAddEditIngredientDialog(),
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                              label: const Text('New Ingredient', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Inventory & Stock Management', style: AppTypography.headlineLarge, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text('Real-time raw material ledger, automated recipe depletion & supplier procurement', style: AppTypography.bodySmall, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.champagneGold,
                            side: const BorderSide(color: AppColors.champagneGold),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          onPressed: _showCreateRecipeDialog,
                          icon: const Icon(Icons.menu_book_rounded, size: 16),
                          label: const Text('Add Recipe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.champagneGold,
                            side: const BorderSide(color: AppColors.champagneGold),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          onPressed: _showCreatePurchaseDialog,
                          icon: const Icon(Icons.receipt_long_rounded, size: 16),
                          label: const Text('Record Purchase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.champagneGold,
                            foregroundColor: AppColors.matteBlack,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: () => _showAddEditIngredientDialog(),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                          label: const Text('New Ingredient', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Top Metrics Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _metricTile('Total Raw Materials', '${metrics.totalIngredients}', Icons.inventory_2_rounded, AppColors.champagneGold),
                  const SizedBox(width: AppSpacing.sm),
                  _metricTile('Total Stock Value', '₹${metrics.totalStockValue.toStringAsFixed(0)}', Icons.account_balance_wallet_rounded, AppColors.successGreen),
                  const SizedBox(width: AppSpacing.sm),
                  _metricTile('Low Stock Alerts', '${metrics.lowStockCount}', Icons.warning_amber_rounded, metrics.lowStockCount > 0 ? AppColors.warningAmber : AppColors.mutedGrey),
                  const SizedBox(width: AppSpacing.sm),
                  _metricTile('Out of Stock (86ed)', '${metrics.outOfStockCount}', Icons.cancel_outlined, metrics.outOfStockCount > 0 ? AppColors.errorRed : AppColors.mutedGrey),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Tab Bar
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.champagneGold,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                labelColor: AppColors.matteBlack,
                unselectedLabelColor: AppColors.textSecondary,
                isScrollable: true,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.inventory_rounded, size: 16), text: 'Stock Ledger & Ingredients'),
                  Tab(icon: Icon(Icons.menu_book_rounded, size: 16), text: 'Recipe Management'),
                  Tab(icon: Icon(Icons.local_shipping_rounded, size: 16), text: 'Suppliers & Purchases'),
                  Tab(icon: Icon(Icons.history_rounded, size: 16), text: 'Movement Audit & Reports'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.base),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStockLedgerTab(allIngredients),
                  _buildRecipesTab(allRecipes),
                  _buildPurchasesTab(allPurchases, allSuppliers),
                  _buildMovementsTab(allMovements),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(String label, String value, IconData icon, Color color) {
    return Container(
      width: 175,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ],
        ),
      );
    }

  // ── Tab 1: Stock Ledger & Ingredients ─────────────────────────────────────

  Widget _buildStockLedgerTab(List<Ingredient> ingredients) {
    final filtered = ingredients.where((i) {
      final matchesCat = _selectedCategory == 'All' || i.category == _selectedCategory;
      final matchesSearch = i.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Column(
      children: [
        // Category Filters & Search
        Row(
          children: [
            Expanded(
              child: AppTextField(
                hintText: 'Search raw materials by name, SKU or category...',
                prefixIcon: Icons.search_rounded,
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: AppColors.surfaceElevated,
                  style: const TextStyle(fontSize: 12, color: AppColors.warmIvory),
                  items: _ingredientCategories.map((c) => DropdownMenuItem(value: c, child: Text('Category: $c'))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Ingredients Table
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
              itemBuilder: (context, index) {
                final ing = filtered[index];
                final progress = (ing.currentStock / (ing.minStockLevel * 2)).clamp(0.0, 1.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 10),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 700;
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ing.isOutOfStock ? AppColors.errorRed : (ing.isLowStock ? AppColors.warningAmber : AppColors.successGreen),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ing.name, style: AppTypography.titleMedium.copyWith(fontSize: 14), overflow: TextOverflow.ellipsis),
                                      Text('${ing.sku} • ${ing.category}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                    ],
                                  ),
                                ),
                                StatusBadge(label: ing.statusLabel, variant: ing.statusBadgeVariant),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add_box_outlined, size: 18, color: AppColors.successGreen),
                                      tooltip: 'Add Stock',
                                      onPressed: () => _showAddStockDialog(ing),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: AppColors.warningAmber),
                                      tooltip: 'Log Wastage',
                                      onPressed: () => _showRecordWastageDialog(ing),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.champagneGold),
                                      tooltip: 'Edit Ingredient',
                                      onPressed: () => _showAddEditIngredientDialog(ing),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('${ing.currentStock} ${ing.unit.symbol}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmIvory)),
                                          Text(' (Min: ${ing.minStockLevel})', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 4,
                                          backgroundColor: AppColors.surfaceElevated,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            ing.isOutOfStock ? AppColors.errorRed : (ing.isLowStock ? AppColors.warningAmber : AppColors.successGreen),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('₹${ing.unitCost.toStringAsFixed(0)} / ${ing.unit.symbol}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    Text('Value: ₹${ing.totalValue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: AppColors.champagneGold, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          // Status Icon Dot
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ing.isOutOfStock ? AppColors.errorRed : (ing.isLowStock ? AppColors.warningAmber : AppColors.successGreen),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),

                          // Name & SKU
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ing.name, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                                Text('${ing.sku} • ${ing.category}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                              ],
                            ),
                          ),

                          // Current Stock & Progress against Minimum
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('${ing.currentStock} ${ing.unit.symbol}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmIvory)),
                                    Text(' (Min: ${ing.minStockLevel})', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 4,
                                    backgroundColor: AppColors.surfaceElevated,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ing.isOutOfStock ? AppColors.errorRed : (ing.isLowStock ? AppColors.warningAmber : AppColors.successGreen),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Unit Cost & Stock Value
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('₹${ing.unitCost.toStringAsFixed(0)} / ${ing.unit.symbol}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                Text('Value: ₹${ing.totalValue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: AppColors.champagneGold, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),

                          // Status Badge
                          StatusBadge(label: ing.statusLabel, variant: ing.statusBadgeVariant),
                          const SizedBox(width: AppSpacing.md),

                          // Action Buttons
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_box_outlined, size: 18, color: AppColors.successGreen),
                                tooltip: 'Add Stock',
                                onPressed: () => _showAddStockDialog(ing),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: AppColors.warningAmber),
                                tooltip: 'Log Wastage',
                                onPressed: () => _showRecordWastageDialog(ing),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.champagneGold),
                                tooltip: 'Edit Ingredient',
                                onPressed: () => _showAddEditIngredientDialog(ing),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Tab 2: Recipe Management ──────────────────────────────────────────────

  Widget _buildRecipesTab(List<Recipe> recipes) {
    if (recipes.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: Icons.menu_book_rounded,
          title: 'No Recipes Created',
          description: 'Map menu dishes to ingredients using "Add Recipe" above.',
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 440,
        mainAxisExtent: 260,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final r = recipes[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      r.menuItemName,
                      style: AppTypography.titleLarge.copyWith(color: AppColors.champagneGold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(4)),
                    child: Text('${r.servings} Serving', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(r.preparationNotes.isEmpty ? 'Traditional culinary formula' : r.preparationNotes,
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
              const Divider(color: AppColors.borderSubtle, height: 14),

              Expanded(
                child: ListView.separated(
                  itemCount: r.ingredients.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 3),
                  itemBuilder: (context, idx) {
                    final ing = r.ingredients[idx];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${ing.quantity} ${ing.unit.symbol} • ${ing.ingredientName}', style: const TextStyle(fontSize: 11, color: AppColors.warmIvory)),
                        Text('₹${ing.estimatedCost.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      ],
                    );
                  },
                ),
              ),

              const Divider(color: AppColors.borderSubtle, height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Food Cost', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      Text('₹${r.totalEstimatedFoodCost.toStringAsFixed(1)}', style: AppTypography.currencyMedium.copyWith(fontSize: 15)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.errorRed),
                    onPressed: () {
                      ref.read(recipesProvider.notifier).deleteRecipe(r.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Recipe for ${r.menuItemName} deleted.'), backgroundColor: AppColors.errorRed),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 3: Suppliers & Purchases ──────────────────────────────────────────

  Widget _buildPurchasesTab(List<PurchaseOrder> purchases, List<Supplier> suppliers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Procurement & Supplier Invoices (${purchases.length})', style: AppTypography.titleLarge),
            Text('Marking received automatically increases inventory raw material stock', style: AppTypography.bodySmall),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: purchases.isEmpty
              ? const Center(child: Text('No purchase orders placed yet.', style: TextStyle(color: AppColors.textTertiary)))
              : ListView.separated(
                  itemCount: purchases.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final po = purchases[index];
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: po.isReceived ? AppColors.borderSubtle : AppColors.champagneGold.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isNarrow = constraints.maxWidth < 650;
                              if (isNarrow) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${po.id} • ${po.supplierName}', style: AppTypography.titleMedium.copyWith(color: AppColors.champagneGold), overflow: TextOverflow.ellipsis),
                                    Text('Ordered: ${po.orderDate.toString().substring(0, 10)} • Payment: ${po.paymentStatus}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('₹${po.totalAmount.toStringAsFixed(0)}', style: AppTypography.currencyMedium),
                                        if (po.isReceived)
                                          const StatusBadge(label: 'Stock Received', variant: BadgeVariant.success)
                                        else
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.successGreen,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            ),
                                            onPressed: () {
                                              ref.read(purchasesProvider.notifier).markAsReceived(po.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Purchase ${po.id} received! Raw material stock replenished.'),
                                                  backgroundColor: AppColors.successGreen,
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.check_circle_outline, size: 14),
                                            label: const Text('Mark Received', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${po.id} • ${po.supplierName}', style: AppTypography.titleMedium.copyWith(color: AppColors.champagneGold)),
                                      Text('Ordered: ${po.orderDate.toString().substring(0, 10)} • Payment: ${po.paymentStatus}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('₹${po.totalAmount.toStringAsFixed(0)}', style: AppTypography.currencyMedium),
                                      const SizedBox(width: AppSpacing.md),
                                      if (po.isReceived)
                                        const StatusBadge(label: 'Stock Received', variant: BadgeVariant.success)
                                      else
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.successGreen,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          onPressed: () {
                                            ref.read(purchasesProvider.notifier).markAsReceived(po.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Purchase ${po.id} received! Raw material stock replenished.'),
                                                backgroundColor: AppColors.successGreen,
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.check_circle_outline, size: 14),
                                          label: const Text('Mark Received', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            po.items.map((i) => '${i.quantity} ${i.unit.symbol} ${i.ingredientName} (@ ₹${i.unitPrice})').join(' • '),
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Tab 4: Stock Movement Audit & Reports ──────────────────────────────────

  Widget _buildMovementsTab(List<StockMovement> movements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text('Stock Movement Audit Ledger (${movements.length} Transactions)', style: AppTypography.titleLarge),
            Text('Traceability for automatic POS deductions, restocks and wastage', style: AppTypography.bodySmall),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: ListView.separated(
              itemCount: movements.length,
              separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
              itemBuilder: (context, index) {
                final m = movements[index];
                final isDeduction = m.type == StockMovementType.orderDeduction ||
                    m.type == StockMovementType.wastage ||
                    m.type == StockMovementType.damaged;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 10),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 650;
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: isDeduction ? AppColors.errorRed.withValues(alpha: 0.15) : AppColors.successGreen.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isDeduction ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                    size: 14,
                                    color: isDeduction ? AppColors.errorRed : AppColors.successGreen,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(m.ingredientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmIvory), overflow: TextOverflow.ellipsis),
                                ),
                                Text(
                                  '${isDeduction ? "-" : "+"}${m.quantity.toStringAsFixed(2)} ${m.unit.symbol}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDeduction ? AppColors.errorRed : AppColors.successGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${m.type.label} • ${m.reason}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                Text(
                                  '${m.previousStock.toStringAsFixed(1)} ➔ ${m.newStock.toStringAsFixed(1)} (${m.timestamp.toString().substring(11, 16)})',
                                  style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDeduction ? AppColors.errorRed.withValues(alpha: 0.15) : AppColors.successGreen.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDeduction ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              size: 16,
                              color: isDeduction ? AppColors.errorRed : AppColors.successGreen,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.ingredientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmIvory)),
                                Text('${m.type.label} • ${m.reason}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${isDeduction ? "-" : "+"}${m.quantity.toStringAsFixed(2)} ${m.unit.symbol}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDeduction ? AppColors.errorRed : AppColors.successGreen,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${m.previousStock.toStringAsFixed(1)} ➔ ${m.newStock.toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                            ),
                          ),
                          Text(
                            m.timestamp.toString().substring(11, 16),
                            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
