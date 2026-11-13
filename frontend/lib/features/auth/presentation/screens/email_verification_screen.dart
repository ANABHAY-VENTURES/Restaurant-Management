// Anabhay Ventures — Email Verification Screen

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, this.email = 'owner@anabhay.com'});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.champagneGold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.champagneGold),
                      ),
                      child: const Icon(Icons.mark_email_read_rounded, size: 32, color: AppColors.champagneGold),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Verify Your Email', style: AppTypography.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      'A verification link has been dispatched to:',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email,
                      style: AppTypography.headlineSmall.copyWith(color: AppColors.champagneGold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Please click the link in your email to verify your restaurant account and unlock all POS, Billing, and KDS features.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AppButton(
                      label: _isResent ? 'Email Resent!' : 'Resend Verification Email',
                      icon: Icons.refresh_rounded,
                      variant: AppButtonVariant.outline,
                      isFullWidth: true,
                      onPressed: () {
                        setState(() => _isResent = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification link re-sent! Check your inbox.'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'I Have Verified — Enter App',
                      icon: Icons.check_circle_rounded,
                      isFullWidth: true,
                      onPressed: () => context.go('/'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
