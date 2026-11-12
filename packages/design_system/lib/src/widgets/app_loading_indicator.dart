// Anabhay Ventures — Branded Loading Indicator & Progress State

import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const AppLoadingIndicator({
    super.key,
    this.size = 28.0,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.champagneGold;

    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );

    if (message == null) return indicator;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(height: 12),
        Text(
          message!,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mutedGrey,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

