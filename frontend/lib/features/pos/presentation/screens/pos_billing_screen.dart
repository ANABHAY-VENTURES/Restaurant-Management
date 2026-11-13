// Anabhay Ventures — Premium POS Billing Screen
// Phase 3: Connected Live POS with Multi-Zone Tables, Variants, Discounts & KOT Dispatch

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_management/core/theme/theme.dart';
import 'package:restaurant_management/shared/widgets/widgets.dart';
import 'package:restaurant_management/features/pos/domain/models/order_models.dart';
import 'package:restaurant_management/features/pos/presentation/providers/pos_providers.dart';
import 'package:restaurant_management/features/pos/presentation/widgets/invoice_preview_dialog.dart';
import 'package:restaurant_management/features/pos/presentation/widgets/item_customization_sheet.dart';

class POSBillingScreen extends ConsumerStatefulWidget {
  const POSBillingScreen({super.key});

  @override
  ConsumerState<POSBillingScreen> createState() => _POSBillingScreenState();
}

class _POSBillingScreenState extends ConsumerState<POSBillingScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _instructionController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  bool _showCustomerFields = false;
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Biryani',
    'Breads',
    'Starters',
    'Main Course',
    'Desserts',
    'Beverages',
  ];

  @override
  void dispose() {
    _instructionController.dispose();
    _discountController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  void _showDiscountDialog() {
    final cart = ref.read(posCartProvider);
    _discountController.text = cart.fixedDiscountAmount > 0
        ? cart.fixedDiscountAmount.toStringAsFixed(0)
        : (cart.discountPercent > 0 ? cart.discountPercent.toStringAsFixed(0) : '');

    bool isPercent = cart.discountPercent > 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: Text('Apply Bill Discount', style: AppTypography.headlineSmall),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Percentage (%)'),
                    selected: isPercent,
                    selectedColor: AppColors.champagneGold,
                    labelStyle: TextStyle(
                      color: isPercent ? AppColors.matteBlack : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) => setDialogState(() => isPercent = true),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ChoiceChip(
                    label: const Text('Fixed Amount (₹)'),
                    selected: !isPercent,
                    selectedColor: AppColors.champagneGold,
                    labelStyle: TextStyle(
                      color: !isPercent ? AppColors.matteBlack : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) => setDialogState(() => isPercent = false),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _discountController,
                hintText: isPercent ? 'e.g. 10 for 10%' : 'e.g. 150 for ₹150 off',
                keyboardType: TextInputType.number,
                prefixIcon: isPercent ? Icons.percent : Icons.currency_rupee,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(posCartProvider.notifier).setDiscount(percent: 0, fixedAmount: 0);
                Navigator.of(ctx).pop();
              },
              child: const Text('Remove Discount', style: TextStyle(color: AppColors.errorRed)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.champagneGold, foregroundColor: AppColors.matteBlack),
              onPressed: () {
                final val = double.tryParse(_discountController.text) ?? 0.0;
                if (isPercent) {
                  ref.read(posCartProvider.notifier).setDiscount(percent: val, fixedAmount: 0);
                } else {
                  ref.read(posCartProvider.notifier).setDiscount(percent: 0, fixedAmount: val);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendToKitchen() {
    final cart = ref.read(posCartProvider);
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items to cart before placing order.'), backgroundColor: AppColors.warningAmber),
      );
      return;
    }

    try {
      final order = ref.read(posCartProvider.notifier).placeOrder();
      _instructionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.id} (${order.kotNumber}) sent to Kitchen for ${order.tableNumber}!'),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.errorRed),
      );
    }
  }

  void _proceedToSettle() {
    final cart = ref.read(posCartProvider);
    if (cart.items.isEmpty) return;

    final invoiceNumber = 'INV-2026-${DateTime.now().millisecondsSinceEpoch % 10000}';

    InvoicePreviewDialog.show(
      context: context,
      invoiceNumber: invoiceNumber,
      tableNumber: cart.selectedTable,
      orderType: cart.orderType,
      items: cart.items,
      subtotal: cart.subtotal,
      discountAmount: cart.discountAmount,
      cgst: cart.cgst,
      sgst: cart.sgst,
      total: cart.grandTotal,
      onPaymentCompleted: () {
        // If there was an active order, settle it in repository
        if (cart.activeExistingOrderId != null) {
          ref.read(ordersProvider.notifier).settleOrder(
                cart.activeExistingOrderId!,
                paymentMethod: 'Demo Cash',
              );
        } else {
          // Create and immediately settle
          final created = ref.read(posCartProvider.notifier).placeOrder();
          ref.read(ordersProvider.notifier).settleOrder(
                created.id,
                paymentMethod: 'Demo Cash',
              );
        }
        ref.read(posCartProvider.notifier).clearCart();
        _instructionController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment Succeeded (DEMO) • Table Released!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(menuItemsProvider);
    final tables = ref.watch(tablesProvider);
    final cart = ref.watch(posCartProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1050;

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Center & Left: Menu Grid & Filters ────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(tables, cart),
                  const SizedBox(height: AppSpacing.md),
                  _buildCategoryFilter(),
                  const SizedBox(height: AppSpacing.base),
                  Expanded(child: _buildMenuGrid(menuItems)),
                ],
              ),
            ),
          ),

          // ── Right: Active Order Cart & Billing Summary ────────────
          Container(
            width: isDesktop ? 400 : 340,
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border(left: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: _buildCartPanel(cart),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(List<RestaurantTable> tables, PosCartState cart) {
    return Row(
      children: [
        // Search bar
        Expanded(
          child: AppTextField(
            hintText: 'Search dishes, biryani, naan, tandoori...',
            prefixIcon: Icons.search_rounded,
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Order Type Toggle (Dine-in, Takeaway, Delivery)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<OrderType>(
              value: cart.orderType,
              dropdownColor: AppColors.surfaceElevated,
              style: AppTypography.labelMedium.copyWith(color: AppColors.champagneGold, fontWeight: FontWeight.bold),
              items: OrderType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.label));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(posCartProvider.notifier).setOrderType(val);
                }
              },
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Table selector (Showing Occupancy status)
        if (cart.orderType == OrderType.dineIn)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: cart.activeExistingOrderId != null ? AppColors.warningAmber : AppColors.borderSubtle,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: tables.any((t) => t.number == cart.selectedTable) ? cart.selectedTable : tables.first.number,
                dropdownColor: AppColors.surfaceElevated,
                style: AppTypography.labelMedium.copyWith(color: AppColors.warmIvory),
                items: tables.map((t) {
                  final isOcc = t.status == TableStatus.occupied;
                  final isBilled = t.status == TableStatus.billed;
                  final badge = isOcc ? ' (Occupied)' : (isBilled ? ' (Billed)' : ' (Free)');
                  return DropdownMenuItem(
                    value: t.number,
                    child: Text(
                      '${t.number}$badge',
                      style: TextStyle(
                        color: isOcc ? AppColors.copper : (isBilled ? AppColors.champagneGold : AppColors.warmIvory),
                        fontWeight: t.number == cart.selectedTable ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref.read(posCartProvider.notifier).setSelectedTable(val);
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
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
    );
  }

  Widget _buildMenuGrid(List<MenuItem> allItems) {
    final filtered = allItems.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: AppEmptyState(
          icon: Icons.search_off_rounded,
          title: 'No dishes found',
          description: 'Try adjusting your search query or category filter.',
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 165,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _buildMenuItemCard(item);
      },
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: () {
          // If item has variants or add-ons, open customizer sheet
          if (item.variants.isNotEmpty || item.addOns.isNotEmpty) {
            ItemCustomizationSheet.show(
              context,
              item: item,
              onConfirm: ({
                required variantName,
                required additionalVariantPrice,
                required addOns,
                required addOnsTotal,
                required specialInstruction,
              }) {
                ref.read(posCartProvider.notifier).addItem(
                      item,
                      variantName: variantName,
                      additionalVariantPrice: additionalVariantPrice,
                      addOns: addOns,
                      addOnsTotal: addOnsTotal,
                      specialInstruction: specialInstruction,
                    );
              },
            );
          } else {
            ref.read(posCartProvider.notifier).addItem(item);
          }
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Veg/NonVeg dot + Category
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: item.isVeg ? AppColors.successGreen : AppColors.errorRed,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: item.isVeg ? AppColors.successGreen : AppColors.errorRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item.category,
                      style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textTertiary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.variants.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.champagneGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('CUSTOM', style: TextStyle(fontSize: 8, color: AppColors.champagneGold, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                item.name,
                style: AppTypography.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${item.basePrice.toStringAsFixed(0)}',
                    style: AppTypography.currencyMedium.copyWith(fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.champagneGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.add, size: 16, color: AppColors.champagneGold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartPanel(PosCartState cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cart Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Bill', style: AppTypography.titleLarge),
                      Text(
                        '${cart.selectedTable} • ${cart.orderType.label}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.champagneGold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _showCustomerFields = !_showCustomerFields),
                        icon: Icon(
                          _showCustomerFields ? Icons.person_rounded : Icons.person_outline_rounded,
                          size: 20,
                          color: _showCustomerFields ? AppColors.champagneGold : AppColors.textTertiary,
                        ),
                        tooltip: 'Guest Info',
                      ),
                      IconButton(
                        onPressed: cart.items.isEmpty ? null : () => ref.read(posCartProvider.notifier).clearCart(),
                        icon: const Icon(Icons.delete_sweep_outlined, size: 20, color: AppColors.textTertiary),
                        tooltip: 'Clear Cart',
                      ),
                    ],
                  ),
                ],
              ),
              if (cart.activeExistingOrderId != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warningAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.table_restaurant_rounded, size: 14, color: AppColors.warningAmber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Active dine-in session loaded (${cart.activeExistingOrderId})',
                          style: const TextStyle(fontSize: 10, color: AppColors.warningAmber, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Optional Customer Details
        if (_showCustomerFields)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 8),
            color: AppColors.surfaceElevated,
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    hintText: 'Guest Name',
                    controller: _customerNameController,
                    onChanged: (val) => ref.read(posCartProvider.notifier).setCustomerDetails(name: val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(
                    hintText: 'Phone No.',
                    keyboardType: TextInputType.phone,
                    controller: _customerPhoneController,
                    onChanged: (val) => ref.read(posCartProvider.notifier).setCustomerDetails(phone: val),
                  ),
                ),
              ],
            ),
          ),

        // Cart Items List
        Expanded(
          child: cart.items.isEmpty
              ? const AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order is empty',
                  description: 'Select dishes from the menu to build table bill.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 16),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _buildCartItemTile(item);
                  },
                ),
        ),

        // Special Cooking Instruction
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: AppTextField(
            hintText: 'Add kitchen instructions (e.g. Less spicy)...',
            controller: _instructionController,
            prefixIcon: Icons.soup_kitchen_outlined,
            onChanged: (val) => ref.read(posCartProvider.notifier).setSpecialInstructions(val),
          ),
        ),

        // Financial Breakdown Summary
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: const BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Column(
            children: [
              _summaryRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
              InkWell(
                onTap: _showDiscountDialog,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Discount', style: AppTypography.bodySmall),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit_outlined, size: 12, color: AppColors.champagneGold),
                        ],
                      ),
                      Text(
                        cart.discountAmount > 0 ? '-₹${cart.discountAmount.toStringAsFixed(2)}' : 'Add Discount',
                        style: AppTypography.bodySmall.copyWith(
                          color: cart.discountAmount > 0 ? AppColors.errorRed : AppColors.champagneGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _summaryRow('CGST (2.5%)', '₹${cart.cgst.toStringAsFixed(2)}'),
              _summaryRow('SGST (2.5%)', '₹${cart.sgst.toStringAsFixed(2)}'),
              const Divider(color: AppColors.borderSubtle, height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: AppTypography.titleLarge),
                  Text('₹${cart.grandTotal.toStringAsFixed(2)}', style: AppTypography.currencyLarge),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Send KOT',
                      variant: AppButtonVariant.secondary,
                      icon: Icons.soup_kitchen_outlined,
                      onPressed: cart.items.isEmpty ? null : _sendToKitchen,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: 'Pay & Settle',
                      variant: AppButtonVariant.primary,
                      icon: Icons.receipt_long_rounded,
                      onPressed: cart.items.isEmpty ? null : _proceedToSettle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemTile(OrderItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.variantName != null)
                    Text('Portion: ${item.variantName}', style: const TextStyle(fontSize: 11, color: AppColors.champagneGold)),
                  Text('₹${(item.unitPrice + item.addOnsTotal).toStringAsFixed(0)} each', style: AppTypography.bodySmall),
                ],
              ),
            ),
            // Qty Stepper
            Row(
              children: [
                InkWell(
                  onTap: () => ref.read(posCartProvider.notifier).decrementItem(item.id),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(Icons.remove, size: 14, color: AppColors.warmIvory),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('${item.quantity}', style: AppTypography.titleMedium),
                ),
                InkWell(
                  onTap: () => ref.read(posCartProvider.notifier).incrementItem(item.id),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(Icons.add, size: 14, color: AppColors.warmIvory),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '₹${item.totalPrice.toStringAsFixed(0)}',
              style: AppTypography.titleMedium.copyWith(color: AppColors.champagneGold),
            ),
          ],
        ),
        if (item.selectedAddOns.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '+ ${item.selectedAddOns.join(', ')}',
              style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
            ),
          ),
        if (item.specialInstruction != null && item.specialInstruction!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '• ${item.specialInstruction}',
              style: const TextStyle(fontSize: 10, color: AppColors.copper),
            ),
          ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
