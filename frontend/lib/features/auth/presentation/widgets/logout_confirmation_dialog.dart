// Anabhay Ventures — Logout Confirmation Dialog

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class LogoutConfirmationDialog extends ConsumerWidget {
  const LogoutConfirmationDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const LogoutConfirmationDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      contentPadding: const EdgeInsets.all(AppSpacing.xl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.errorRed),
            ),
            child: const Icon(Icons.logout_rounded, size: 26, color: AppColors.errorRed),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Sign Out', style: AppTypography.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to end your current session? Any unsaved orders will be safely preserved in local offline queue.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Sign Out',
                  variant: AppButtonVariant.danger,
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/welcome');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
