// Anabhay Ventures — Menu & Category Management Screen

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Starters',
    'Main Course',
    'Breads',
    'Biryani',
    'Desserts',
    'Beverages',
  ];

  final List<Map<String, dynamic>> _dishes = [
    {'id': 'd1', 'name': 'Saffron Dum Biryani', 'category': 'Biryani', 'price': 540.0, 'isVeg': false, 'isAvailable': true, 'prepTime': 25},
    {'id': 'd2', 'name': 'Murgh Malai Tikka', 'category': 'Starters', 'price': 460.0, 'isVeg': false, 'isAvailable': true, 'prepTime': 15},
    {'id': 'd3', 'name': 'Paneer Tikka Angara', 'category': 'Starters', 'price': 390.0, 'isVeg': true, 'isAvailable': true, 'prepTime': 12},
    {'id': 'd4', 'name': 'Dal Makhani Reserve', 'category': 'Main Course', 'price': 380.0, 'isVeg': true, 'isAvailable': true, 'prepTime': 10},
    {'id': 'd5', 'name': 'Butter Chicken Royale', 'category': 'Main Course', 'price': 520.0, 'isVeg': false, 'isAvailable': true, 'prepTime': 18},
    {'id': 'd6', 'name': 'Butter Garlic Naan', 'category': 'Breads', 'price': 110.0, 'isVeg': true, 'isAvailable': true, 'prepTime': 5},
    {'id': 'd7', 'name': 'Gulab Jamun Flambé', 'category': 'Desserts', 'price': 220.0, 'isVeg': true, 'isAvailable': false, 'prepTime': 8},
  ];

  void _showAddDishDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String category = 'Starters';
    bool isVeg = true;

    AppDialog.show(
      context: context,
      title: 'Add New Food Item',
      subtitle: 'Add a new dish to the restaurant menu catalog',
      content: StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(label: 'Item Name', hintText: 'e.g. Tandoori Pomfret', controller: nameCtrl),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Price (₹)',
                      hintText: '450',
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dietary Type', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Veg'),
                              selected: isVeg,
                              onSelected: (val) => setDialogState(() => isVeg = true),
                              selectedColor: AppColors.successGreen.withValues(alpha: 0.2),
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              label: const Text('Non-Veg'),
                              selected: !isVeg,
                              onSelected: (val) => setDialogState(() => isVeg = false),
                              selectedColor: AppColors.errorRed.withValues(alpha: 0.2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      confirmLabel: 'Add Dish',
      onConfirm: () {
        if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
          setState(() {
            _dishes.add({
              'id': 'd${_dishes.length + 1}',
              'name': nameCtrl.text,
              'category': category,
              'price': double.tryParse(priceCtrl.text) ?? 200.0,
              'isVeg': isVeg,
              'isAvailable': true,
              'prepTime': 15,
            });
          });
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDishes = _dishes.where((d) {
      final matchesCategory = _selectedCategory == 'All' || d['category'] == _selectedCategory;
      final matchesSearch = d['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Menu & Categories', style: AppTypography.headlineLarge),
                      const SizedBox(height: 2),
                      Text('Digital menu catalog • Pricing & availability', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                AppButton(
                  label: 'Add New Item',
                  icon: Icons.add,
                  onPressed: _showAddDishDialog,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Search and Category Tabs
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat == _selectedCategory;
                        return Material(
                          color: isSelected ? AppColors.champagneGold : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              alignment: Alignment.center,
                              child: Text(
                                cat,
                                style: AppTypography.labelSmall.copyWith(
                                  color: isSelected ? AppColors.matteBlack : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 260,
                  child: AppTextField(
                    hintText: 'Search dishes...',
                    prefixIcon: Icons.search,
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),

            // Dishes Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: ListView.separated(
                  itemCount: filteredDishes.length,
                  separatorBuilder: (_, __) => const Divider(color: AppColors.borderSubtle, height: 1),
                  itemBuilder: (context, index) {
                    final dish = filteredDishes[index];
                    final isVeg = dish['isVeg'] as bool;
                    final isAvailable = dish['isAvailable'] as bool;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
                      child: Row(
                        children: [
                          // Veg / Non-Veg Indicator
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              border: Border.all(color: isVeg ? AppColors.successGreen : AppColors.errorRed, width: 1.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Center(
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isVeg ? AppColors.successGreen : AppColors.errorRed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dish['name'] as String, style: AppTypography.titleMedium),
                                Text('Prep time: ~${dish['prepTime']} min', style: AppTypography.bodySmall),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(dish['category'] as String, style: AppTypography.bodyMedium),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('₹${(dish['price'] as num).toStringAsFixed(0)}', style: AppTypography.currencyMedium),
                          ),
                          // Stock Toggle Switch
                          Row(
                            children: [
                              Text(isAvailable ? 'In Stock' : 'Out of Stock', style: AppTypography.labelSmall),
                              const SizedBox(width: 8),
                              Switch(
                                value: isAvailable,
                                activeColor: AppColors.champagneGold,
                                onChanged: (val) {
                                  setState(() {
                                    dish['isAvailable'] = val;
                                  });
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
        ),
      ),
    );
  }
}
