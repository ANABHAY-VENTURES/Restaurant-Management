// Anabhay Ventures — Premium Design System Dialog & Modal

import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final String? confirmLabel;
  final VoidCallback? onConfirm;
  final String cancelLabel;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const AppDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    this.confirmLabel,
    this.onConfirm,
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.isDestructive = false,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Widget content,
    String? confirmLabel,
    VoidCallback? onConfirm,
    String cancelLabel = 'Cancel',
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: AppColors.matteBlack.withValues(alpha: 0.8),
      builder: (ctx) => AppDialog(
        title: title,
        subtitle: subtitle,
        content: content,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        cancelLabel: cancelLabel,
        onCancel: onCancel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTypography.headlineMedium),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(subtitle!, style: AppTypography.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Body
              content,
              const SizedBox(height: AppSpacing.xl),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: cancelLabel,
                    variant: AppButtonVariant.ghost,
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  ),
                  if (confirmLabel != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    AppButton(
                      label: confirmLabel!,
                      variant: isDestructive ? AppButtonVariant.danger : AppButtonVariant.primary,
                      onPressed: onConfirm,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

