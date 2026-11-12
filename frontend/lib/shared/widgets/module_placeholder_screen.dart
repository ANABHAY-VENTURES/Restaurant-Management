// Anabhay Ventures — Module Placeholder Screen for Future Phases

import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class ModulePlaceholderScreen extends StatelessWidget {
  final String title;
  final String phase;
  final String description;
  final IconData icon;

  const ModulePlaceholderScreen({
    super.key,
    required this.title,
    required this.phase,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.champagneGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(color: AppColors.champagneGold.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, size: 36, color: AppColors.champagneGold),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTypography.displayMedium.copyWith(color: AppColors.warmIvory),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.copper.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  phase,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.champagneGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                description,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
