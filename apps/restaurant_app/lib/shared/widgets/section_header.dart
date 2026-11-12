// Anabhay Ventures — Section Header Widget

import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTypography.headlineSmall),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.champagneGold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

