// Anabhay Ventures — Customer Live Order Tracking Screen
// Synchronized in real-time with Kitchen Display System (KDS) and POS Order State
// Watches ordersProvider so kitchen status updates reflect instantly without page reload

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../pos/domain/models/order_models.dart';
import '../../../pos/presentation/providers/pos_providers.dart';
import 'package:restaurant_management/features/settings/presentation/providers/settings_providers.dart';

class CustomerOrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const CustomerOrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(ordersProvider);
    final profile = ref.watch(restaurantProfileProvider);
    final orderIndex = allOrders.indexWhere((o) => o.id == orderId);

    if (orderIndex < 0) {
      return Scaffold(
        backgroundColor: AppColors.matteBlack,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Order Tracking', style: TextStyle(color: AppColors.champagneGold, fontSize: 16)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.champagneGold),
            onPressed: () => context.go('/qr-menu'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textTertiary),
                const SizedBox(height: 16),
                const Text('Order Not Found', style: AppTypography.headlineMedium),
                const SizedBox(height: 8),
                const Text(
                  'The requested order could not be located in the restaurant register.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textTertiary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.champagneGold,
                    foregroundColor: AppColors.matteBlack,
                  ),
                  onPressed: () => context.go('/qr-menu'),
                  child: const Text('Return to Digital Menu'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final order = allOrders[orderIndex];

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.champagneGold),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/qr/${Uri.encodeComponent(order.tableNumber)}');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.name,
              style: const TextStyle(color: AppColors.champagneGold, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              '${order.tableNumber} • Live Kitchen Tracking',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.room_service_outlined, color: AppColors.champagneGold),
            tooltip: 'Call Waiter',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Waiter notified for ${order.tableNumber}! A captain is heading to your table.'),
                  backgroundColor: AppColors.champagneGold,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            children: [
              // Live Status Header Card
              _buildLiveStatusHeroCard(order),
              const SizedBox(height: AppSpacing.base),

              // 4-Step Visual Progress Stepper
              _buildProgressStepper(order.orderStatus),
              const SizedBox(height: AppSpacing.base),

              // Order Summary & Items List
              _buildOrderItemsCard(order),
              const SizedBox(height: AppSpacing.base),

              // Bill Breakdown
              _buildBillSummaryCard(order),
              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.champagneGold,
                        side: const BorderSide(color: AppColors.champagneGold),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        context.push('/qr/${Uri.encodeComponent(order.tableNumber)}');
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                      label: const Text('Order More Items', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceElevated,
                        foregroundColor: AppColors.warmIvory,
                        side: const BorderSide(color: AppColors.borderSubtle),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Requested bill settlement for ${order.tableNumber}. Captain notified!'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long_rounded, size: 18),
                      label: const Text('Request Bill', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStatusHeroCard(RestaurantOrder order) {
    final status = order.orderStatus;
    Color statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusSubtitle;

    if (status == OrderStatus.newOrder) {
      statusColor = AppColors.warningAmber;
      statusIcon = Icons.receipt_long_rounded;
      statusTitle = 'Order Received by Kitchen';
      statusSubtitle = 'Ticket confirmed. Head Chef is assigning station.';
    } else if (status == OrderStatus.preparing) {
      statusColor = AppColors.copper;
      statusIcon = Icons.soup_kitchen_rounded;
      statusTitle = 'Chef is Preparing Your Food';
      statusSubtitle = 'Fresh ingredients firing on the hearth. Est. 12-15 mins.';
    } else if (status == OrderStatus.ready) {
      statusColor = AppColors.champagneGold;
      statusIcon = Icons.check_circle_rounded;
      statusTitle = 'Order Plated & Ready to Serve!';
      statusSubtitle = 'Service staff is bringing your warm feast to ${order.tableNumber}.';
    } else if (status == OrderStatus.served || status == OrderStatus.completed) {
      statusColor = AppColors.successGreen;
      statusIcon = Icons.dinner_dining_rounded;
      statusTitle = 'Order Served • Bon Appétit!';
      statusSubtitle = 'Delivered to ${order.tableNumber}. Enjoy your royal meal!';
    } else {
      statusColor = AppColors.errorRed;
      statusIcon = Icons.cancel_outlined;
      statusTitle = 'Order Cancelled';
      statusSubtitle = 'This ticket has been cancelled.';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.kotNumber,
                        style: const TextStyle(fontSize: 10, color: AppColors.champagneGold, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      'Order #${order.id.split('-').last}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  statusTitle,
                  style: AppTypography.titleMedium.copyWith(color: AppColors.warmIvory, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  statusSubtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStepper(OrderStatus status) {
    int activeStep = 0;
    if (status == OrderStatus.newOrder) {
      activeStep = 1;
    } else if (status == OrderStatus.preparing) {
      activeStep = 2;
    } else if (status == OrderStatus.ready) {
      activeStep = 3;
    } else if (status == OrderStatus.served || status == OrderStatus.completed) {
      activeStep = 4;
    }

    final steps = [
      {'title': 'Received', 'icon': Icons.check_circle_outline},
      {'title': 'Preparing', 'icon': Icons.soup_kitchen_outlined},
      {'title': 'Ready', 'icon': Icons.restaurant_rounded},
      {'title': 'Served', 'icon': Icons.done_all_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live Kitchen Progress', style: TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index % 2 == 1) {
                // Divider line between steps
                final stepIndex = (index ~/ 2) + 1;
                final isDone = activeStep > stepIndex;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: isDone ? AppColors.champagneGold : AppColors.surfaceElevated,
                  ),
                );
              }

              final stepNum = (index ~/ 2) + 1;
              final isCurrent = activeStep == stepNum;
              final isPast = activeStep >= stepNum;
              final stepData = steps[index ~/ 2];

              Color circleBg;
              Color iconColor;
              if (isCurrent) {
                circleBg = AppColors.champagneGold;
                iconColor = AppColors.matteBlack;
              } else if (isPast) {
                circleBg = AppColors.champagneGold.withValues(alpha: 0.2);
                iconColor = AppColors.champagneGold;
              } else {
                circleBg = AppColors.surfaceElevated;
                iconColor = AppColors.textTertiary;
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: circleBg,
                      shape: BoxShape.circle,
                      border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
                    ),
                    child: Center(
                      child: Icon(stepData['icon'] as IconData, size: 16, color: iconColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stepData['title'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? AppColors.champagneGold : (isPast ? AppColors.warmIvory : AppColors.textTertiary),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(RestaurantOrder order) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ordered Dishes', style: AppTypography.titleMedium),
              Text('${order.items.length} items', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            ],
          ),
          const Divider(color: AppColors.borderSubtle, height: 20),
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item.quantity}×',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.champagneGold),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.warmIvory)),
                        if (item.variantName != null)
                          Text('Portion: ${item.variantName}', style: const TextStyle(fontSize: 11, color: AppColors.champagneGold)),
                        if (item.selectedAddOns.isNotEmpty)
                          Text('+ ${item.selectedAddOns.join(', ')}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        if (item.specialInstruction != null && item.specialInstruction!.isNotEmpty)
                          Text('Note: ${item.specialInstruction}', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  Text(
                    '₹${item.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.warmIvory),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBillSummaryCard(RestaurantOrder order) {
    final isPaid = order.paymentStatus == PaymentStatus.paid;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Status:', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPaid ? AppColors.successGreen.withValues(alpha: 0.15) : AppColors.warningAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isPaid ? AppColors.successGreen : AppColors.warningAmber),
                ),
                child: Text(
                  isPaid ? 'PAID (DEMO UPI)' : 'PENDING AT COUNTER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? AppColors.successGreen : AppColors.warningAmber,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.borderSubtle, height: 20),
          _buildRow('Subtotal', '₹${order.subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 4),
          _buildRow('CGST (2.5%)', '₹${order.cgstAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          _buildRow('SGST (2.5%)', '₹${order.sgstAmount.toStringAsFixed(2)}'),
          const Divider(color: AppColors.borderSubtle, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.warmIvory)),
              Text('₹${order.grandTotal.toStringAsFixed(0)}', style: AppTypography.currencyLarge.copyWith(color: AppColors.champagneGold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, color: AppColors.warmIvory)),
      ],
    );
  }
}
