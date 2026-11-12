// Anabhay Ventures — Status Badge Widget

import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

enum BadgeVariant { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (variant) {
      BadgeVariant.success => (AppColors.successGreen.withValues(alpha: 0.14), AppColors.successGreen),
      BadgeVariant.warning => (AppColors.warningAmber.withValues(alpha: 0.14), AppColors.warningAmber),
      BadgeVariant.error   => (AppColors.errorRed.withValues(alpha: 0.14), AppColors.errorRed),
      BadgeVariant.info    => (AppColors.infoBlue.withValues(alpha: 0.14), AppColors.infoBlue),
      BadgeVariant.neutral => (AppColors.mutedGrey.withValues(alpha: 0.14), AppColors.mutedGrey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
