// Anabhay Ventures — Kitchen Queue Widget
// Phase 3: Connected Live Kitchen KOT Queue

import 'package:flutter/material.dart';
import 'package:restaurant_management/core/theme/theme.dart';
import 'package:restaurant_management/shared/widgets/status_badge.dart';
import 'package:restaurant_management/features/pos/domain/models/order_models.dart';

class KitchenQueueCard extends StatelessWidget {
  final List<Map<String, dynamic>>? tickets;
  final List<RestaurantOrder>? liveOrders;

  const KitchenQueueCard({
    super.key,
    this.tickets,
    this.liveOrders,
  });

  @override
  Widget build(BuildContext context) {
    final count = liveOrders != null ? liveOrders!.length : (tickets?.length ?? 0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.soup_kitchen_outlined, size: 20, color: AppColors.champagneGold),
              const SizedBox(width: AppSpacing.sm),
              Text('Kitchen Queue', style: AppTypography.titleLarge),
              const Spacer(),
              Text(
                '$count active',
                style: AppTypography.labelMedium.copyWith(color: AppColors.warningAmber),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          if (liveOrders != null)
            ...liveOrders!.map((o) => _LiveKOTTile(order: o))
          else if (tickets != null)
            ...tickets!.map((t) => _LegacyKOTTile(ticket: t)),
        ],
      ),
    );
  }
}

class _LiveKOTTile extends StatelessWidget {
  final RestaurantOrder order;

  const _LiveKOTTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final isPreparing = order.orderStatus == OrderStatus.preparing;
    final elapsedMinutes = DateTime.now().difference(order.createdAt).inMinutes;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isPreparing ? AppColors.warningAmber.withValues(alpha: 0.3) : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                order.kotNumber,
                style: AppTypography.titleMedium.copyWith(color: AppColors.champagneGold),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(order.tableNumber, style: AppTypography.bodySmall),
              const Spacer(),
              StatusBadge(
                label: order.orderStatus.label,
                variant: order.orderStatus.badgeVariant,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            order.items.map((i) => '${i.quantity}× ${i.name}').join(' • '),
            style: AppTypography.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                '$elapsedMinutes min',
                style: AppTypography.labelSmall.copyWith(
                  color: elapsedMinutes > 10 ? AppColors.errorRed : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.restaurant_rounded, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                '${order.items.length} items',
                style: AppTypography.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegacyKOTTile extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const _LegacyKOTTile({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isPreparing = ticket['status'] == 'preparing';
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isPreparing ? AppColors.warningAmber.withValues(alpha: 0.3) : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ticket['kot'] as String,
                style: AppTypography.titleMedium.copyWith(color: AppColors.champagneGold),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(ticket['table'] as String, style: AppTypography.bodySmall),
              const Spacer(),
              StatusBadge(
                label: isPreparing ? 'Preparing' : 'Pending',
                variant: isPreparing ? BadgeVariant.warning : BadgeVariant.neutral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            (ticket['itemList'] as List).join(' • '),
            style: AppTypography.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                '${ticket['elapsed']} min',
                style: AppTypography.labelSmall.copyWith(
                  color: (ticket['elapsed'] as int) > 10 ? AppColors.errorRed : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.restaurant_rounded, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text('${ticket['items']} items', style: AppTypography.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
