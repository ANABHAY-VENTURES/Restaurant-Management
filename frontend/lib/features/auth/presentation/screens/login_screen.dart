// Anabhay Ventures — Luxury Restaurant Login Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _emailController = TextEditingController(text: 'owner@anabhay.com');
  final TextEditingController _phoneController = TextEditingController(text: '+91 98765 43210');
  final TextEditingController _passwordController = TextEditingController(text: 'Anabhay@2026');

  bool _rememberMe = true;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _tabController.index == 0
        ? _emailController.text.trim()
        : _phoneController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(authProvider.notifier).login(identifier, password);
    if (success && mounted) {
      context.go('/');
    }
  }

  void _quickRoleLogin(String role) {
    ref.read(authProvider.notifier).switchRole(role);
    context.go('/');
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
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Brand Header ──────────────────────────────
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.champagneGold,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.champagneGold.withValues(alpha: 0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.restaurant_menu_rounded, size: 30, color: AppColors.matteBlack),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Restaurant Management',
                    style: AppTypography.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ANABHAY VENTURES',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.champagneGold,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Login Card ────────────────────────────────
                  Container(
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
                          // Tab selector: Email vs Phone
                          Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: AppColors.champagneGold,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                              labelColor: AppColors.matteBlack,
                              unselectedLabelColor: AppColors.textSecondary,
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              indicatorSize: TabBarIndicatorSize.tab,
                              tabs: const [
                                Tab(text: 'Email Login'),
                                Tab(text: 'Phone Login'),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Dynamic Input: Email vs Phone
                          SizedBox(
                            height: 85,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                AppTextField(
                                  label: 'Email Address',
                                  hintText: 'owner@anabhay.com',
                                  controller: _emailController,
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                AppTextField(
                                  label: 'Phone Number',
                                  hintText: '+91 98765 43210',
                                  controller: _phoneController,
                                  prefixIcon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Password Field
                          AppTextField(
                            label: 'Password',
                            hintText: '••••••••',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 18,
                                color: AppColors.textTertiary,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Remember Me & Forgot Password Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: AppColors.champagneGold,
                                      checkColor: AppColors.matteBlack,
                                      onChanged: (val) => setState(() => _rememberMe = val ?? true),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember login',
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => context.push('/forgot-password'),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                child: Text(
                                  'Forgot password?',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.champagneGold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Error Banner
                          if (authState.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.errorRed.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.errorRed),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authState.errorMessage!,
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          // Submit Button
                          AppButton(
                            label: 'Sign In to Restaurant',
                            icon: Icons.lock_open_rounded,
                            isFullWidth: true,
                            isLoading: authState.isLoading,
                            size: AppButtonSize.large,
                            onPressed: _handleLogin,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Quick Demo Role Switcher ───────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.speed_rounded, size: 16, color: AppColors.champagneGold),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Instant Role Switcher (Live Testing)',
                                style: AppTypography.labelMedium.copyWith(color: AppColors.champagneGold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Test UI and permissions instantaneously under any role:',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _RoleChip(label: '👑 Owner', role: 'owner', onTap: () => _quickRoleLogin('owner')),
                            _RoleChip(label: '🛡️ Admin', role: 'admin', onTap: () => _quickRoleLogin('admin')),
                            _RoleChip(label: '🏢 Manager', role: 'branch_manager', onTap: () => _quickRoleLogin('branch_manager')),
                            _RoleChip(label: '💳 Cashier', role: 'cashier', onTap: () => _quickRoleLogin('cashier')),
                            _RoleChip(label: '🍽️ Waiter', role: 'waiter', onTap: () => _quickRoleLogin('waiter')),
                            _RoleChip(label: '🍳 Chef/KDS', role: 'kitchen_staff', onTap: () => _quickRoleLogin('kitchen_staff')),
                            _RoleChip(label: '📦 Inventory', role: 'inventory_manager', onTap: () => _quickRoleLogin('inventory_manager')),
                            _RoleChip(label: '📊 Accountant', role: 'accountant', onTap: () => _quickRoleLogin('accountant')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Register Link ──────────────────────────────
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Don't have a restaurant account yet? ",
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => context.go('/register-owner'),
                        child: Text(
                          'Register Here',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.champagneGold,
                            fontWeight: FontWeight.bold,
                          ),
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

class _RoleChip extends StatelessWidget {
  final String label;
  final String role;
  final VoidCallback onTap;

  const _RoleChip({required this.label, required this.role, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
