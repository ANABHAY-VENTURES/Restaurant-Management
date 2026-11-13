// Anabhay Ventures — OTP Verification Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController(text: '123456');

  @override
  void initState() {
    super.initState();
    final demoOtp = ref.read(authProvider).demoOtp;
    if (demoOtp != null) {
      _otpController.text = demoOtp;
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;

    final success = await ref.read(authProvider.notifier).verifyOtp(otp);
    if (success && mounted) {
      context.push('/create-new-password');
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
                      child: const Icon(Icons.mark_email_read_outlined, size: 28, color: AppColors.champagneGold),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Verify 6-Digit OTP', style: AppTypography.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      'Please enter the 6-digit verification code sent to your contact.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Demo code banner
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.champagneGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(color: AppColors.champagneGold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppColors.champagneGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Demo Verification Code: ${authState.demoOtp ?? "123456"}',
                              style: const TextStyle(fontSize: 12, color: AppColors.champagneGold, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AppTextField(
                      label: 'One-Time Password (OTP)',
                      hintText: '123456',
                      controller: _otpController,
                      prefixIcon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
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
                      label: 'Verify Code & Proceed',
                      icon: Icons.check_circle_outline_rounded,
                      isLoading: authState.isLoading,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                      onPressed: _handleVerify,
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
