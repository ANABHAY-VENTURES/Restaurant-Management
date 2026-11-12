// Anabhay Ventures — Premium Metric Card Widget

import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final String description;
  final IconData icon;
  final bool isPositive;
  final Color? accentColor;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.description,
    required this.icon,
    this.isPositive = true,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.champagneGold;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row: icon + title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(icon, size: 20, color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),

          // Value
          Text(value, style: AppTypography.currencyLarge.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.sm),

          // Change + Description
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.successGreen : AppColors.errorRed)
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 15,
                      color: isPositive ? AppColors.successGreen : AppColors.errorRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      change,
                      style: AppTypography.labelSmall.copyWith(
                        color: isPositive ? AppColors.successGreen : AppColors.errorRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  description,
                  style: AppTypography.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
