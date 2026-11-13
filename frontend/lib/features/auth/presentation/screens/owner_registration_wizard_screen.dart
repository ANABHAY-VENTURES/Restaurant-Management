// Anabhay Ventures — Restaurant Owner Multi-Step Onboarding Wizard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class OwnerRegistrationWizardScreen extends ConsumerStatefulWidget {
  const OwnerRegistrationWizardScreen({super.key});

  @override
  ConsumerState<OwnerRegistrationWizardScreen> createState() => _OwnerRegistrationWizardScreenState();
}

class _OwnerRegistrationWizardScreenState extends ConsumerState<OwnerRegistrationWizardScreen> {
  int _currentStep = 0; // 0 to 5 (Steps 1 to 6)

  // Step 1: Owner Information
  final _ownerNameCtrl = TextEditingController(text: 'Vikramaditya Roy');
  final _ownerEmailCtrl = TextEditingController(text: 'vikram@anabhayventures.com');
  final _ownerPhoneCtrl = TextEditingController(text: '+91 98765 43210');
  final _passwordCtrl = TextEditingController(text: 'Anabhay@2026');
  bool _obscurePassword = true;

  // Step 2: Restaurant Information
  final _restaurantNameCtrl = TextEditingController(text: 'Anabhay Royal Kitchen & Bar');
  String _restaurantType = 'Fine Dining';
  final _descriptionCtrl = TextEditingController(text: 'Authentic royal North Indian cuisine and charcoal tandoor delicacies.');
  final _contactPhoneCtrl = TextEditingController(text: '+91 11 2341 5678');
  final _contactEmailCtrl = TextEditingController(text: 'contact@anabhayventures.com');

  // Step 3: Business Information
  bool _gstRegistered = true;
  final _gstinCtrl = TextEditingController(text: '07AAAAA0000A1Z5');
  final _panCtrl = TextEditingController(text: 'AAAAA0000A');
  final _addressCtrl = TextEditingController(text: 'B-14, Inner Circle, Connaught Place');
  final _cityCtrl = TextEditingController(text: 'New Delhi');
  final _stateCtrl = TextEditingController(text: 'Delhi');
  final _pincodeCtrl = TextEditingController(text: '110001');

  // Step 4: Configuration
  final String _currency = 'INR (₹)';
  final String _timezone = 'Asia/Kolkata (IST)';
  String _defaultLanguage = 'English';
  final _taxRateCtrl = TextEditingController(text: '5.0');
  final _invoicePrefixCtrl = TextEditingController(text: 'INV-');

