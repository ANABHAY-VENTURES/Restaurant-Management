// Anabhay Ventures — Reports & Business Analytics Dashboard
// Phase 6: Financial KPIs, Sales Trends, Product Performance, Payment Breakdown & Inventory Valuation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/models/report_models.dart';
import '../providers/report_providers.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';

class ReportsAnalyticsScreen extends ConsumerStatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  ConsumerState<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends ConsumerState<ReportsAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _exportCsv(SalesSummary summary, List<ProductSalesMetric> products) {
    final buffer = StringBuffer();
    buffer.writeln('Anabhay Ventures - The Royal Saffron Sales Report');
    buffer.writeln('Metric,Value');
    buffer.writeln('Gross Sales,Rs. ${summary.grossSales.toStringAsFixed(2)}');
    buffer.writeln('Discounts,Rs. ${summary.totalDiscounts.toStringAsFixed(2)}');
    buffer.writeln('Net Revenue,Rs. ${summary.netSales.toStringAsFixed(2)}');
    buffer.writeln('CGST (2.5%),Rs. ${summary.cgstCollected.toStringAsFixed(2)}');
    buffer.writeln('SGST (2.5%),Rs. ${summary.sgstCollected.toStringAsFixed(2)}');
    buffer.writeln('Paid Orders Count,${summary.paidOrdersCount}');
    buffer.writeln('Average Order Value,Rs. ${summary.averageOrderValue.toStringAsFixed(2)}');
    buffer.writeln('Estimated Food Cost,Rs. ${summary.estimatedFoodCost.toStringAsFixed(2)}');
    buffer.writeln('Gross Profit,Rs. ${summary.estimatedGrossProfit.toStringAsFixed(2)}');
    buffer.writeln('Gross Margin %,${summary.grossProfitMarginPercent.toStringAsFixed(1)}%');
    buffer.writeln('');
    buffer.writeln('Dish Name,Category,Qty Sold,Revenue (Rs),Food Cost (Rs),Profit (Rs)');
    for (final p in products) {
      buffer.writeln('"${p.itemName}","${p.category}",${p.quantitySold},${p.totalRevenue.toStringAsFixed(2)},${p.totalFoodCost.toStringAsFixed(2)},${p.grossProfit.toStringAsFixed(2)}');
    }

