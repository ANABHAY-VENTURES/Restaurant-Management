// Anabhay Ventures — Food Item Customization Sheet (Variants & Add-Ons)
// Phase 3: Premium POS Experience

import 'package:flutter/material.dart';
import 'package:restaurant_management/core/theme/theme.dart';
import 'package:restaurant_management/shared/widgets/widgets.dart';
import 'package:restaurant_management/features/pos/domain/models/order_models.dart';

class ItemCustomizationSheet extends StatefulWidget {
  final MenuItem item;
  final void Function({
    required String? variantName,
    required double additionalVariantPrice,
    required List<String> addOns,
    required double addOnsTotal,
    required String? specialInstruction,
  }) onConfirm;

  const ItemCustomizationSheet({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required MenuItem item,
    required void Function({
      required String? variantName,
      required double additionalVariantPrice,
      required List<String> addOns,
      required double addOnsTotal,
      required String? specialInstruction,
    }) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ItemCustomizationSheet(item: item, onConfirm: onConfirm),
    );
  }

  @override
  State<ItemCustomizationSheet> createState() => _ItemCustomizationSheetState();
}

class _ItemCustomizationSheetState extends State<ItemCustomizationSheet> {
  ItemVariant? _selectedVariant;
  final Set<ItemAddOn> _selectedAddOns = {};
  final TextEditingController _instructionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item.variants.isNotEmpty) {
      _selectedVariant = widget.item.variants.first;
    }
  }

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    double total = widget.item.basePrice;
    if (_selectedVariant != null) {
      total += _selectedVariant!.additionalPrice;
    }
    for (final addon in _selectedAddOns) {
      total += addon.price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: 540,
      ),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
        border: Border(
          top: BorderSide(color: AppColors.champagneGold, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 4, right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.item.isVeg ? AppColors.successGreen : AppColors.errorRed,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: widget.item.isVeg ? AppColors.successGreen : AppColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item.name, style: AppTypography.headlineSmall),
                      Text(
                        widget.item.description,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderSubtle, height: 1),

          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppSpacing.base),
              children: [
                // Portion / Variant Selection
                if (widget.item.variants.isNotEmpty) ...[
                  Text('Select Portion / Variant', style: AppTypography.titleMedium.copyWith(color: AppColors.champagneGold)),
                  const SizedBox(height: AppSpacing.sm),
                  ...widget.item.variants.map((v) {
                    final isSelected = _selectedVariant?.name == v.name;
                    return InkWell(
                      onTap: () => setState(() => _selectedVariant = v),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: isSelected ? AppColors.champagneGold : AppColors.borderSubtle,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  size: 18,
                                  color: isSelected ? AppColors.champagneGold : AppColors.mutedGrey,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Text(v.name, style: AppTypography.bodyMedium),
                              ],
                            ),
                            Text(
                              v.additionalPrice > 0 ? '+₹${v.additionalPrice.toStringAsFixed(0)}' : 'Included',
                              style: AppTypography.labelMedium.copyWith(
                                color: isSelected ? AppColors.champagneGold : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.base),
                ],

                // Add-Ons Selection
                if (widget.item.addOns.isNotEmpty) ...[
                  Text('Extra Add-Ons', style: AppTypography.titleMedium.copyWith(color: AppColors.champagneGold)),
                  const SizedBox(height: AppSpacing.sm),
                  ...widget.item.addOns.map((a) {
                    final isChecked = _selectedAddOns.contains(a);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isChecked) {
                            _selectedAddOns.remove(a);
                          } else {
                            _selectedAddOns.add(a);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isChecked ? AppColors.surfaceElevated : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: isChecked ? AppColors.champagneGold : AppColors.borderSubtle,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                                  size: 18,
                                  color: isChecked ? AppColors.champagneGold : AppColors.mutedGrey,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Text(a.name, style: AppTypography.bodyMedium),
                              ],
                            ),
                            Text(
                              '+₹${a.price.toStringAsFixed(0)}',
                              style: AppTypography.currencyMedium.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.base),
                ],

                // Item Special Instructions
                Text('Cooking Instructions for this Item', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                AppTextField(
                  hintText: 'e.g. Less spicy, well cooked, no onion garnish...',
                  controller: _instructionController,
                  prefixIcon: Icons.restaurant_menu_rounded,
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Item Total', style: AppTypography.labelSmall),
                      Text('₹${_totalPrice.toStringAsFixed(0)}', style: AppTypography.currencyLarge),
                    ],
                  ),
                ),
                Expanded(
                  child: AppButton(
                    label: 'Add to Cart',
                    icon: Icons.add_shopping_cart_rounded,
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      final addOnsTotal = _selectedAddOns.fold(0.0, (sum, a) => sum + a.price);
                      widget.onConfirm(
                        variantName: _selectedVariant?.name,
                        additionalVariantPrice: _selectedVariant?.additionalPrice ?? 0.0,
                        addOns: _selectedAddOns.map((a) => a.name).toList(),
                        addOnsTotal: addOnsTotal,
                        specialInstruction: _instructionController.text.trim().isEmpty ? null : _instructionController.text.trim(),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
