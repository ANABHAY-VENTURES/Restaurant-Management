// Anabhay Ventures — Inventory & Stock Management Screen

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<Map<String, dynamic>> _stockItems = [
    {'name': 'Basmati Biryani Rice', 'category': 'Grains', 'current': 42.0, 'min': 50.0, 'unit': 'kg', 'cost': 120.0},
    {'name': 'Kashmiri Saffron (Grade A)', 'category': 'Spices', 'current': 15.0, 'min': 50.0, 'unit': 'grams', 'cost': 350.0},
    {'name': 'Amul Desi Ghee', 'category': 'Dairy', 'current': 18.0, 'min': 20.0, 'unit': 'litres', 'cost': 620.0},
    {'name': 'Fresh Malai Paneer', 'category': 'Dairy', 'current': 24.0, 'min': 15.0, 'unit': 'kg', 'cost': 380.0},
    {'name': 'Boneless Chicken Breast', 'category': 'Meat', 'current': 35.0, 'min': 20.0, 'unit': 'kg', 'cost': 260.0},
    {'name': 'Whole Black Urad Lentils', 'category': 'Pulses', 'current': 28.0, 'min': 25.0, 'unit': 'kg', 'cost': 140.0},
    {'name': 'Amul Fresh Cooking Cream', 'category': 'Dairy', 'current': 8.0, 'min': 15.0, 'unit': 'packs', 'cost': 95.0},
  ];

  void _showRecordStockDialog() {
    final itemCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final supplierCtrl = TextEditingController();

    AppDialog.show(
      context: context,
      title: 'Record Stock Inward / Purchase',
      subtitle: 'Add ingredient replenishment to the stock ledger',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(label: 'Item Name', hintText: 'e.g. Basmati Rice', controller: itemCtrl),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: AppTextField(label: 'Quantity Added', hintText: '25', controller: qtyCtrl, keyboardType: TextInputType.number)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: AppTextField(label: 'Supplier / Vendor', hintText: 'Agro Farms Ltd', controller: supplierCtrl)),
            ],
          ),
        ],
      ),
      confirmLabel: 'Save to Ledger',
      onConfirm: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock inward recorded into source-of-truth ledger!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lowStockCount = _stockItems.where((i) => (i['current'] as double) < (i['min'] as double)).length;

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
                      Text('Inventory & Raw Materials', style: AppTypography.headlineLarge),
                      const SizedBox(height: 2),
                      Text('Real-time ingredient levels • Recipe-based depletion', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                AppButton(
                  label: 'Record Stock In',
                  icon: Icons.add_shopping_cart,
                  onPressed: _showRecordStockDialog,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Low Stock Alert Banner
            if (lowStockCount > 0)
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.warningAmber),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Low Stock Warning: $lowStockCount raw materials have fallen below minimum safety stock levels.',
                        style: AppTypography.labelMedium.copyWith(color: AppColors.warningAmber),
                      ),
                    ),
                  ],
                ),
              ),

            // Stock Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: ListView.separated(
                  itemCount: _stockItems.length,
                  separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                  itemBuilder: (context, index) {
                    final item = _stockItems[index];
                    final current = (item['current'] as num).toDouble();
                    final min = (item['min'] as num).toDouble();
                    final unit = item['unit'] as String;
                    final isLow = current < min;
                    final isCritical = current < min * 0.5;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'] as String, style: AppTypography.titleMedium),
                                Text('Category: ${item['category']}', style: AppTypography.bodySmall),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${current.toStringAsFixed(1)} $unit',
                              style: AppTypography.currencyMedium.copyWith(
                                color: isLow ? AppColors.warningAmber : AppColors.warmIvory,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('Min: $min $unit', style: AppTypography.bodySmall),
                          ),
                          StatusBadge(
                            label: isCritical ? 'Critical Low' : (isLow ? 'Low Stock' : 'Optimal'),
                            variant: isCritical
                                ? BadgeVariant.error
                                : (isLow ? BadgeVariant.warning : BadgeVariant.success),
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
