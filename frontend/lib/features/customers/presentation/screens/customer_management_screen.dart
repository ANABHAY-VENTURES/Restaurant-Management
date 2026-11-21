// Anabhay Ventures — Customer Relationship & Loyalty Program Screen (CRM)
// Phase 6: Guest Directory, VIP Insights, Order Frequency, Total Spend & Loyalty Ledger

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/models/customer_models.dart';
import '../providers/customer_providers.dart';

class CustomerManagementScreen extends ConsumerStatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  ConsumerState<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends ConsumerState<CustomerManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedTierFilter = 'All Patrons';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddEditCustomerDialog([CustomerRecord? existing]) {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final birthdayCtrl = TextEditingController(text: existing?.birthday ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEditing ? 'Edit Customer Record' : 'Add New Customer Profile', style: AppTypography.headlineSmall),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textTertiary, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Divider(color: AppColors.borderSubtle, height: 20),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                  decoration: const InputDecoration(labelText: 'Customer Full Name *', isDense: true),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                        decoration: const InputDecoration(labelText: 'Phone Number *', isDense: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                        decoration: const InputDecoration(labelText: 'Email Address', isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: birthdayCtrl,
                        style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                        decoration: const InputDecoration(labelText: 'Birthday (e.g. 15 August)', isDense: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: addressCtrl,
                        style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                        decoration: const InputDecoration(labelText: 'City / Area', isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                  decoration: const InputDecoration(labelText: 'Guest Preferences & Dietary Notes (Peanuts, Table, Spices)', isDense: true),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.matteBlack,
                      ),
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final phone = phoneCtrl.text.trim();
                        if (name.isEmpty || phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Name and Phone are required!'), backgroundColor: AppColors.errorRed),
                          );
                          return;
                        }

                        if (isEditing) {
                          ref.read(customersProvider.notifier).updateCustomer(
                                existing.copyWith(
                                  name: name,
                                  phone: phone,
                                  email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                                  birthday: birthdayCtrl.text.trim().isNotEmpty ? birthdayCtrl.text.trim() : null,
                                  address: addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : null,
                                  notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                                ),
                              );
                        } else {
                          ref.read(customersProvider.notifier).addCustomerManually(
                                name: name,
                                phone: phone,
                                email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                                birthday: birthdayCtrl.text.trim().isNotEmpty ? birthdayCtrl.text.trim() : null,
                                address: addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : null,
                                notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                              );
                        }
                        Navigator.of(ctx).pop();
                      },
                      child: Text(isEditing ? 'Save Changes' : 'Create Profile'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRedeemDialog(CustomerRecord customer) {
    int pointsToRedeem = 50;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Redeem Points: ${customer.name}', style: AppTypography.titleMedium),
                const SizedBox(height: 4),
                Text('Current Balance: ${customer.loyaltyPoints} Royal Points', style: const TextStyle(fontSize: 12, color: AppColors.champagneGold, fontWeight: FontWeight.bold)),
                const Divider(color: AppColors.borderSubtle, height: 20),
                const Text('Redeem points for demo bill discount voucher:', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Points to Redeem:', style: TextStyle(fontSize: 13, color: AppColors.warmIvory)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.textTertiary),
                          onPressed: pointsToRedeem > 10 ? () => setDialogState(() => pointsToRedeem -= 10) : null,
                        ),
                        Text('$pointsToRedeem', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.champagneGold),
                          onPressed: pointsToRedeem + 10 <= customer.loyaltyPoints ? () => setDialogState(() => pointsToRedeem += 10) : null,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount Value (₹1 / pt):', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text('₹$pointsToRedeem.00', style: AppTypography.currencyMedium.copyWith(color: AppColors.successGreen)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.matteBlack,
                      ),
                      onPressed: customer.loyaltyPoints >= pointsToRedeem
                          ? () {
                              ref.read(customersProvider.notifier).redeemPoints(
                                    customerId: customer.id,
                                    pointsToRedeem: pointsToRedeem,
                                    discountValue: pointsToRedeem.toDouble(),
                                  );
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Redeemed $pointsToRedeem points for ₹$pointsToRedeem voucher!'),
                                  backgroundColor: AppColors.successGreen,
                                ),
                              );
                            }
                          : null,
                      child: const Text('Confirm Voucher'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);
    final metrics = ref.watch(customerMetricsProvider);
    final loyaltyTxs = ref.watch(loyaltyProvider);

