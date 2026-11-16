// Anabhay Ventures — Menu & Category Management Screen
// Phase 4: Full Interactive Menu CRUD, Variants, Add-Ons, Categories & Live Sync

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_management/core/theme/theme.dart';
import 'package:restaurant_management/shared/widgets/widgets.dart';
import 'package:restaurant_management/features/pos/domain/models/order_models.dart';
import 'package:restaurant_management/features/pos/presentation/providers/pos_providers.dart';
import 'package:restaurant_management/features/inventory/domain/models/inventory_models.dart';
import 'package:restaurant_management/features/inventory/presentation/providers/inventory_providers.dart';

class MenuManagementScreen extends ConsumerStatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  ConsumerState<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends ConsumerState<MenuManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _dietaryFilter = 'All'; // 'All', 'Veg', 'Non-Veg'
  String _sortBy = 'Name'; // 'Name', 'Price Low-High', 'Price High-Low', 'Margin'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddEditItemDialog([MenuItem? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final priceCtrl = TextEditingController(text: existing != null ? existing.basePrice.toStringAsFixed(0) : '');
    final costCtrl = TextEditingController(text: existing != null ? existing.foodCost.toStringAsFixed(0) : '');
    final prepCtrl = TextEditingController(text: existing != null ? existing.prepTimeMinutes.toString() : '15');

    final categories = ref.read(categoriesProvider).where((c) => c.name != 'All').toList();
    String category = existing?.category ?? (categories.isNotEmpty ? categories.first.name : 'Main Course');
    DietaryType dietaryType = existing?.dietaryType ?? DietaryType.veg;
    bool isAvailable = existing?.isAvailable ?? true;
    bool isFeatured = existing?.isFeatured ?? false;

    // Variants and Addons lists
    final List<ItemVariant> variants = List.from(existing?.variants ?? []);
    final List<ItemAddOn> addOns = List.from(existing?.addOns ?? []);

    final variantNameCtrl = TextEditingController();
    final variantPriceCtrl = TextEditingController();
    final addOnNameCtrl = TextEditingController();
    final addOnPriceCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierColor: AppColors.matteBlack.withValues(alpha: 0.85),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existing == null ? 'Add New Food Item' : 'Edit Food Item',
                          style: AppTypography.headlineMedium.copyWith(color: AppColors.champagneGold),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.borderSubtle, height: 16),

                    // Scrollable form
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Basic Info
                            AppTextField(label: 'Dish / Item Name', hintText: 'e.g. Tandoori Pomfret Royale', controller: nameCtrl),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              label: 'Description',
                              hintText: 'Rich flavors, whole spices and traditional clay oven preparation...',
                              controller: descCtrl,
                              maxLines: 2,
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Category & Dietary Type
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Category', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                          border: Border.all(color: AppColors.borderSubtle),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: categories.any((c) => c.name == category) ? category : categories.first.name,
                                            isExpanded: true,
                                            dropdownColor: AppColors.surfaceElevated,
                                            style: AppTypography.bodyMedium,
                                            items: categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                                            onChanged: (val) {
                                              if (val != null) setDialogState(() => category = val);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Dietary Classification', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          ChoiceChip(
                                            label: const Text('Veg'),
                                            selected: dietaryType == DietaryType.veg,
                                            selectedColor: AppColors.successGreen.withValues(alpha: 0.25),
                                            labelStyle: TextStyle(
                                              color: dietaryType == DietaryType.veg ? AppColors.successGreen : AppColors.textSecondary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            onSelected: (val) => setDialogState(() => dietaryType = DietaryType.veg),
                                          ),
                                          const SizedBox(width: 4),
                                          ChoiceChip(
                                            label: const Text('Non-Veg'),
                                            selected: dietaryType == DietaryType.nonVeg,
                                            selectedColor: AppColors.errorRed.withValues(alpha: 0.25),
                                            labelStyle: TextStyle(
                                              color: dietaryType == DietaryType.nonVeg ? AppColors.errorRed : AppColors.textSecondary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            onSelected: (val) => setDialogState(() => dietaryType = DietaryType.nonVeg),
                                          ),
                                          const SizedBox(width: 4),
                                          ChoiceChip(
                                            label: const Text('Egg'),
                                            selected: dietaryType == DietaryType.egg,
                                            selectedColor: AppColors.warningAmber.withValues(alpha: 0.25),
                                            labelStyle: TextStyle(
                                              color: dietaryType == DietaryType.egg ? AppColors.warningAmber : AppColors.textSecondary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            onSelected: (val) => setDialogState(() => dietaryType = DietaryType.egg),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Pricing & Food Cost & Prep Time
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Selling Price (₹)',
                                    hintText: '480',
                                    controller: priceCtrl,
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.currency_rupee,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: AppTextField(
                                    label: 'Estimated Food Cost (₹)',
                                    hintText: '160',
                                    controller: costCtrl,
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.receipt_long,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: AppTextField(
                                    label: 'Prep Time (Mins)',
                                    hintText: '20',
                                    controller: prepCtrl,
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.timer_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Switches: Available & Featured
                            Row(
                              children: [
                                Expanded(
                                  child: SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Currently Available', style: TextStyle(fontSize: 13, color: AppColors.warmIvory)),
                                    subtitle: const Text('Visible in POS & QR Menu', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                    value: isAvailable,
                                    activeColor: AppColors.champagneGold,
                                    onChanged: (val) => setDialogState(() => isAvailable = val),
                                  ),
                                ),
                                Expanded(
                                  child: SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Featured / Chef Special', style: TextStyle(fontSize: 13, color: AppColors.warmIvory)),
                                    subtitle: const Text('Highlighted at top of QR Menu', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                    value: isFeatured,
                                    activeColor: AppColors.champagneGold,
                                    onChanged: (val) => setDialogState(() => isFeatured = val),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Portions & Variants Section
                            Text('Portions & Pricing Variants (Optional)', style: AppTypography.titleMedium.copyWith(color: AppColors.champagneGold)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(flex: 3, child: AppTextField(hintText: 'Variant (e.g. Half, Large)', controller: variantNameCtrl)),
                                const SizedBox(width: 8),
                                Expanded(flex: 2, child: AppTextField(hintText: '+ Price (₹)', controller: variantPriceCtrl, keyboardType: TextInputType.number)),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.surfaceElevated,
                                    foregroundColor: AppColors.champagneGold,
                                  ),
                                  onPressed: () {
                                    if (variantNameCtrl.text.trim().isNotEmpty) {
                                      setDialogState(() {
                                        variants.add(
                                          ItemVariant(
                                            name: variantNameCtrl.text.trim(),
                                            additionalPrice: double.tryParse(variantPriceCtrl.text.trim()) ?? 0.0,
                                          ),
                                        );
                                        variantNameCtrl.clear();
                                        variantPriceCtrl.clear();
                                      });
                                    }
                                  },
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                            if (variants.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                children: variants.map((v) {
                                  return Chip(
                                    backgroundColor: AppColors.surfaceElevated,
                                    label: Text('${v.name} (+₹${v.additionalPrice.toStringAsFixed(0)})', style: const TextStyle(fontSize: 11, color: AppColors.warmIvory)),
                                    onDeleted: () => setDialogState(() => variants.remove(v)),
                                    deleteIconColor: AppColors.textTertiary,
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),

                            // Add-Ons Section
                            Text('Add-Ons & Extras (Optional)', style: AppTypography.titleMedium.copyWith(color: AppColors.champagneGold)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(flex: 3, child: AppTextField(hintText: 'Add-On (e.g. Extra Cheese)', controller: addOnNameCtrl)),
                                const SizedBox(width: 8),
                                Expanded(flex: 2, child: AppTextField(hintText: 'Price (₹)', controller: addOnPriceCtrl, keyboardType: TextInputType.number)),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.surfaceElevated,
                                    foregroundColor: AppColors.champagneGold,
                                  ),
                                  onPressed: () {
                                    if (addOnNameCtrl.text.trim().isNotEmpty) {
                                      setDialogState(() {
                                        addOns.add(
                                          ItemAddOn(
                                            id: 'addon_${DateTime.now().millisecondsSinceEpoch}',
                                            name: addOnNameCtrl.text.trim(),
                                            price: double.tryParse(addOnPriceCtrl.text.trim()) ?? 0.0,
                                          ),
                                        );
                                        addOnNameCtrl.clear();
                                        addOnPriceCtrl.clear();
                                      });
                                    }
                                  },
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                            if (addOns.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                children: addOns.map((a) {
                                  return Chip(
                                    backgroundColor: AppColors.surfaceElevated,
                                    label: Text('${a.name} (+₹${a.price.toStringAsFixed(0)})', style: const TextStyle(fontSize: 11, color: AppColors.warmIvory)),
                                    onDeleted: () => setDialogState(() => addOns.remove(a)),
                                    deleteIconColor: AppColors.textTertiary,
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const Divider(color: AppColors.borderSubtle, height: 16),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.champagneGold,
                            foregroundColor: AppColors.matteBlack,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: () {
                            if (nameCtrl.text.trim().isEmpty) return;

                            final price = double.tryParse(priceCtrl.text.trim()) ?? 100.0;
                            final cost = double.tryParse(costCtrl.text.trim()) ?? 0.0;
                            final prep = int.tryParse(prepCtrl.text.trim()) ?? 15;

                            if (existing == null) {
                              final newItem = MenuItem(
                                id: 'm_${DateTime.now().millisecondsSinceEpoch}',
                                name: nameCtrl.text.trim(),
                                category: category,
                                basePrice: price,
                                foodCost: cost,
                                dietaryType: dietaryType,
                                isVeg: dietaryType == DietaryType.veg,
                                description: descCtrl.text.trim(),
                                prepTimeMinutes: prep,
                                isAvailable: isAvailable,
                                isFeatured: isFeatured,
                                variants: variants,
                                addOns: addOns,
                              );
                              ref.read(menuItemsProvider.notifier).addMenuItem(newItem);
                            } else {
                              final updated = existing.copyWith(
                                name: nameCtrl.text.trim(),
                                category: category,
                                basePrice: price,
                                foodCost: cost,
                                dietaryType: dietaryType,
                                isVeg: dietaryType == DietaryType.veg,
                                description: descCtrl.text.trim(),
                                prepTimeMinutes: prep,
                                isAvailable: isAvailable,
                                isFeatured: isFeatured,
                                variants: variants,
                                addOns: addOns,
                              );
                              ref.read(menuItemsProvider.notifier).updateMenuItem(updated);
                            }

                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(existing == null ? 'Food item added to catalog!' : 'Item updated successfully!'),
                                backgroundColor: AppColors.successGreen,
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_rounded, size: 18),
                          label: Text(existing == null ? 'Save Dish' : 'Update Dish', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  void _showAddEditCategoryDialog([MenuCategory? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    AppDialog.show(
      context: context,
      title: existing == null ? 'Create Menu Category' : 'Edit Category',
      subtitle: 'Organize menu offerings by department',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(label: 'Category Name', hintText: 'e.g. Tandoori Starters', controller: nameCtrl),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Description', hintText: 'Clay oven delicacies and kebabs', controller: descCtrl),
        ],
      ),
      confirmLabel: existing == null ? 'Create' : 'Save Changes',
      onConfirm: () {
        if (nameCtrl.text.trim().isEmpty) return;
        if (existing == null) {
          final newCat = MenuCategory(
            id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
            name: nameCtrl.text.trim(),
            description: descCtrl.text.trim(),
          );
          ref.read(categoriesProvider.notifier).addCategory(newCat);
        } else {
          final updated = existing.copyWith(
            name: nameCtrl.text.trim(),
            description: descCtrl.text.trim(),
          );
          ref.read(categoriesProvider.notifier).updateCategory(updated);
        }
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category saved successfully!'), backgroundColor: AppColors.successGreen),
        );
      },
    );
  }

  void _confirmDeleteItem(MenuItem item) {
    AppDialog.show(
      context: context,
      title: 'Delete "${item.name}"?',
      subtitle: 'This will remove the item from POS and Customer Menu.',
      content: Text('Are you sure you want to permanently delete ${item.name}? This action cannot be undone.', style: AppTypography.bodyMedium),
      confirmLabel: 'Delete Item',
      isDestructive: true,
      onConfirm: () {
        Navigator.of(context).pop();
        ref.read(menuItemsProvider.notifier).deleteMenuItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} deleted from menu catalog'), backgroundColor: AppColors.errorRed),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(menuItemsProvider);
    final allCategories = ref.watch(categoriesProvider);

    // Metrics
    final totalItems = allItems.length;
    final activeItems = allItems.where((i) => i.isAvailable).length;
    final unavailableItems = allItems.where((i) => !i.isAvailable).length;
    final totalCategories = allCategories.where((c) => c.name != 'All').length;

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header & Action Buttons
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 700;
                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Menu & Catalog', style: AppTypography.headlineMedium.copyWith(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text('Dishes, portions, add-ons, pricing & categories', style: AppTypography.bodySmall),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.champagneGold,
                                side: const BorderSide(color: AppColors.champagneGold),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              onPressed: () => _showAddEditCategoryDialog(),
                              icon: const Icon(Icons.category_rounded, size: 14),
                              label: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.champagneGold,
                                foregroundColor: AppColors.matteBlack,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              onPressed: () => _showAddEditItemDialog(),
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                              label: const Text('Add Dish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
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
                        Text('Menu & Catalog Management', style: AppTypography.headlineLarge),
                        const SizedBox(height: 2),
                        Text('Manage food items, portions, add-ons, pricing & categories', style: AppTypography.bodySmall),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.champagneGold,
                            side: const BorderSide(color: AppColors.champagneGold),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          onPressed: () => _showAddEditCategoryDialog(),
                          icon: const Icon(Icons.category_rounded, size: 16),
                          label: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.champagneGold,
                            foregroundColor: AppColors.matteBlack,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: () => _showAddEditItemDialog(),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                          label: const Text('Add Food Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Top Metrics Bar
            _buildMetricsBar(totalItems, activeItems, unavailableItems, totalCategories),
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
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.restaurant_menu_rounded, size: 16), text: 'Food Items Catalog'),
                  Tab(icon: Icon(Icons.category_rounded, size: 16), text: 'Categories Management'),
                  Tab(icon: Icon(Icons.price_change_rounded, size: 16), text: 'Quick Price & Availability Editor'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.base),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFoodCatalogTab(allItems, allCategories),
                  _buildCategoriesTab(allCategories, allItems),
                  _buildQuickEditorTab(allItems),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsBar(int total, int active, int unavailable, int categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _metricTile('Total Dishes', '$total', Icons.restaurant_rounded, AppColors.champagneGold),
          const SizedBox(width: AppSpacing.sm),
          _metricTile('Active (Available)', '$active', Icons.check_circle_rounded, AppColors.successGreen),
          const SizedBox(width: AppSpacing.sm),
          _metricTile('Unavailable (86ed)', '$unavailable', Icons.do_not_disturb_on_rounded, AppColors.errorRed),
          const SizedBox(width: AppSpacing.sm),
          _metricTile('Categories', '$categories', Icons.category_rounded, AppColors.copper),
        ],
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

  // ── Tab 1: Food Items Catalog ─────────────────────────────────────────────

  Widget _buildFoodCatalogTab(List<MenuItem> allItems, List<MenuCategory> allCategories) {
    // Filter items
    var filtered = allItems.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDietary = _dietaryFilter == 'All' ||
          (_dietaryFilter == 'Veg' && item.dietaryType == DietaryType.veg) ||
          (_dietaryFilter == 'Non-Veg' && item.dietaryType == DietaryType.nonVeg);
      return matchesCategory && matchesSearch && matchesDietary;
    }).toList();

    // Sort
    if (_sortBy == 'Name') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortBy == 'Price Low-High') {
      filtered.sort((a, b) => a.basePrice.compareTo(b.basePrice));
    } else if (_sortBy == 'Price High-Low') {
      filtered.sort((a, b) => b.basePrice.compareTo(a.basePrice));
    } else if (_sortBy == 'Margin') {
      filtered.sort((a, b) => b.profitMarginPercent.compareTo(a.profitMarginPercent));
    }

    return Column(
      children: [
        // Filter and Search Toolbar
        Row(
          children: [
            Expanded(
              child: AppTextField(
                hintText: 'Search menu by name, category or ingredient...',
                prefixIcon: Icons.search_rounded,
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Dietary Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _dietaryFilter,
                  dropdownColor: AppColors.surfaceElevated,
                  style: const TextStyle(fontSize: 12, color: AppColors.warmIvory),
                  items: ['All', 'Veg', 'Non-Veg'].map((d) => DropdownMenuItem(value: d, child: Text('Dietary: $d'))).toList(),
                  onChanged: (val) => setState(() => _dietaryFilter = val!),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Sort Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortBy,
                  dropdownColor: AppColors.surfaceElevated,
                  style: const TextStyle(fontSize: 12, color: AppColors.warmIvory),
                  items: ['Name', 'Price Low-High', 'Price High-Low', 'Margin'].map((s) => DropdownMenuItem(value: s, child: Text('Sort: $s'))).toList(),
                  onChanged: (val) => setState(() => _sortBy = val!),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Categories Chips List
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: allCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) {
              final cat = allCategories[index];
              final isSelected = cat.name == _selectedCategory;
              return ChoiceChip(
                label: Text(cat.name),
                selected: isSelected,
                selectedColor: AppColors.champagneGold,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.matteBlack : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                ),
                onSelected: (val) => setState(() => _selectedCategory = cat.name),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Items Grid
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: AppEmptyState(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'No menu items match criteria',
                    description: 'Try resetting filters or click "Add Food Item" above.',
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 380,
                    mainAxisExtent: 195,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildFoodCard(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFoodCard(MenuItem item) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: item.isAvailable ? AppColors.borderSubtle : AppColors.errorRed.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Veg dot + Category + Status Switch
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  border: Border.all(color: item.dietaryType.color, width: 1.5),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: item.dietaryType.color, shape: BoxShape.circle),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(item.category, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              if (item.isFeatured) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.champagneGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('FEATURED', style: TextStyle(fontSize: 8, color: AppColors.champagneGold, fontWeight: FontWeight.bold)),
                ),
              ],
              const Spacer(),
              // Availability toggle switch
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: item.isAvailable,
                  activeThumbColor: AppColors.champagneGold,
                  onChanged: (val) {
                    ref.read(menuItemsProvider.notifier).toggleAvailability(item.id);
                  },
                ),
              ),
            ],
          ),

          // Title & Description
          Text(
            item.name,
            style: AppTypography.titleMedium.copyWith(
              color: item.isAvailable ? AppColors.textPrimary : AppColors.textTertiary,
              decoration: item.isAvailable ? null : TextDecoration.lineThrough,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            item.description.isEmpty ? 'Traditional chef preparation' : item.description,
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),
          const Divider(color: AppColors.borderSubtle, height: 10),

          // Pricing, Margin & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('₹${item.basePrice.toStringAsFixed(0)}', style: AppTypography.currencyMedium.copyWith(fontSize: 15)),
                      if (item.foodCost > 0) ...[
                        const SizedBox(width: 6),
                        Text('Cost: ₹${item.foodCost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      ],
                    ],
                  ),
                  if (item.foodCost > 0)
                    Text(
                      'Margin: ${item.profitMarginPercent.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 10, color: AppColors.successGreen, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.champagneGold),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => _showAddEditItemDialog(item),
                    tooltip: 'Edit Item',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.errorRed),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => _confirmDeleteItem(item),
                    tooltip: 'Delete Item',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Categories Management ──────────────────────────────────────────

  Widget _buildCategoriesTab(List<MenuCategory> categories, List<MenuItem> allItems) {
    final validCategories = categories.where((c) => c.name != 'All').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Menu Categories (${validCategories.length})', style: AppTypography.titleLarge),
            Text('Drag or toggle active status to update POS category filters', style: AppTypography.bodySmall),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: validCategories.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(categoriesProvider.notifier).reorderCategories(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final cat = validCategories[index];
              final itemCount = allItems.where((i) => i.category == cat.name).length;

              return Container(
                key: ValueKey(cat.id),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: cat.isActive ? AppColors.borderSubtle : AppColors.errorRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.drag_indicator_rounded, color: AppColors.textTertiary, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(8)),
                      child: Icon(cat.icon, size: 20, color: AppColors.champagneGold),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat.name, style: AppTypography.titleMedium),
                          Text(cat.description.isEmpty ? '$itemCount items linked' : '${cat.description} • $itemCount items',
                              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: cat.isActive,
                        activeThumbColor: AppColors.champagneGold,
                        onChanged: (val) {
                          ref.read(categoriesProvider.notifier).toggleCategoryActive(cat.id);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.champagneGold),
                      onPressed: () => _showAddEditCategoryDialog(cat),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.errorRed),
                      onPressed: () {
                        if (itemCount > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cannot delete "${cat.name}" because $itemCount dishes are assigned to it.'),
                              backgroundColor: AppColors.warningAmber,
                            ),
                          );
                          return;
                        }
                        ref.read(categoriesProvider.notifier).deleteCategory(cat.id);
                      },
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

  // ── Tab 3: Quick Price & Availability Editor ──────────────────────────────

  Widget _buildQuickEditorTab(List<MenuItem> allItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Quick Price & Rush Hour 86 Manager', style: AppTypography.titleLarge),
            Text('Changes immediately synchronize across POS, Kitchen and Customer QR Menu', style: AppTypography.bodySmall),
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
              itemCount: allItems.length,
              separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
              itemBuilder: (context, index) {
                final item = allItems[index];
                final priceCtrl = TextEditingController(text: item.basePrice.toStringAsFixed(0));

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.dietaryType.color,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                            Text(item.category, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                      // Editable Price field
                      SizedBox(
                        width: 110,
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 13, color: AppColors.warmIvory, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            prefixStyle: const TextStyle(color: AppColors.champagneGold, fontWeight: FontWeight.bold),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                          ),
                          onSubmitted: (val) {
                            final newP = double.tryParse(val);
                            if (newP != null && newP > 0) {
                              ref.read(menuItemsProvider.notifier).updatePrice(item.id, newP);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Updated price for ${item.name} to ₹${newP.toStringAsFixed(0)}'), backgroundColor: AppColors.successGreen),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      // Out of stock toggle
                      Row(
                        children: [
                          Text(
                            item.isAvailable ? 'In Stock' : '86ed / Out',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: item.isAvailable ? AppColors.successGreen : AppColors.errorRed,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Switch(
                            value: item.isAvailable,
                            activeThumbColor: AppColors.champagneGold,
                            onChanged: (val) {
                              ref.read(menuItemsProvider.notifier).toggleAvailability(item.id);
                            },
                          ),
                        ],
                      ),
                    ],
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
