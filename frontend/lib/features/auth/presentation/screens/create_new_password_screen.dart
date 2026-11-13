// Anabhay Ventures — Create New Password Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class CreateNewPasswordScreen extends ConsumerStatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  ConsumerState<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends ConsumerState<CreateNewPasswordScreen> {
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final newPass = _newPassController.text;
    final confirm = _confirmPassController.text;

    if (newPass.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters long.'), backgroundColor: AppColors.errorRed),
      );
      return;
    }

    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.'), backgroundColor: AppColors.errorRed),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).createNewPassword(newPass);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully. Please sign in with your new credentials.'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

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
                      child: const Icon(Icons.vpn_key_rounded, size: 28, color: AppColors.champagneGold),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Create New Password', style: AppTypography.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      'Choose a strong alphanumeric password for your restaurant staff profile.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AppTextField(
                      label: 'New Password',
                      hintText: 'Min. 8 characters',
                      controller: _newPassController,
                      obscureText: _obscure,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      label: 'Confirm New Password',
                      hintText: 'Re-enter password',
                      controller: _confirmPassController,
                      obscureText: _obscure,
                      prefixIcon: Icons.lock_clock_outlined,
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
                      label: 'Update Password & Sign In',
                      icon: Icons.check_circle_rounded,
                      isLoading: authState.isLoading,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                      onPressed: _handleSave,
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