    final filteredCustomers = customers.where((c) {
      if (_selectedTierFilter == 'VIP Guests' && !c.isVip) return false;
      if (_selectedTierFilter == 'Returning' && !c.isReturning) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = c.name.toLowerCase().contains(q);
        final matchesPhone = c.phone.toLowerCase().contains(q);
        final matchesEmail = (c.email ?? '').toLowerCase().contains(q);
        if (!matchesName && !matchesPhone && !matchesEmail) return false;
      }
      return true;
    }).toList();

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
                final isCompact = constraints.maxWidth < 700;
                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Customer CRM',
                              style: AppTypography.headlineMedium.copyWith(fontSize: 20),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.champagneGold,
                              foregroundColor: AppColors.matteBlack,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            onPressed: () => _showAddEditCustomerDialog(),
                            icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                            label: const Text('Add Guest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Guest profiles, dining history, VIP tiers & rewards', style: AppTypography.bodySmall),
                    ],
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer Relationship & Loyalty', style: AppTypography.headlineLarge, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text('Guest profiles, dining history, VIP tiers & royal rewards ledger', style: AppTypography.bodySmall, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.matteBlack,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () => _showAddEditCustomerDialog(),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('Add Customer', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Top KPI Metrics Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 175,
                    child: _buildMetricCard(
                      label: 'Total Registered Guests',
                      value: '${metrics.totalCustomers}',
                      icon: Icons.people_outline_rounded,
                      color: AppColors.champagneGold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 175,
                    child: _buildMetricCard(
                      label: 'Returning Patrons',
                      value: '${metrics.returningCustomers}',
                      icon: Icons.repeat_rounded,
                      color: AppColors.successGreen,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 175,
                    child: _buildMetricCard(
                      label: 'Total Guest Orders',
                      value: '${metrics.totalOrders}',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.copper,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 175,
                    child: _buildMetricCard(
                      label: 'Avg Spend / Patron',
                      value: '₹${metrics.averageSpendPerCustomer.toStringAsFixed(0)}',
                      icon: Icons.currency_rupee_rounded,
                      color: AppColors.warmIvory,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Navigation Tabs
            TabBar(
              controller: _tabController,
              labelColor: AppColors.champagneGold,
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: AppColors.champagneGold,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.contacts_rounded, size: 18), text: 'Guest Directory'),
                Tab(icon: Icon(Icons.stars_rounded, size: 18), text: 'VIP Insights & Spenders'),
                Tab(icon: Icon(Icons.card_giftcard_rounded, size: 18), text: 'Loyalty Points Ledger'),
              ],
            ),
            const SizedBox(height: AppSpacing.base),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDirectoryTab(filteredCustomers),
                  _buildInsightsTab(metrics),
                  _buildLoyaltyTab(loyaltyTxs, customers),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryTab(List<CustomerRecord> customers) {
    return Column(
      children: [
        // Search & Filter
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                decoration: InputDecoration(
                  hintText: 'Search guests by name, phone or email...',
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.champagneGold),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.surfaceCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderSubtle)),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: DropdownButton<String>(
                value: _selectedTierFilter,
                dropdownColor: AppColors.surfaceCard,
                underline: const SizedBox(),
                style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                items: ['All Patrons', 'VIP Guests', 'Returning'].map((r) {
                  return DropdownMenuItem(value: r, child: Text(r));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTierFilter = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Customer Cards List
        Expanded(
          child: customers.isEmpty
              ? const Center(child: Text('No customers found.', style: TextStyle(color: AppColors.textTertiary)))
              : ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final c = customers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: c.isVip ? AppColors.champagneGold.withValues(alpha: 0.5) : AppColors.borderSubtle),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 650;
                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: c.isVip ? AppColors.champagneGold.withValues(alpha: 0.2) : AppColors.surfaceElevated,
                                      child: Text(
                                        c.name.isNotEmpty ? c.name[0] : 'C',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: c.isVip ? AppColors.champagneGold : AppColors.warmIvory),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(child: Text(c.name, style: AppTypography.titleMedium, overflow: TextOverflow.ellipsis)),
                                              const SizedBox(width: 4),
                                              if (c.isVip)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.champagneGold.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(3),
                                                  ),
                                                  child: const Text('VIP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
                                                ),
                                            ],
                                          ),
                                          Text(c.phone, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceElevated,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.champagneGold),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.stars_rounded, size: 12, color: AppColors.champagneGold),
                                          const SizedBox(width: 2),
                                          Text('${c.loyaltyPoints} pts', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.champagneGold),
                                      onPressed: () => _showAddEditCustomerDialog(c),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${c.totalOrders} visits • ₹${c.totalSpend.toStringAsFixed(0)} spend', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warmIvory)),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.champagneGold,
                                        side: const BorderSide(color: AppColors.champagneGold),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        minimumSize: const Size(50, 26),
                                      ),
                                      onPressed: () => _showRedeemDialog(c),
                                      child: const Text('Redeem', style: TextStyle(fontSize: 10)),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: c.isVip ? AppColors.champagneGold.withValues(alpha: 0.2) : AppColors.surfaceElevated,
                                child: Text(
                                  c.name.isNotEmpty ? c.name[0] : 'C',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: c.isVip ? AppColors.champagneGold : AppColors.warmIvory),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(child: Text(c.name, style: AppTypography.titleMedium, overflow: TextOverflow.ellipsis)),
                                        const SizedBox(width: 8),
                                        if (c.isVip)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.champagneGold.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('VIP PATRON', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
                                          ),
                                        if (c.isReturning && !c.isVip)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.successGreen.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('RETURNING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text('${c.phone}${c.email != null ? ' • ${c.email}' : ''}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary), overflow: TextOverflow.ellipsis),
                                    if (c.notes != null && c.notes!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text('Preference: ${c.notes}', style: const TextStyle(fontSize: 10, color: AppColors.champagneGold, fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${c.totalOrders} visits • ₹${c.totalSpend.toStringAsFixed(0)} spend', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.warmIvory)),
                                    Text('Last visited: ${c.lastVisit.toLocal().toString().split(' ')[0]}', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                                  ],
                                ),
                              ),
                              // Loyalty Points
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.champagneGold),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.stars_rounded, size: 14, color: AppColors.champagneGold),
                                    const SizedBox(width: 4),
                                    Text('${c.loyaltyPoints} pts', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Redeem Button
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.champagneGold,
                                  side: const BorderSide(color: AppColors.champagneGold),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: const Size(60, 30),
                                ),
                                onPressed: () => _showRedeemDialog(c),
                                child: const Text('Redeem', style: TextStyle(fontSize: 11)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.champagneGold),
                                onPressed: () => _showAddEditCustomerDialog(c),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInsightsTab(CustomerMetrics metrics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final leftCard = Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.diamond_outlined, size: 18, color: AppColors.champagneGold),
                  SizedBox(width: 8),
                  Text('Top Spending VIP Patrons', style: AppTypography.titleMedium),
                ],
              ),
              const Divider(color: AppColors.borderSubtle, height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: metrics.topSpenders.length,
                  itemBuilder: (context, index) {
                    final c = metrics.topSpenders[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.champagneGold.withValues(alpha: 0.2),
                        child: Text('#${index + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
                      ),
                      title: Text(c.name, style: AppTypography.bodyMedium),
                      subtitle: Text('${c.totalOrders} dining sessions', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      trailing: Text(
                        '₹${c.totalSpend.toStringAsFixed(0)}',
                        style: AppTypography.currencyMedium.copyWith(color: AppColors.champagneGold),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );

        final rightCard = Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.repeat_on_rounded, size: 18, color: AppColors.copper),
                  SizedBox(width: 8),
                  Text('Most Frequent Visitors', style: AppTypography.titleMedium),
                ],
              ),
              const Divider(color: AppColors.borderSubtle, height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: metrics.mostFrequent.length,
                  itemBuilder: (context, index) {
                    final c = metrics.mostFrequent[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.copper.withValues(alpha: 0.2),
                        child: Text('#${index + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.copper)),
                      ),
                      title: Text(c.name, style: AppTypography.bodyMedium),
                      subtitle: Text(c.phone, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${c.totalOrders} Visits',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warmIvory),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );

        if (isNarrow) {
          return ListView(
            children: [
              SizedBox(height: 380, child: leftCard),
              const SizedBox(height: AppSpacing.md),
              SizedBox(height: 380, child: rightCard),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: leftCard),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: rightCard),
          ],
        );
      },
    );
  }

  Widget _buildLoyaltyTab(List<LoyaltyTransaction> txs, List<CustomerRecord> customers) {
    final custMap = {for (final c in customers) c.id: c.name};

    return txs.isEmpty
        ? const Center(child: Text('No loyalty transactions recorded yet.', style: TextStyle(color: AppColors.textTertiary)))
        : ListView.builder(
            itemCount: txs.length,
            itemBuilder: (context, index) {
              final tx = txs[index];
              final custName = custMap[tx.customerId] ?? 'Patron';
              final isEarned = tx.points > 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isEarned ? AppColors.successGreen.withValues(alpha: 0.15) : AppColors.copper.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEarned ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 16,
                        color: isEarned ? AppColors.successGreen : AppColors.copper,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$custName • ${tx.description}', style: AppTypography.bodyMedium),
                          Text('${tx.timestamp.toLocal().toString().split('.')[0]}', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                    Text(
                      '${isEarned ? '+' : ''}${tx.points} pts',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isEarned ? AppColors.successGreen : AppColors.copper,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
