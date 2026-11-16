// Anabhay Ventures — Customer Cart & Checkout Sheet
// Mobile-first bottom sheet for reviewing order, selecting payment mode, and placing live orders

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../pos/domain/models/order_models.dart';
import '../../../pos/presentation/providers/pos_providers.dart';
import '../providers/customer_cart_provider.dart';

class CustomerCartSheet extends ConsumerStatefulWidget {
  const CustomerCartSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CustomerCartSheet(),
    );
  }

  @override
  ConsumerState<CustomerCartSheet> createState() => _CustomerCartSheetState();
}

class _CustomerCartSheetState extends ConsumerState<CustomerCartSheet> {
  bool _isSubmitting = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showUpiDemoModal(VoidCallback onComplete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.champagneGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_2_rounded, size: 40, color: AppColors.champagneGold),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Demo UPI Payment', style: AppTypography.headlineSmall),
              const SizedBox(height: 4),
              const Text(
                'Simulating instant UPI payment for demonstration.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount to Pay:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(
                      '₹${ref.read(customerCartProvider).grandTotal.toStringAsFixed(0)}',
                      style: AppTypography.currencyMedium.copyWith(color: AppColors.champagneGold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onComplete();
                },
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text('Simulate Successful UPI Pay', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    final cart = ref.read(customerCartProvider);
    if (cart.items.isEmpty) return;

    if (_isSubmitting) return; // Prevent double submission
    setState(() => _isSubmitting = true);

    try {
      // Convert cart items to OrderItem models
      final orderItems = cart.items.map((ci) {
        return OrderItem(
          id: 'item-${DateTime.now().millisecondsSinceEpoch}-${ci.menuItem.id}',
          menuItemId: ci.menuItem.id,
          name: ci.menuItem.name,
          unitPrice: ci.unitPrice,
          quantity: ci.quantity,
          isVeg: ci.menuItem.isVeg,
          variantName: ci.selectedVariant?.name,
          selectedAddOns: ci.selectedAddOns.map((a) => a.name).toList(),
          addOnsTotal: ci.addOnsTotal,
          specialInstruction: ci.specialInstructions.isNotEmpty ? ci.specialInstructions : null,
          isPrepared: false,
        );
      }).toList();

      final paymentMethodStr = cart.paymentMethod == 'Demo UPI' ? 'Demo UPI' : 'Demo Cash';

      // Submit directly into restaurant orders state
      final createdOrder = ref.read(ordersProvider.notifier).createOrder(
            tableNumber: cart.tableNumber,
            orderType: cart.orderType,
            items: orderItems,
            customerName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
            customerPhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
            generalInstructions: 'Placed via Table QR Digital Dining',
          );

      // If user selected demo UPI, mark order as paid
      if (cart.paymentMethod == 'Demo UPI') {
        ref.read(ordersProvider.notifier).recordPayment(
              orderId: createdOrder.id,
              method: paymentMethodStr,
              amount: createdOrder.grandTotal,
            );
      }

      // Clear customer cart
      ref.read(customerCartProvider.notifier).clearCart();

      // Close bottom sheet
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to Customer Order Tracking
      if (mounted) {
        context.push('/track-order/${createdOrder.id}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(customerCartProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Order Cart', style: AppTypography.headlineSmall),
                    Text(
                      '${cart.tableNumber} • ${cart.orderType.label}',
                      style: const TextStyle(fontSize: 12, color: AppColors.champagneGold, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (cart.items.isNotEmpty)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
                    onPressed: () => ref.read(customerCartProvider.notifier).clearCart(),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderSubtle, height: 1),

          // Cart Items List
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 56, color: AppColors.textTertiary.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        const Text('Your cart is currently empty', style: AppTypography.titleMedium),
                        const SizedBox(height: 4),
                        const Text('Browse dishes and add them to your table order.', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.champagneGold,
                            side: const BorderSide(color: AppColors.champagneGold),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Back to Menu'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    children: [
                      // Line Items
                      ...cart.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dietary dot
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  border: Border.all(color: item.menuItem.dietaryType.color, width: 1.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(color: item.menuItem.dietaryType.color, shape: BoxShape.circle),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),

                              // Item details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.menuItem.name, style: AppTypography.titleMedium),
                                    if (item.selectedVariant != null)
                                      Text(
                                        'Portion: ${item.selectedVariant!.name}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.champagneGold),
                                      ),
                                    if (item.selectedAddOns.isNotEmpty)
                                      Text(
                                        'Add-ons: ${item.selectedAddOns.map((a) => a.name).join(', ')}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    if (item.specialInstructions.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Note: ${item.specialInstructions}',
                                          style: const TextStyle(fontSize: 10, color: AppColors.textTertiary, fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '₹${item.totalPrice.toStringAsFixed(0)}',
                                      style: AppTypography.currencyMedium.copyWith(color: AppColors.champagneGold),
                                    ),
                                  ],
                                ),
                              ),

                              // Stepper Controls
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () => ref.read(customerCartProvider.notifier).updateQuantity(index, -1),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Icon(Icons.remove, size: 14, color: AppColors.warmIvory),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => ref.read(customerCartProvider.notifier).updateQuantity(index, 1),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Icon(Icons.add, size: 14, color: AppColors.champagneGold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: AppSpacing.sm),

                      // Order Type Toggle
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dining Mode', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.table_restaurant, size: 16),
                                        SizedBox(width: 6),
                                        Text('Dine-In'),
                                      ],
                                    ),
                                    selected: cart.orderType == OrderType.dineIn,
                                    selectedColor: AppColors.champagneGold,
                                    labelStyle: TextStyle(
                                      color: cart.orderType == OrderType.dineIn ? AppColors.matteBlack : AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    onSelected: (_) => ref.read(customerCartProvider.notifier).setOrderType(OrderType.dineIn),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: ChoiceChip(
                                    label: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.shopping_bag_outlined, size: 16),
                                        SizedBox(width: 6),
                                        Text('Takeaway'),
                                      ],
                                    ),
                                    selected: cart.orderType == OrderType.takeaway,
                                    selectedColor: AppColors.champagneGold,
                                    labelStyle: TextStyle(
                                      color: cart.orderType == OrderType.takeaway ? AppColors.matteBlack : AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    onSelected: (_) => ref.read(customerCartProvider.notifier).setOrderType(OrderType.takeaway),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Optional Guest Details
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Contact Information (Optional)', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                              decoration: const InputDecoration(
                                hintText: 'Your name (for greeting & bill)',
                                hintStyle: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                              decoration: const InputDecoration(
                                hintText: 'Phone number (for SMS receipt)',
                                hintStyle: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Payment Method Selection
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Payment Preference', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                            const SizedBox(height: 6),
                            RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              value: 'Pay at Counter',
                              groupValue: cart.paymentMethod,
                              activeColor: AppColors.champagneGold,
                              onChanged: (val) => ref.read(customerCartProvider.notifier).setPaymentMethod(val!),
                              title: const Text('Pay at Counter / Settle Later', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.warmIvory)),
                              subtitle: const Text('Cash, card or UPI directly with your server after meal', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                            ),
                            const Divider(color: AppColors.borderSubtle, height: 12),
                            RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              value: 'Demo UPI',
                              groupValue: cart.paymentMethod,
                              activeColor: AppColors.champagneGold,
                              onChanged: (val) => ref.read(customerCartProvider.notifier).setPaymentMethod(val!),
                              title: const Text('Demo UPI Payment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.warmIvory)),
                              subtitle: const Text('Simulate contactless digital mobile payment immediately', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Bill Summary
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow('Subtotal (${cart.totalItemCount} items)', '₹${cart.subtotal.toStringAsFixed(0)}'),
                            const SizedBox(height: 6),
                            if (cart.isGstEnabled) ...[
                              _buildSummaryRow('CGST (${(cart.taxRatePercent / 2).toStringAsFixed(1)}%)', '₹${cart.cgstAmount.toStringAsFixed(2)}'),
                              const SizedBox(height: 6),
                              _buildSummaryRow('SGST (${(cart.taxRatePercent / 2).toStringAsFixed(1)}%)', '₹${cart.sgstAmount.toStringAsFixed(2)}'),
                            ] else
                              _buildSummaryRow('GST Taxes', 'Exempted (0.00)'),
                            const Divider(color: AppColors.borderSubtle, height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Grand Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.warmIvory)),
                                Text('₹${cart.grandTotal.toStringAsFixed(0)}', style: AppTypography.currencyLarge.copyWith(color: AppColors.champagneGold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
          ),

          // Bottom Place Order Action Bar
          if (cart.items.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: const BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.champagneGold,
                    foregroundColor: AppColors.matteBlack,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          if (cart.paymentMethod == 'Demo UPI') {
                            _showUpiDemoModal(_placeOrder);
                          } else {
                            _placeOrder();
                          }
                        },
                  icon: _isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.matteBlack))
                      : const Icon(Icons.soup_kitchen_rounded, size: 20),
                  label: Text(
                    _isSubmitting
                        ? 'Confirming Order with Kitchen...'
                        : 'Confirm & Send to Kitchen • ₹${cart.grandTotal.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, color: AppColors.warmIvory, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
