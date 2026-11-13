// Anabhay Ventures — Welcome & Gateway Screen

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Luxury Brand Crest ─────────────────────────
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.champagneGold,
                          AppColors.champagneGold.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.champagneGold.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.restaurant_rounded, size: 36, color: AppColors.matteBlack),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Title & Company ────────────────────────────
                  Text(
                    'Restaurant Management',
                    style: AppTypography.displayMedium.copyWith(letterSpacing: -0.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'BY ANABHAY VENTURES',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.champagneGold,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'The complete enterprise restaurant operating system for fine-dining, cafes, cloud kitchens, and multi-branch venues.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Feature Highlights ─────────────────────────
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: const [
                      _FeaturePill(icon: Icons.point_of_sale_rounded, label: 'Fast POS & Billing'),
                      _FeaturePill(icon: Icons.soup_kitchen_outlined, label: 'Live KDS Bump-Bar'),
                      _FeaturePill(icon: Icons.table_restaurant_outlined, label: 'Floor Plan Sync'),
                      _FeaturePill(icon: Icons.qr_code_2_rounded, label: 'Customer QR Dine'),
                      _FeaturePill(icon: Icons.inventory_2_outlined, label: 'Realtime Stock'),
                      _FeaturePill(icon: Icons.shield_outlined, label: 'Multi-Tenant RBAC'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Action Buttons ─────────────────────────────
                  AppButton(
                    label: 'Sign In to Restaurant',
                    icon: Icons.login_rounded,
                    isFullWidth: true,
                    size: AppButtonSize.large,
                    onPressed: () => context.go('/login'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Onboard New Restaurant (Register)',
                    icon: Icons.storefront_rounded,
                    isFullWidth: true,
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.large,
                    onPressed: () => context.go('/register-owner'),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Bypass direct to demo dashboard ───────────
                  TextButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textTertiary),
                    label: Text(
                      'Launch Live Demo Dashboard',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Security & Compliance Footer ───────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.mutedGrey),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Enterprise Argon2 / PBKDF2 Encryption • GST Compliant',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.mutedGrey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.champagneGold),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
