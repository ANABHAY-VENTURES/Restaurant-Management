// Anabhay Ventures — Session Expired Modal Dialog

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';

class SessionExpiredDialog extends StatelessWidget {
  const SessionExpiredDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SessionExpiredDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.warningAmber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.warningAmber),
            ),
            child: const Icon(Icons.timer_off_rounded, size: 28, color: AppColors.warningAmber),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Session Expired', style: AppTypography.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Your security session has expired due to inactivity. Please sign in again to resume managing your restaurant.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Sign In Again',
            icon: Icons.login_rounded,
            isFullWidth: true,
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
