// Anabhay Ventures — Food Item Customization Sheet (Customer Mobile Menu)
// Enables selection of portions, variants, add-ons, special chef instructions, and dynamic live price calculation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../pos/domain/models/order_models.dart';
import '../providers/customer_cart_provider.dart';

class FoodCustomizationSheet extends ConsumerStatefulWidget {
  final MenuItem item;

  const FoodCustomizationSheet({super.key, required this.item});

  static Future<void> show(BuildContext context, MenuItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodCustomizationSheet(item: item),
    );
  }

  @override
  ConsumerState<FoodCustomizationSheet> createState() => _FoodCustomizationSheetState();
}

class _FoodCustomizationSheetState extends ConsumerState<FoodCustomizationSheet> {
  late ItemVariant? _selectedVariant;
  final Set<ItemAddOn> _selectedAddOns = {};
  int _quantity = 1;
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.item.variants.isNotEmpty ? widget.item.variants.first : null;
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  double get _currentUnitPrice {
    final base = widget.item.basePrice;
    final variantExtra = _selectedVariant?.additionalPrice ?? 0.0;
    return base + variantExtra;
  }

  double get _currentAddOnsTotal {
    return _selectedAddOns.fold(0.0, (sum, a) => sum + a.price);
  }

  double get _totalPrice {
    return (_currentUnitPrice + _currentAddOnsTotal) * _quantity;
  }

  void _onAddToCart() {
    ref.read(customerCartProvider.notifier).addItem(
      menuItem: widget.item,
      variant: _selectedVariant,
      addOns: _selectedAddOns.toList(),
      instructions: _instructionsController.text.trim(),
      quantity: _quantity,
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${_quantity}× ${widget.item.name} to your order!'),
        backgroundColor: AppColors.champagneGold,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dietaryColor = widget.item.dietaryType.color;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dish Banner & Header
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surfaceCard,
                          AppColors.champagneGold.withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.restaurant_rounded,
                            size: 56,
                            color: AppColors.champagneGold.withValues(alpha: 0.4),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(color: dietaryColor, width: 2),
                              borderRadius: BorderRadius.circular(4),
                              color: AppColors.surfaceDark,
                            ),
                            child: Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: dietaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (widget.item.isFeatured)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.champagneGold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'CHEF SPECIAL',
                                style: TextStyle(
                                  color: AppColors.matteBlack,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.item.name, style: AppTypography.headlineMedium),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.item.category} • ${widget.item.prepTimeMinutes} mins prep',
                              style: const TextStyle(fontSize: 12, color: AppColors.champagneGold),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${widget.item.basePrice.toStringAsFixed(0)}',
                        style: AppTypography.currencyLarge.copyWith(color: AppColors.champagneGold),
                      ),
                    ],
                  ),
                  if (widget.item.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.item.description,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                  const Divider(color: AppColors.borderSubtle, height: 28),

                  // Portion / Variants Section
                  if (widget.item.variants.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Choose Portion Size', style: AppTypography.titleMedium),
                        Text('Required', style: TextStyle(fontSize: 11, color: AppColors.champagneGold, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...widget.item.variants.map((v) {
                      final isSelected = _selectedVariant?.name == v.name;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.champagneGold.withValues(alpha: 0.1) : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: isSelected ? AppColors.champagneGold : AppColors.borderSubtle,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: RadioListTile<ItemVariant>(
                          value: v,
                          groupValue: _selectedVariant,
                          activeColor: AppColors.champagneGold,
                          onChanged: (val) {
                            setState(() => _selectedVariant = val);
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(v.name, style: AppTypography.bodyMedium),
                              Text(
                                v.additionalPrice > 0
                                    ? '+₹${v.additionalPrice.toStringAsFixed(0)}'
                                    : 'Base Price',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? AppColors.champagneGold : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const Divider(color: AppColors.borderSubtle, height: 28),
                  ],

                  // Add-ons Section
                  if (widget.item.addOns.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Select Extra Add-ons', style: AppTypography.titleMedium),
                        Text('Optional', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...widget.item.addOns.map((a) {
                      final isChecked = _selectedAddOns.contains(a);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isChecked ? AppColors.champagneGold.withValues(alpha: 0.1) : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: isChecked ? AppColors.champagneGold : AppColors.borderSubtle,
                            width: isChecked ? 1.5 : 1,
                          ),
                        ),
                        child: CheckboxListTile(
                          value: isChecked,
                          activeColor: AppColors.champagneGold,
                          checkColor: AppColors.matteBlack,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedAddOns.add(a);
                              } else {
                                _selectedAddOns.remove(a);
                              }
                            });
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(a.name, style: AppTypography.bodyMedium),
                              Text(
                                '+₹${a.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isChecked ? AppColors.champagneGold : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const Divider(color: AppColors.borderSubtle, height: 28),
                  ],

                  // Special Cooking Instructions
                  const Text('Special Cooking Instructions', style: AppTypography.titleMedium),
                  const SizedBox(height: 4),
                  const Text('e.g. Less spicy, no onion-garlic, extra crispy, less oil', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _instructionsController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                    decoration: InputDecoration(
                      hintText: 'Add special notes for the kitchen...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        borderSide: const BorderSide(color: AppColors.champagneGold),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),

          // Bottom Action Bar: Stepper & Add Button
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              children: [
                // Quantity Stepper
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18, color: AppColors.warmIvory),
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.warmIvory),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18, color: AppColors.champagneGold),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Add to Order Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.champagneGold,
                      foregroundColor: AppColors.matteBlack,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _onAddToCart,
                    child: Text(
                      'Add to Order • ₹${_totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
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
