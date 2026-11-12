// Anabhay Ventures — Premium Design System Bottom Sheet

import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AppBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
        side: BorderSide(color: AppColors.borderSubtle),
      ),
      isScrollControlled: true,
      builder: (ctx) => AppBottomSheet(
        title: title,
        trailing: trailing,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppSpacing.base,
          right: AppSpacing.base,
          top: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(title, style: AppTypography.headlineMedium),
                ),
                if (trailing != null) trailing!,
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textTertiary),
                ),
              ],
            ),
            const Divider(color: AppColors.borderSubtle),
            const SizedBox(height: AppSpacing.base),
            child,
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