  // Step 5: Branch Setup
  final _branchNameCtrl = TextEditingController(text: 'Connaught Place Flagship');
  final _branchAddressCtrl = TextEditingController(text: 'B-14, Inner Circle, Connaught Place, New Delhi');
  final _branchPhoneCtrl = TextEditingController(text: '+91 11 2341 5678');
  final _openingHoursCtrl = TextEditingController(text: '11:00 AM - 11:30 PM');

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _ownerEmailCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    _passwordCtrl.dispose();
    _restaurantNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _contactEmailCtrl.dispose();
    _gstinCtrl.dispose();
    _panCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    _taxRateCtrl.dispose();
    _invoicePrefixCtrl.dispose();
    _branchNameCtrl.dispose();
    _branchAddressCtrl.dispose();
    _branchPhoneCtrl.dispose();
    _openingHoursCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _completeRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.go('/welcome');
    }
  }

  Future<void> _completeRegistration() async {
    final payload = {
      'owner_name': _ownerNameCtrl.text.trim(),
      'owner_email': _ownerEmailCtrl.text.trim(),
      'owner_phone': _ownerPhoneCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'restaurant_name': _restaurantNameCtrl.text.trim(),
      'restaurant_type': _restaurantType.toLowerCase().replaceAll(' ', '_'),
      'description': _descriptionCtrl.text.trim(),
      'gst_registered': _gstRegistered,
      'gstin': _gstinCtrl.text.trim(),
      'pan': _panCtrl.text.trim(),
      'business_address': _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'pincode': _pincodeCtrl.text.trim(),
      'currency': 'INR',
      'timezone': 'Asia/Kolkata',
      'default_tax_rate': double.tryParse(_taxRateCtrl.text) ?? 5.0,
      'invoice_prefix': _invoicePrefixCtrl.text.trim(),
      'branch_name': _branchNameCtrl.text.trim(),
      'branch_address': _branchAddressCtrl.text.trim(),
      'branch_phone': _branchPhoneCtrl.text.trim(),
      'opening_hours': _openingHoursCtrl.text.trim(),
    };

    final success = await ref.read(authProvider.notifier).registerOwner(payload);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant Onboarding Complete! Welcome to Restaurant Management OS.'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: _previousStep,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Restaurant Onboarding', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Step ${_currentStep + 1} of 6 — ${_getStepTitle(_currentStep)}',
                style: const TextStyle(fontSize: 12, color: AppColors.champagneGold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Already Registered? Sign In', style: TextStyle(color: AppColors.champagneGold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress Bar ───────────────────────────────
            LinearProgressIndicator(
              value: (_currentStep + 1) / 6.0,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.champagneGold),
              minHeight: 4,
            ),

            // ── Wizard Body ────────────────────────────────
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
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
                          _buildStepContent(),
                          const SizedBox(height: AppSpacing.xl),

                          // Error Banner
                          if (authState.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.errorRed.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                authState.errorMessage!,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          // Step Navigation Controls
                          Row(
                            children: [
                              if (_currentStep > 0)
                                Expanded(
                                  flex: 1,
                                  child: AppButton(
                                    label: 'Back',
                                    variant: AppButtonVariant.outline,
                                    onPressed: _previousStep,
                                  ),
                                ),
                              if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
                              Expanded(
                                flex: 2,
                                child: AppButton(
                                  label: _currentStep == 5 ? 'Launch Restaurant OS' : 'Continue to ${_getStepTitle(_currentStep + 1)}',
                                  icon: _currentStep == 5 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                                  isLoading: authState.isLoading,
                                  onPressed: _nextStep,
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
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return 'Owner Information';
      case 1: return 'Restaurant Profile';
      case 2: return 'Business & Tax';
      case 3: return 'Operating Config';
      case 4: return 'Primary Branch';
      case 5: return 'Launch & Access';
      default: return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildStep1OwnerInfo();
      case 1: return _buildStep2RestaurantInfo();
      case 2: return _buildStep3BusinessInfo();
      case 3: return _buildStep4Config();
      case 4: return _buildStep5BranchSetup();
      case 5: return _buildStep6Completion();
      default: return const SizedBox.shrink();
    }
  }

  // ── Step 1: Owner Information ──────────────────────────────────────────
  Widget _buildStep1OwnerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Restaurant Owner Account', style: AppTypography.headlineSmall),
        const SizedBox(height: 4),
        Text('Create the primary administrator and owner credentials for your restaurant brand.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Full Legal Name',
          hintText: 'e.g. Vikramaditya Roy',
          controller: _ownerNameCtrl,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Work / Owner Email',
          hintText: 'vikram@restaurant.com',
          controller: _ownerEmailCtrl,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Mobile Contact Number',
          hintText: '+91 98765 43210',
          controller: _ownerPhoneCtrl,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Secure Password',
          hintText: 'Min. 8 characters (alphanumeric)',
          controller: _passwordCtrl,
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
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(Icons.shield_outlined, size: 14, color: AppColors.successGreen),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Secured using PBKDF2 / Argon2 cryptographic salting',
                style: TextStyle(fontSize: 11, color: AppColors.mutedGrey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 2: Restaurant Information ──────────────────────────────────────
  Widget _buildStep2RestaurantInfo() {
    final types = ['Fine Dining', 'Cafe & Bakery', 'Cloud Kitchen', 'Fast Food / QSR', 'Pub & Lounge'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Restaurant Profile', style: AppTypography.headlineSmall),
        const SizedBox(height: 4),
        Text('Define your brand name, venue category, and public dining profile.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Restaurant / Brand Name',
          hintText: 'e.g. Anabhay Royal Kitchen',
          controller: _restaurantNameCtrl,
          prefixIcon: Icons.store_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Venue Category', style: AppTypography.labelMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((t) {
            final isSelected = t == _restaurantType;
            return ChoiceChip(
              label: Text(t),
              selected: isSelected,
              selectedColor: AppColors.champagneGold,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.matteBlack : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) => setState(() => _restaurantType = t),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Concept Description & Specialties',
          hintText: 'Describe your dining theme, cuisine focus, and ambiance.',
          controller: _descriptionCtrl,
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Restaurant Contact Phone',
                hintText: '+91 11 2341 5678',
                controller: _contactPhoneCtrl,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                label: 'Public Contact Email',
                hintText: 'dine@anabhay.com',
                controller: _contactEmailCtrl,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 3: Business & Tax Information ───────────────────────────────────
  Widget _buildStep3BusinessInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Business Information & Taxation', style: AppTypography.headlineSmall),
        const SizedBox(height: 4),
        Text('Enter GST and corporate registration parameters for automated tax compliance.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: AppSpacing.lg),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Is this business registered under GST?', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Enables automatic CGST + SGST tax invoice calculation on dining bills', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          value: _gstRegistered,
          activeThumbColor: AppColors.champagneGold,
          onChanged: (val) => setState(() => _gstRegistered = val),
        ),
        if (_gstRegistered) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'GSTIN (GST Number)',
                  hintText: '07AAAAA0000A1Z5',
                  controller: _gstinCtrl,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: 'PAN (Business / Owner)',
                  hintText: 'AAAAA0000A',
                  controller: _panCtrl,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Registered Business Address',
          hintText: 'Plot / Shop number, Road, Area',
          controller: _addressCtrl,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'City',
                hintText: 'New Delhi',
                controller: _cityCtrl,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppTextField(
                label: 'State',
                hintText: 'Delhi',
                controller: _stateCtrl,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppTextField(
                label: 'PIN Code',
                hintText: '110001',
                controller: _pincodeCtrl,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 4: Operating Configuration ─────────────────────────────────────
  Widget _buildStep4Config() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 4: Operational Configuration', style: AppTypography.headlineSmall),
        const SizedBox(height: 4),
        Text('Configure defaults for currency, timezone, thermal bill prefix, and GST.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Base Currency', style: TextStyle(fontSize: 12, color: AppColors.mutedGrey)),
                    const SizedBox(height: 4),
                    Text(_currency, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Operating Timezone', style: TextStyle(fontSize: 12, color: AppColors.mutedGrey)),
                    const SizedBox(height: 4),
                    Text(_timezone, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Default Food GST Rate (%)',
                hintText: '5.0',
                controller: _taxRateCtrl,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                label: 'Tax Invoice Prefix',
                hintText: 'INV-',
                controller: _invoicePrefixCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Default Language', style: AppTypography.labelMedium),
        const SizedBox(height: 6),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'English', label: Text('English')),
            ButtonSegment(value: 'Hindi', label: Text('हिंदी (Hindi)')),
            ButtonSegment(value: 'Bengali', label: Text('বাংলা (Bengali)')),
          ],
          selected: {_defaultLanguage},
          onSelectionChanged: (set) => setState(() => _defaultLanguage = set.first),
        ),
      ],
    );
  }

  // ── Step 5: Primary Branch Setup ────────────────────────────────────────
  Widget _buildStep5BranchSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 5: Setup Flagship Branch', style: AppTypography.headlineSmall),
        const SizedBox(height: 4),
        Text('Configure your initial operational outlet (additional branches can be linked anytime).',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Primary Branch Name',
          hintText: 'e.g. Connaught Place Flagship',
          controller: _branchNameCtrl,
          prefixIcon: Icons.location_city_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Branch Physical Address',
          hintText: 'Full address of the dining outlet',
          controller: _branchAddressCtrl,
          prefixIcon: Icons.place_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Branch Phone Number',
                hintText: '+91 11 2341 5678',
                controller: _branchPhoneCtrl,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                label: 'Daily Operating Hours',
                hintText: '11:00 AM - 11:30 PM',
                controller: _openingHoursCtrl,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 6: Completion & Launch ─────────────────────────────────────────
  Widget _buildStep6Completion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.successGreen),
          ),
          child: const Center(
            child: Icon(Icons.check_circle_rounded, size: 36, color: AppColors.successGreen),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Ready to Initialize Restaurant OS', style: AppTypography.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(
          'All parameters have been verified. Launching your multi-tenant instance under the Anabhay Ventures OS.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Restaurant Name', _restaurantNameCtrl.text),
              const Divider(color: AppColors.borderSubtle, height: 16),
              _buildSummaryRow('Owner Account', '${_ownerNameCtrl.text} (${_ownerEmailCtrl.text})'),
              const Divider(color: AppColors.borderSubtle, height: 16),
              _buildSummaryRow('Flagship Branch', _branchNameCtrl.text),
              const Divider(color: AppColors.borderSubtle, height: 16),
              _buildSummaryRow('Tax Configuration', _gstRegistered ? 'GST Registered (${_taxRateCtrl.text}%)' : 'Unregistered'),
              const Divider(color: AppColors.borderSubtle, height: 16),
              _buildSummaryRow('Security Protocol', 'Argon2id Hashed • Tenant Scoped'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey)),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
