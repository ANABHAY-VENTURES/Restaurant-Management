// Anabhay Ventures — Forgot Password Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _identifierController = TextEditingController(text: 'owner@anabhay.com');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) return;

    final success = await ref.read(authProvider.notifier).forgotPassword(identifier);
    if (success && mounted) {
      context.push('/verify-otp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.champagneGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.champagneGold),
                        ),
                        child: const Icon(Icons.lock_reset_rounded, size: 28, color: AppColors.champagneGold),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Password Recovery', style: AppTypography.headlineSmall),
                      const SizedBox(height: 6),
                      Text(
                        'Enter the registered email or mobile number associated with your restaurant staff account.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      AppTextField(
                        label: 'Registered Email or Phone',
                        hintText: 'owner@anabhay.com',
                        controller: _identifierController,
                        prefixIcon: Icons.contact_mail_outlined,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      if (authState.errorMessage != null) ...[
                        Text(
                          authState.errorMessage!,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      AppButton(
                        label: 'Send 6-Digit OTP Code',
                        icon: Icons.send_rounded,
                        isLoading: authState.isLoading,
                        isFullWidth: true,
                        size: AppButtonSize.large,
                        onPressed: _handleSendOtp,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Back to Sign In', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
