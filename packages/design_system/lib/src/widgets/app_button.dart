// Anabhay Ventures — Premium Design System Buttons

import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum AppButtonVariant { primary, secondary, outline, danger, ghost }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, BorderSide? border) = _getColors();
    final (EdgeInsets padding, double fontSize, double iconSize) = _getSizeProps();

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          Icon(icon, size: iconSize, color: fg),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: onPressed == null ? AppColors.surfaceElevated : bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: border != null ? Border.fromBorderSide(border) : null,
            ),
            child: content,
          ),
        ),
      ),
    );
  }

  (Color, Color, BorderSide?) _getColors() {
    switch (variant) {
      case AppButtonVariant.primary:
        return (AppColors.champagneGold, AppColors.matteBlack, null);
      case AppButtonVariant.secondary:
        return (AppColors.surfaceElevated, AppColors.warmIvory, const BorderSide(color: AppColors.borderSubtle));
      case AppButtonVariant.outline:
        return (Colors.transparent, AppColors.champagneGold, const BorderSide(color: AppColors.champagneGold, width: 1.2));
      case AppButtonVariant.danger:
        return (AppColors.errorRed.withValues(alpha: 0.15), AppColors.errorRed, const BorderSide(color: AppColors.errorRed, width: 1));
      case AppButtonVariant.ghost:
        return (Colors.transparent, AppColors.textSecondary, null);
    }
  }

  (EdgeInsets, double, double) _getSizeProps() {
    switch (size) {
      case AppButtonSize.small:
        return (const EdgeInsets.symmetric(horizontal: 14, vertical: 8), 12.0, 14.0);
      case AppButtonSize.medium:
        return (const EdgeInsets.symmetric(horizontal: 20, vertical: 12), 14.0, 18.0);
      case AppButtonSize.large:
        return (const EdgeInsets.symmetric(horizontal: 28, vertical: 16), 16.0, 20.0);
    }
  }
}

