// Anabhay Ventures — Kitchen Queue Widget

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/status_badge.dart';

class KitchenQueueCard extends StatelessWidget {
  final List<Map<String, dynamic>> tickets;

  const KitchenQueueCard({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
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
                '${tickets.length} active',
                style: AppTypography.labelMedium.copyWith(color: AppColors.warningAmber),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          ...tickets.map((t) => _KOTTile(ticket: t)),
        ],
      ),
    );
  }
}

class _KOTTile extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const _KOTTile({required this.ticket});

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
          color: isPreparing
              ? AppColors.warningAmber.withValues(alpha: 0.3)
              : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ticket['kot'] as String,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.champagneGold,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                ticket['table'] as String,
                style: AppTypography.bodySmall,
              ),
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
                  color: (ticket['elapsed'] as int) > 10
                      ? AppColors.errorRed
                      : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.restaurant_rounded, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                '${ticket['items']} items',
                style: AppTypography.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