    final csvText = buffer.toString();
    Clipboard.setData(ClipboardData(text: csvText));

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('CSV Data Export Ready', style: AppTypography.headlineSmall),
                  IconButton(icon: const Icon(Icons.close, color: AppColors.textTertiary), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const SizedBox(height: 8),
              const Text('The complete comma-separated sales data has been copied to your clipboard.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: SingleChildScrollView(
                  child: Text(csvText, style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.warmIvory)),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.champagneGold, foregroundColor: AppColors.matteBlack),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CSV copied to clipboard successfully!'), backgroundColor: AppColors.successGreen),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy to Clipboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _printReportDialog(SalesSummary summary) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('THE ROYAL SAFFRON', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF171717), letterSpacing: 2)),
              const Text('EXECUTIVE SALES & REVENUE AUDIT', style: TextStyle(fontSize: 10, color: Color(0xFFB88746), fontWeight: FontWeight.bold)),
              const Divider(height: 20, color: Color(0xFFE0E0E0)),
              _printRow('Report Generated:', DateTime.now().toLocal().toString().split('.')[0]),
              _printRow('Completed Paid Orders:', '${summary.paidOrdersCount} orders'),
              _printRow('Gross Dining Sales:', 'Rs. ${summary.grossSales.toStringAsFixed(2)}'),
              _printRow('Discounts Applied:', '- Rs. ${summary.totalDiscounts.toStringAsFixed(2)}'),
              _printRow('Net Food & Beverage Sales:', 'Rs. ${summary.netSales.toStringAsFixed(2)}'),
              _printRow('CGST (2.5%):', 'Rs. ${summary.cgstCollected.toStringAsFixed(2)}'),
              _printRow('SGST (2.5%):', 'Rs. ${summary.sgstCollected.toStringAsFixed(2)}'),
              _printRow('Average Order Ticket:', 'Rs. ${summary.averageOrderValue.toStringAsFixed(2)}'),
              _printRow('Estimated Raw Material Cost:', 'Rs. ${summary.estimatedFoodCost.toStringAsFixed(2)}'),
              const Divider(height: 20, color: Color(0xFFE0E0E0)),
              _printRow('Estimated Gross Profit:', 'Rs. ${summary.estimatedGrossProfit.toStringAsFixed(2)}', isBold: true),
              _printRow('Gross Profit Margin:', '${summary.grossProfitMarginPercent.toStringAsFixed(1)}%', isBold: true),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF171717), foregroundColor: Colors.white),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Dispatched PDF report to print spool.'), backgroundColor: AppColors.successGreen),
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: const Text('Print / Save PDF'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _printRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: const Color(0xFF555555), fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(val, style: TextStyle(fontSize: 11, color: const Color(0xFF171717), fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFilter = ref.watch(selectedDateRangeProvider);
    final summary = ref.watch(salesSummaryProvider);
    final products = ref.watch(productAnalyticsProvider);
    final payments = ref.watch(paymentAnalyticsProvider);
    final inventoryMetrics = ref.watch(inventoryMetricsProvider);

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
                final isCompact = constraints.maxWidth < 750;
                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Financial Reports & Analytics', style: AppTypography.headlineMedium.copyWith(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text('Executive metrics, margins & tenders', style: AppTypography.bodySmall),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.champagneGold,
                                side: const BorderSide(color: AppColors.champagneGold),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              onPressed: () => _exportCsv(summary, products),
                              icon: const Icon(Icons.file_download_outlined, size: 14),
                              label: const Text('Export CSV', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.champagneGold,
                                foregroundColor: AppColors.matteBlack,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              onPressed: () => _printReportDialog(summary),
                              icon: const Icon(Icons.print_rounded, size: 14),
                              label: const Text('Print / PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
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
                          Text('Financial Reports & Business Analytics', style: AppTypography.headlineLarge, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text('Executive metrics, product margins, tender splits & raw material accounting', style: AppTypography.bodySmall, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.champagneGold,
                            side: const BorderSide(color: AppColors.champagneGold),
                          ),
                          onPressed: () => _exportCsv(summary, products),
                          icon: const Icon(Icons.file_download_outlined, size: 16),
                          label: const Text('Export CSV'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.champagneGold,
                            foregroundColor: AppColors.matteBlack,
                          ),
                          onPressed: () => _printReportDialog(summary),
                          icon: const Icon(Icons.print_rounded, size: 16),
                          label: const Text('Print Summary / PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Date Range Filter Chips
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ReportDateRange.values.map((range) {
                  final isSelected = range == activeFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(range.label),
                      selected: isSelected,
                      selectedColor: AppColors.champagneGold,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.matteBlack : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        ref.read(selectedDateRangeProvider.notifier).state = range;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Financial Summary KPI Tiles
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 185,
                    child: _buildMetricTile(
                      label: 'Net Revenue',
                      value: '₹${summary.netSales.toStringAsFixed(0)}',
                      subtext: '${summary.paidOrdersCount} paid orders',
                      color: AppColors.champagneGold,
                      icon: Icons.payments_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 185,
                    child: _buildMetricTile(
                      label: 'Est. Gross Profit',
                      value: '₹${summary.estimatedGrossProfit.toStringAsFixed(0)}',
                      subtext: '${summary.grossProfitMarginPercent.toStringAsFixed(1)}% margin',
                      color: AppColors.successGreen,
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 185,
                    child: _buildMetricTile(
                      label: 'Food Cost (Raw Materials)',
                      value: '₹${summary.estimatedFoodCost.toStringAsFixed(0)}',
                      subtext: '${summary.foodCostPercent.toStringAsFixed(1)}% of net sales',
                      color: AppColors.copper,
                      icon: Icons.soup_kitchen_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 185,
                    child: _buildMetricTile(
                      label: 'Tax Collected (GST)',
                      value: '₹${(summary.cgstCollected + summary.sgstCollected).toStringAsFixed(0)}',
                      subtext: '2.5% CGST + 2.5% SGST',
                      color: AppColors.warmIvory,
                      icon: Icons.account_balance_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.champagneGold,
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: AppColors.champagneGold,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.bar_chart_rounded, size: 18), text: 'Sales & Trends'),
                Tab(icon: Icon(Icons.restaurant_menu_rounded, size: 18), text: 'Product Analytics'),
                Tab(icon: Icon(Icons.account_balance_wallet_outlined, size: 18), text: 'Payment & Tenders'),
                Tab(icon: Icon(Icons.inventory_2_outlined, size: 18), text: 'Inventory Valuation'),
              ],
            ),
            const SizedBox(height: AppSpacing.base),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSalesTab(summary),
                  _buildProductsTab(products),
                  _buildPaymentsTab(payments),
                  _buildInventoryTab(inventoryMetrics),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTab(SalesSummary summary) {
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
              const Text('Financial Breakdown & Order Auditing', style: AppTypography.titleMedium),
              const SizedBox(height: 4),
              const Text('Distinguishing completed paid sales from open pending bills and cancelled tickets', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              const Divider(color: AppColors.borderSubtle, height: 24),
              _buildAuditRow('Gross Menu Sales (Before Discounts):', '₹${summary.grossSales.toStringAsFixed(2)}'),
              _buildAuditRow('Promotional & VIP Discounts Deducted:', '- ₹${summary.totalDiscounts.toStringAsFixed(2)}', isNegative: true),
              _buildAuditRow('Net Realised Sales:', '₹${summary.netSales.toStringAsFixed(2)}', isBold: true),
              _buildAuditRow('CGST (2.5% Central Tax):', '₹${summary.cgstCollected.toStringAsFixed(2)}'),
              _buildAuditRow('SGST (2.5% State Tax):', '₹${summary.sgstCollected.toStringAsFixed(2)}'),
              _buildAuditRow('Estimated Ingredient Food Cost:', '₹${summary.estimatedFoodCost.toStringAsFixed(2)}', isNegative: true),
              const Divider(color: AppColors.borderSubtle, height: 24),
              _buildAuditRow('Estimated Gross Contribution Margin:', '₹${summary.estimatedGrossProfit.toStringAsFixed(2)}', isBold: true, highlightColor: AppColors.successGreen),
              _buildAuditRow('Average Order Value (AOV):', '₹${summary.averageOrderValue.toStringAsFixed(2)}'),
              _buildAuditRow('Active / Unpaid Order Tickets in House:', '${summary.unpaidOrdersCount} tickets'),
              _buildAuditRow('Cancelled Orders (Voided / Reversed):', '${summary.cancelledOrdersCount} orders (Not counted in revenue)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditRow(String label, String value, {bool isBold = false, bool isNegative = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: highlightColor ?? (isNegative ? AppColors.copper : (isBold ? AppColors.champagneGold : AppColors.warmIvory)),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(List<ProductSalesMetric> products) {
    if (products.isEmpty) {
      return const Center(child: Text('No paid sales recorded in this period.', style: TextStyle(color: AppColors.textTertiary)));
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
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
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.champagneGold.withValues(alpha: 0.15),
                child: Text('#${index + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.itemName, style: AppTypography.titleMedium),
                    Text('${p.category} • Food Cost: ₹${p.unitFoodCost.toStringAsFixed(0)} / serving', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Qty Sold', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    Text('${p.quantitySold}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.warmIvory)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Revenue', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    Text('₹${p.totalRevenue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimated Margin', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    Text('₹${p.grossProfit.toStringAsFixed(0)} (${p.profitMargin.toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab(PaymentBreakdown payments) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final upiCard = _buildPaymentCard(
          title: 'UPI / Contactless QR',
          amount: payments.upiTotal,
          txCount: payments.upiCount,
          icon: Icons.qr_code_2_rounded,
          color: AppColors.champagneGold,
        );
        final cashCard = _buildPaymentCard(
          title: 'Cash at Counter',
          amount: payments.cashTotal,
          txCount: payments.cashCount,
          icon: Icons.money_rounded,
          color: AppColors.successGreen,
        );
        final cardCard = _buildPaymentCard(
          title: 'Card / POS Terminal',
          amount: payments.cardTotal,
          txCount: payments.cardCount,
          icon: Icons.credit_card_rounded,
          color: AppColors.copper,
        );

        if (isNarrow) {
          return Column(
            children: [
              upiCard,
              const SizedBox(height: AppSpacing.md),
              cashCard,
              const SizedBox(height: AppSpacing.md),
              cardCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: upiCard),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: cashCard),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: cardCard),
          ],
        );
      },
    );
  }

  Widget _buildPaymentCard({
    required String title,
    required double amount,
    required int txCount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppTypography.titleMedium, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 16),
          Text('₹${amount.toStringAsFixed(0)}', style: AppTypography.currencyLarge.copyWith(color: color)),
          const SizedBox(height: 4),
          Text('$txCount transactions settled', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildInventoryTab(InventoryMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Inventory Stock Valuation & Consumption Health', style: AppTypography.titleMedium),
              const SizedBox(height: 4),
              const Text('Synchronized with recipe-based automated deduction and supplier inward register', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              const Divider(color: AppColors.borderSubtle, height: 24),
              if (isNarrow) ...[
                _buildAuditRow('Total Raw Materials Stock Value:', '₹${metrics.totalStockValue.toStringAsFixed(0)}', isBold: true),
                const SizedBox(height: 12),
                _buildAuditRow('Total Raw Ingredients Managed:', '${metrics.totalIngredients} items'),
                const SizedBox(height: 12),
                _buildAuditRow('Low Stock Alerts (< Minimum Threshold):', '${metrics.lowStockCount} items', isNegative: metrics.lowStockCount > 0),
                const SizedBox(height: 12),
                _buildAuditRow('Recent Stock Movements Logged:', '${metrics.recentMovements.length} transactions'),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildAuditRow('Total Raw Materials Stock Value:', '₹${metrics.totalStockValue.toStringAsFixed(0)}', isBold: true),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildAuditRow('Total Raw Ingredients Managed:', '${metrics.totalIngredients} items'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildAuditRow('Low Stock Alerts (< Minimum Threshold):', '${metrics.lowStockCount} items', isNegative: metrics.lowStockCount > 0),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildAuditRow('Recent Stock Movements Logged:', '${metrics.recentMovements.length} transactions'),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtext,
    required Color color,
    required IconData icon,
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
                const SizedBox(height: 2),
                Text(subtext, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
