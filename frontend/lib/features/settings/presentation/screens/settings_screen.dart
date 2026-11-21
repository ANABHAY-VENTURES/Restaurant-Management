// Anabhay Ventures — Complete Restaurant Settings & Profile Configuration
// Phase 7: Profile, Taxes, Receipts, POS Config, Language, Appearance, Data Backup & About

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../pos/domain/models/order_models.dart';
import '../../../pos/presentation/providers/pos_providers.dart';
import '../../domain/models/settings_models.dart';
import '../providers/settings_providers.dart';
import '../widgets/live_receipt_preview.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Profile
  late TextEditingController _nameCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _gstinCtrl;
  late TextEditingController _fssaiCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _openTimeCtrl;
  late TextEditingController _closeTimeCtrl;
  late TextEditingController _closingDayCtrl;

  // Controllers for Tax & Billing
  late TextEditingController _taxRateCtrl;
  late TextEditingController _serviceChargeCtrl;
  late TextEditingController _discountCtrl;

  // Controllers for Receipt
  late TextEditingController _invoiceTitleCtrl;
  late TextEditingController _footerMsgCtrl;
  late TextEditingController _thankYouCtrl;
  late TextEditingController _prefixCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);

    final prof = ref.read(restaurantProfileProvider);
    _nameCtrl = TextEditingController(text: prof.name);
    _taglineCtrl = TextEditingController(text: prof.tagline);
    _addressCtrl = TextEditingController(text: prof.address);
    _phoneCtrl = TextEditingController(text: prof.phone);
    _emailCtrl = TextEditingController(text: prof.email);
    _websiteCtrl = TextEditingController(text: prof.website);
    _gstinCtrl = TextEditingController(text: prof.gstin);
    _fssaiCtrl = TextEditingController(text: prof.fssai);
    _descCtrl = TextEditingController(text: prof.description);
    _openTimeCtrl = TextEditingController(text: prof.openingTime);
    _closeTimeCtrl = TextEditingController(text: prof.closingTime);
    _closingDayCtrl = TextEditingController(text: prof.weeklyClosingDay);

    final tax = ref.read(taxBillingConfigProvider);
    _taxRateCtrl = TextEditingController(text: tax.taxRatePercent.toString());
    _serviceChargeCtrl = TextEditingController(text: tax.serviceChargePercent.toString());
    _discountCtrl = TextEditingController(text: tax.defaultDiscountPercent.toString());

    final inv = ref.read(invoiceReceiptConfigProvider);
    _invoiceTitleCtrl = TextEditingController(text: inv.invoiceTitle);
    _footerMsgCtrl = TextEditingController(text: inv.footerMessage);
    _thankYouCtrl = TextEditingController(text: inv.thankYouMessage);
    _prefixCtrl = TextEditingController(text: inv.invoicePrefix);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _gstinCtrl.dispose();
    _fssaiCtrl.dispose();
    _descCtrl.dispose();
    _openTimeCtrl.dispose();
    _closeTimeCtrl.dispose();
    _closingDayCtrl.dispose();
    _taxRateCtrl.dispose();
    _serviceChargeCtrl.dispose();
    _discountCtrl.dispose();
    _invoiceTitleCtrl.dispose();
    _footerMsgCtrl.dispose();
    _thankYouCtrl.dispose();
    _prefixCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final updated = ref.read(restaurantProfileProvider).copyWith(
          name: _nameCtrl.text.trim(),
          tagline: _taglineCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          website: _websiteCtrl.text.trim(),
          gstin: _gstinCtrl.text.trim(),
          fssai: _fssaiCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          openingTime: _openTimeCtrl.text.trim(),
          closingTime: _closeTimeCtrl.text.trim(),
          weeklyClosingDay: _closingDayCtrl.text.trim(),
        );

    ref.read(restaurantProfileProvider.notifier).updateProfile(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restaurant Profile successfully updated and synchronized!'), backgroundColor: AppColors.successGreen),
    );
  }

  void _saveTaxBilling() {
    final rate = double.tryParse(_taxRateCtrl.text.trim()) ?? 5.0;
    final sc = double.tryParse(_serviceChargeCtrl.text.trim()) ?? 0.0;
    final disc = double.tryParse(_discountCtrl.text.trim()) ?? 0.0;

    final updated = ref.read(taxBillingConfigProvider).copyWith(
          taxRatePercent: rate,
          serviceChargePercent: sc,
          defaultDiscountPercent: disc,
        );

    ref.read(taxBillingConfigProvider.notifier).updateConfig(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Taxation & Billing settings saved!'), backgroundColor: AppColors.successGreen),
    );
  }

  void _saveReceiptConfig() {
    final updated = ref.read(invoiceReceiptConfigProvider).copyWith(
          invoiceTitle: _invoiceTitleCtrl.text.trim(),
          footerMessage: _footerMsgCtrl.text.trim(),
          thankYouMessage: _thankYouCtrl.text.trim(),
          invoicePrefix: _prefixCtrl.text.trim(),
        );

    ref.read(invoiceReceiptConfigProvider.notifier).updateConfig(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice & Receipt template customized!'), backgroundColor: AppColors.successGreen),
    );
  }

  void _exportDatabase() async {
    final repo = ref.read(restaurantStorageRepositoryProvider);
    final jsonStr = await repo.exportFullDatabaseJson();
    await Clipboard.setData(ClipboardData(text: jsonStr));

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 550,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Complete Backup Exported', style: AppTypography.headlineSmall),
                  IconButton(icon: const Icon(Icons.close, color: AppColors.textTertiary), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const SizedBox(height: 8),
              const Text('All system records (menu, staff, customers, profile, orders) have been exported and copied to your clipboard as JSON.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                height: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(8)),
                child: SingleChildScrollView(
                  child: Text(jsonStr, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.warmIvory)),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _importDatabase() {
    final importCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 550,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Import Database Backup', style: AppTypography.headlineSmall),
                  IconButton(icon: const Icon(Icons.close, color: AppColors.textTertiary), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Paste your exported JSON backup text below to restore all restaurant data:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextField(
                controller: importCtrl,
                maxLines: 7,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.warmIvory),
                decoration: const InputDecoration(hintText: '{\n  "version": "1.0.0",\n  "profile": ...\n}'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final text = importCtrl.text.trim();
                      if (text.isEmpty) return;
                      final repo = ref.read(restaurantStorageRepositoryProvider);
                      final success = await repo.importFullDatabaseJson(text);
                      Navigator.of(ctx).pop();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Backup restored successfully! Refreshing modules...'), backgroundColor: AppColors.successGreen),
                        );
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid backup JSON format. Import aborted.'), backgroundColor: AppColors.errorRed),
                        );
                      }
                    },
                    child: const Text('Validate & Restore'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmResetData() {
    AppDialog.show(
      context: context,
      title: 'Reset Demo Data',
      subtitle: 'Are you sure you want to restore all restaurant tables, menu items, staff, and settings to original demo factory defaults? This action cannot be undone.',
      content: const Text(
        'All orders, custom settings, and test data will be reset to the original seeds.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      confirmLabel: 'Reset Everything',
      isDestructive: true,
      onConfirm: () async {
        Navigator.of(context).pop();
        final repo = ref.read(restaurantStorageRepositoryProvider);
        await repo.resetDatabaseToDefaults();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restored factory demo defaults!'), backgroundColor: AppColors.champagneGold),
        );
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(restaurantProfileProvider);
    final taxBilling = ref.watch(taxBillingConfigProvider);
    final invoiceConfig = ref.watch(invoiceReceiptConfigProvider);
    final orderPos = ref.watch(orderPosConfigProvider);
    final tableQr = ref.watch(tableQrConfigProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 650;
                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Restaurant Settings', style: AppTypography.headlineMedium.copyWith(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text(profile.name, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Restaurant & System Settings', style: AppTypography.headlineLarge),
                        const SizedBox(height: 2),
                        Text('${profile.name} • Master branding, taxation, receipts, language & appearance', style: AppTypography.bodySmall),
                      ],
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.champagneGold,
                        side: const BorderSide(color: AppColors.champagneGold),
                      ),
                      onPressed: () => context.go('/qr-codes'),
                      icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                      label: const Text('View Standees'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Tab Bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.champagneGold,
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: AppColors.champagneGold,
              tabs: const [
                Tab(icon: Icon(Icons.storefront_rounded, size: 18), text: 'Restaurant Profile'),
                Tab(icon: Icon(Icons.receipt_long_rounded, size: 18), text: 'Tax & Billing'),
                Tab(icon: Icon(Icons.receipt_rounded, size: 18), text: 'Receipt & Invoices'),
                Tab(icon: Icon(Icons.point_of_sale_rounded, size: 18), text: 'Orders & POS'),
                Tab(icon: Icon(Icons.table_restaurant_rounded, size: 18), text: 'Tables & QR'),
                Tab(icon: Icon(Icons.palette_outlined, size: 18), text: 'Theme & Language'),
                Tab(icon: Icon(Icons.storage_rounded, size: 18), text: 'Backup & About'),
              ],
            ),
            const SizedBox(height: AppSpacing.base),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProfileTab(profile),
                  _buildTaxBillingTab(taxBilling),
                  _buildReceiptsTab(profile, taxBilling, invoiceConfig),
                  _buildOrderPosTab(orderPos),
                  _buildTableQrTab(tableQr),
                  _buildThemeLanguageTab(themeMode, locale, loc),
                  _buildBackupAboutTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(RestaurantProfile profile) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Brand Identity & Restaurant Profile', style: AppTypography.titleMedium),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.champagneGold,
                      foregroundColor: AppColors.matteBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: const Text('Save Profile Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Changes update immediately across Dashboard, Table QR Menus, KOT receipts, and PDF Invoices.', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              const Divider(color: AppColors.borderSubtle, height: 24),

              // Logo & Banner Preview
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.champagneGold, width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.restaurant_rounded, size: 36, color: AppColors.champagneGold),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.name, style: AppTypography.headlineSmall),
                        Text(profile.tagline, style: const TextStyle(fontSize: 12, color: AppColors.champagneGold)),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.champagneGold,
                            side: const BorderSide(color: AppColors.champagneGold),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Avatar selection updated!'), backgroundColor: AppColors.champagneGold),
                            );
                          },
                          icon: const Icon(Icons.upload_rounded, size: 14),
                          label: const Text('Upload Brand Emblem', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form fields
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 650;
                  if (isNarrow) {
                    return Column(
                      children: [
                        TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Restaurant Name *')),
                        const SizedBox(height: 16),
                        TextField(controller: _taglineCtrl, decoration: const InputDecoration(labelText: 'Culinary Tagline / Cuisine')),
                        const SizedBox(height: 16),
                        TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Full Physical Address *')),
                        const SizedBox(height: 16),
                        TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Contact Phone Number *')),
                        const SizedBox(height: 16),
                        TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Official Email *')),
                        const SizedBox(height: 16),
                        TextField(controller: _websiteCtrl, decoration: const InputDecoration(labelText: 'Website / Web Menu URL')),
                        const SizedBox(height: 16),
                        TextField(controller: _gstinCtrl, decoration: const InputDecoration(labelText: 'GSTIN Registration (Optional)')),
                        const SizedBox(height: 16),
                        TextField(controller: _fssaiCtrl, decoration: const InputDecoration(labelText: 'FSSAI License No. (Optional)')),
                        const SizedBox(height: 16),
                        TextField(controller: _openTimeCtrl, decoration: const InputDecoration(labelText: 'Daily Opening Hours (e.g. 11:00 AM)')),
                        const SizedBox(height: 16),
                        TextField(controller: _closeTimeCtrl, decoration: const InputDecoration(labelText: 'Closing Hours (e.g. 11:30 PM)')),
                        const SizedBox(height: 16),
                        TextField(controller: _closingDayCtrl, decoration: const InputDecoration(labelText: 'Weekly Closing Day (e.g. Open 7 Days)')),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Restaurant Name *'))),
                          const SizedBox(width: 16),
                          Expanded(child: TextField(controller: _taglineCtrl, decoration: const InputDecoration(labelText: 'Culinary Tagline / Cuisine'))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Full Physical Address *')),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Contact Phone Number *'))),
                          const SizedBox(width: 16),
                          Expanded(child: TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Official Email *'))),
                          const SizedBox(width: 16),
                          Expanded(child: TextField(controller: _websiteCtrl, decoration: const InputDecoration(labelText: 'Website / Web Menu URL'))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _gstinCtrl, decoration: const InputDecoration(labelText: 'GSTIN Registration (Optional)'))),
                          const SizedBox(width: 16),
                          Expanded(child: TextField(controller: _fssaiCtrl, decoration: const InputDecoration(labelText: 'FSSAI License No. (Optional)'))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _openTimeCtrl, decoration: const InputDecoration(labelText: 'Daily Opening Hours (e.g. 11:00 AM)'))),
                          const SizedBox(width: 16),
                          Expanded(child: TextField(controller: _closeTimeCtrl, decoration: const InputDecoration(labelText: 'Closing Hours (e.g. 11:30 PM)'))),
                          const SizedBox(width: 16),
                          Expanded(child: TextField(controller: _closingDayCtrl, decoration: const InputDecoration(labelText: 'Weekly Closing Day (e.g. Open 7 Days)'))),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Restaurant Story & Culinary Description'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaxBillingTab(TaxBillingConfig tax) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Goods & Services Tax (GST) & Billing Engine', style: AppTypography.titleMedium),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.champagneGold, foregroundColor: AppColors.matteBlack),
                    onPressed: _saveTaxBilling,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: const Text('Save Tax Config'),
                  ),
                ],
              ),
              const Divider(color: AppColors.borderSubtle, height: 24),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable GST Tax Calculations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.warmIvory)),
                subtitle: const Text('When disabled, zero tax is added to dining checks.', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                value: tax.isGstEnabled,
                activeThumbColor: AppColors.champagneGold,
                onChanged: (val) {
                  ref.read(taxBillingConfigProvider.notifier).updateConfig(tax.copyWith(isGstEnabled: val));
                },
              ),
              const SizedBox(height: 12),

              // Presets
              const Text('Indian Restaurant GST Presets:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('5.0% Composite (2.5% CGST + 2.5% SGST)'),
                    selected: tax.taxRatePercent == 5.0,
                    selectedColor: AppColors.champagneGold,
                    labelStyle: TextStyle(
                      color: tax.taxRatePercent == 5.0 ? AppColors.matteBlack : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    onSelected: (_) {
                      _taxRateCtrl.text = '5.0';
                      ref.read(taxBillingConfigProvider.notifier).updateConfig(tax.copyWith(taxRatePercent: 5.0));
                    },
                  ),
                  ChoiceChip(
                    label: const Text('12.0% GST'),
                    selected: tax.taxRatePercent == 12.0,
                    selectedColor: AppColors.champagneGold,
                    labelStyle: TextStyle(
                      color: tax.taxRatePercent == 12.0 ? AppColors.matteBlack : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    onSelected: (_) {
                      _taxRateCtrl.text = '12.0';
                      ref.read(taxBillingConfigProvider.notifier).updateConfig(tax.copyWith(taxRatePercent: 12.0));
                    },
                  ),
                  ChoiceChip(
                    label: const Text('18.0% GST'),
                    selected: tax.taxRatePercent == 18.0,
                    selectedColor: AppColors.champagneGold,
                    labelStyle: TextStyle(
                      color: tax.taxRatePercent == 18.0 ? AppColors.matteBlack : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    onSelected: (_) {
                      _taxRateCtrl.text = '18.0';
                      ref.read(taxBillingConfigProvider.notifier).updateConfig(tax.copyWith(taxRatePercent: 18.0));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taxRateCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Total Tax Rate % (Split equally into CGST & SGST)'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _serviceChargeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Optional Service Charge % (Default: 0%)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tax-Inclusive Menu Pricing', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.warmIvory)),
                subtitle: const Text('Prices on menu already include applicable GST taxes.', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                value: tax.isTaxInclusive,
                activeThumbColor: AppColors.champagneGold,
                onChanged: (val) {
                  ref.read(taxBillingConfigProvider.notifier).updateConfig(tax.copyWith(isTaxInclusive: val));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptsTab(RestaurantProfile profile, TaxBillingConfig taxBilling, InvoiceReceiptConfig inv) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;
        final leftControls = Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Receipt Layout & Header Details', style: AppTypography.titleMedium),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.champagneGold, foregroundColor: AppColors.matteBlack),
                    onPressed: _saveReceiptConfig,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: const Text('Save Template'),
                  ),
                ],
              ),
              const Divider(color: AppColors.borderSubtle, height: 20),

              TextField(controller: _invoiceTitleCtrl, decoration: const InputDecoration(labelText: 'Bill / Receipt Title (e.g. TAX INVOICE)')),
              const SizedBox(height: 12),
              TextField(controller: _prefixCtrl, decoration: const InputDecoration(labelText: 'Invoice Serial Prefix (e.g. INV-2026-)')),
              const SizedBox(height: 12),
              TextField(controller: _thankYouCtrl, decoration: const InputDecoration(labelText: 'Thank You Message')),
              const SizedBox(height: 12),
              TextField(controller: _footerMsgCtrl, decoration: const InputDecoration(labelText: 'Footer Legal Note / Policy')),
              const SizedBox(height: 16),

              const Text('Content Visibility Toggles:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              _buildReceiptSwitch('Show Restaurant Logo', inv.showLogo, (v) => ref.read(invoiceReceiptConfigProvider.notifier).updateConfig(inv.copyWith(showLogo: v))),
              _buildReceiptSwitch('Show Restaurant Name', inv.showRestaurantName, (v) => ref.read(invoiceReceiptConfigProvider.notifier).updateConfig(inv.copyWith(showRestaurantName: v))),
              _buildReceiptSwitch('Show Address & Telephone', inv.showAddressContact, (v) => ref.read(invoiceReceiptConfigProvider.notifier).updateConfig(inv.copyWith(showAddressContact: v))),
              _buildReceiptSwitch('Show GSTIN Registration', inv.showGstin, (v) => ref.read(invoiceReceiptConfigProvider.notifier).updateConfig(inv.copyWith(showGstin: v))),
              _buildReceiptSwitch('Show FSSAI License Number', inv.showFssai, (v) => ref.read(invoiceReceiptConfigProvider.notifier).updateConfig(inv.copyWith(showFssai: v))),
              _buildReceiptSwitch('Show Customer Name & Phone', inv.showCustomerDetails, (v) => ref.read(invoiceReceiptConfigProvider.notifier).updateConfig(inv.copyWith(showCustomerDetails: v))),
              _buildReceiptSwitch('Show Itemised Tax Breakdown', inv.showTaxBreakdown, (v) => ref.read(invoiceReceiptConfigProvider.notifier).updateConfig(inv.copyWith(showTaxBreakdown: v))),
            ],
          ),
        );

        final rightPreview = LiveReceiptPreview(
          profile: profile,
          taxBilling: taxBilling,
          invoiceConfig: inv,
        );

        if (isNarrow) {
          return ListView(
            children: [
              leftControls,
              const SizedBox(height: AppSpacing.md),
              rightPreview,
            ],
          );
        }

        return ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: leftControls),
                const SizedBox(width: AppSpacing.md),
                Expanded(flex: 4, child: rightPreview),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.warmIvory)),
      value: value,
      activeThumbColor: AppColors.champagneGold,
      onChanged: onChanged,
    );
  }

  Widget _buildOrderPosTab(OrderPosConfig pos) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('POS Operations & Order Numbering', style: AppTypography.titleMedium),
              const Divider(color: AppColors.borderSubtle, height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable Dine-In Orders', style: TextStyle(fontSize: 13, color: AppColors.warmIvory, fontWeight: FontWeight.bold)),
                subtitle: const Text('Allow table-linked dine-in billing in POS.', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                value: pos.isDineInEnabled,
                activeThumbColor: AppColors.champagneGold,
                onChanged: (v) => ref.read(orderPosConfigProvider.notifier).updateConfig(pos.copyWith(isDineInEnabled: v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable Takeaway Orders', style: TextStyle(fontSize: 13, color: AppColors.warmIvory, fontWeight: FontWeight.bold)),
                subtitle: const Text('Allow quick takeaway counter tickets.', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                value: pos.isTakeawayEnabled,
                activeThumbColor: AppColors.champagneGold,
                onChanged: (v) => ref.read(orderPosConfigProvider.notifier).updateConfig(pos.copyWith(isTakeawayEnabled: v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable Customer QR Mobile Ordering', style: TextStyle(fontSize: 13, color: AppColors.warmIvory, fontWeight: FontWeight.bold)),
                subtitle: const Text('Guests can order directly from table QR codes.', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                value: pos.isCustomerQrOrderingEnabled,
                activeThumbColor: AppColors.champagneGold,
                onChanged: (v) => ref.read(orderPosConfigProvider.notifier).updateConfig(pos.copyWith(isCustomerQrOrderingEnabled: v)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: pos.defaultPaymentMethod,
                      dropdownColor: AppColors.surfaceCard,
                      decoration: const InputDecoration(labelText: 'Default Payment Method'),
                      items: ['Demo Cash', 'Demo UPI', 'Demo Card'].map((m) {
                        return DropdownMenuItem(value: m, child: Text(m));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) ref.read(orderPosConfigProvider.notifier).updateConfig(pos.copyWith(defaultPaymentMethod: v));
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<OrderType>(
                      value: pos.defaultOrderType,
                      dropdownColor: AppColors.surfaceCard,
                      decoration: const InputDecoration(labelText: 'Default Order Mode'),
                      items: OrderType.values.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.label));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) ref.read(orderPosConfigProvider.notifier).updateConfig(pos.copyWith(defaultOrderType: v));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableQrTab(TableQrConfig tableQr) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Table Floor Plan & QR Settings', style: AppTypography.titleMedium),
              const Divider(color: AppColors.borderSubtle, height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;
                  if (isNarrow) {
                    return Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: tableQr.tableNamingFormat,
                          dropdownColor: AppColors.surfaceCard,
                          decoration: const InputDecoration(labelText: 'Table Display Naming'),
                          items: ['Table {number}', 'T-{number}'].map((f) {
                            return DropdownMenuItem(value: f, child: Text(f));
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) ref.read(tableQrConfigProvider.notifier).updateConfig(tableQr.copyWith(tableNamingFormat: v));
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: tableQr.defaultCapacity,
                          dropdownColor: AppColors.surfaceCard,
                          decoration: const InputDecoration(labelText: 'Default Table Capacity'),
                          items: [2, 4, 6, 8, 12].map((c) {
                            return DropdownMenuItem(value: c, child: Text('$c Guests'));
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) ref.read(tableQrConfigProvider.notifier).updateConfig(tableQr.copyWith(defaultCapacity: v));
                          },
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: tableQr.tableNamingFormat,
                          dropdownColor: AppColors.surfaceCard,
                          decoration: const InputDecoration(labelText: 'Table Display Naming'),
                          items: ['Table {number}', 'T-{number}'].map((f) {
                            return DropdownMenuItem(value: f, child: Text(f));
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) ref.read(tableQrConfigProvider.notifier).updateConfig(tableQr.copyWith(tableNamingFormat: v));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: tableQr.defaultCapacity,
                          dropdownColor: AppColors.surfaceCard,
                          decoration: const InputDecoration(labelText: 'Default Table Capacity'),
                          items: [2, 4, 6, 8, 12].map((c) {
                            return DropdownMenuItem(value: c, child: Text('$c Guests'));
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) ref.read(tableQrConfigProvider.notifier).updateConfig(tableQr.copyWith(defaultCapacity: v));
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.champagneGold, foregroundColor: AppColors.matteBlack),
                onPressed: () => context.go('/qr-codes'),
                icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                label: const Text('Manage Table QR Codes & Printable Standees'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeLanguageTab(ThemeMode themeMode, Locale locale, AppLocalizations loc) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Language & Multi-Lingual Support', style: AppTypography.titleMedium),
              const SizedBox(height: 4),
              const Text('Full interface translations for English, Hindi (हिन्दी), and Bengali (বাংলা).', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              const Divider(color: AppColors.borderSubtle, height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('English (EN)'),
                    selected: locale.languageCode == 'en',
                    selectedColor: AppColors.champagneGold,
                    labelStyle: TextStyle(
                      color: locale.languageCode == 'en' ? AppColors.matteBlack : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => ref.read(appLocaleProvider.notifier).setLocale(const Locale('en')),
                  ),
                  ChoiceChip(
                    label: const Text('हिन्दी (Hindi)'),
                    selected: locale.languageCode == 'hi',
                    selectedColor: AppColors.champagneGold,
                    labelStyle: TextStyle(
                      color: locale.languageCode == 'hi' ? AppColors.matteBlack : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => ref.read(appLocaleProvider.notifier).setLocale(const Locale('hi')),
                  ),
                  ChoiceChip(
                    label: const Text('বাংলা (Bengali)'),
                    selected: locale.languageCode == 'bn',
                    selectedColor: AppColors.champagneGold,
                    labelStyle: TextStyle(
                      color: locale.languageCode == 'bn' ? AppColors.matteBlack : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => ref.read(appLocaleProvider.notifier).setLocale(const Locale('bn')),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const Text('Appearance & Theme Palette', style: AppTypography.titleMedium),
              const SizedBox(height: 4),
              const Text('High-contrast luxury theme maintaining Anabhay Ventures brand identity.', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              const Divider(color: AppColors.borderSubtle, height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    avatar: const Icon(Icons.dark_mode_rounded, size: 16),
                    label: const Text('Matte Black Dark Theme'),
                    selected: themeMode == ThemeMode.dark,
                    selectedColor: AppColors.champagneGold,
                    labelStyle: TextStyle(
                      color: themeMode == ThemeMode.dark ? AppColors.matteBlack : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.light_mode_rounded, size: 16),
                    label: const Text('Warm Ivory Light Theme'),
                    selected: themeMode == ThemeMode.light,
                    selectedColor: AppColors.champagneGold,
                    labelStyle: TextStyle(
                      color: themeMode == ThemeMode.light ? AppColors.matteBlack : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.settings_brightness_rounded, size: 16),
                    label: const Text('System Auto'),
                    selected: themeMode == ThemeMode.system,
                    selectedColor: AppColors.champagneGold,
                    labelStyle: TextStyle(
                      color: themeMode == ThemeMode.system ? AppColors.matteBlack : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackupAboutTab() {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Local Data Management & Backup', style: AppTypography.titleMedium),
              const SizedBox(height: 4),
              const Text('Export full application database as portable JSON or restore demo factory defaults.', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              const Divider(color: AppColors.borderSubtle, height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.champagneGold, foregroundColor: AppColors.matteBlack),
                    onPressed: _exportDatabase,
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Export JSON Backup'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.warmIvory, side: const BorderSide(color: AppColors.borderSubtle)),
                    onPressed: _importDatabase,
                    icon: const Icon(Icons.upload_file_rounded, size: 16),
                    label: const Text('Import Backup File'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceElevated, foregroundColor: AppColors.errorRed, side: const BorderSide(color: AppColors.errorRed)),
                    onPressed: _confirmResetData,
                    icon: const Icon(Icons.restore_rounded, size: 16),
                    label: const Text('Reset Demo Defaults'),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const Text('About Application', style: AppTypography.titleMedium),
              const Divider(color: AppColors.borderSubtle, height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surfaceElevated, shape: BoxShape.circle, border: Border.all(color: AppColors.champagneGold)),
                    child: const Icon(Icons.restaurant_rounded, size: 28, color: AppColors.champagneGold),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Restaurant Management Platform', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.warmIvory)),
                        Text('Developed by Anabhay Ventures • Enterprise Client Demonstration Prototype', style: TextStyle(fontSize: 11, color: AppColors.champagneGold)),
                        Text('Version 1.0.0 (Phase 7: Full System Suite) • Powered by Flutter & Dart', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '© 2026 Anabhay Ventures. All rights reserved. Built with unified Riverpod architecture, local persistent storage, instant KDS synchronization, automated recipe deduction, mobile-first guest QR ordering, CRM loyalty rewards, and financial auditing.',
                style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
