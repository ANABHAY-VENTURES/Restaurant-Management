// Anabhay Ventures — Restaurant Owner Dashboard Screen
// DEMO DATA is clearly labelled. All widgets will connect to real APIs in later phases.

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/dashboard_demo_data.dart';
import '../widgets/sales_chart.dart';
import '../widgets/kitchen_queue_card.dart';
import '../widgets/best_sellers_table.dart';
import '../widgets/recent_transactions_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 720 && screenWidth < 1100;

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────
            _buildHeader(context),
            const SizedBox(height: AppSpacing.xl),

            // ── DEMO NOTICE ──────────────────────────────
            _buildDemoNotice(),
            const SizedBox(height: AppSpacing.xl),

            // ── Metric Cards ─────────────────────────────
            _buildMetricsGrid(isDesktop, isTablet),
            const SizedBox(height: AppSpacing.xl),

            // ── Charts + Kitchen Queue ───────────────────
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: SalesChart(data: DashboardDemoData.hourlySales),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    flex: 2,
                    child: KitchenQueueCard(tickets: DashboardDemoData.kitchenQueue),
                  ),
                ],
              )
            else ...[
              SalesChart(data: DashboardDemoData.hourlySales),
              const SizedBox(height: AppSpacing.base),
              KitchenQueueCard(tickets: DashboardDemoData.kitchenQueue),
            ],

            const SizedBox(height: AppSpacing.xl),

            // ── Best Sellers + Transactions ──────────────
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: BestSellersTable(items: DashboardDemoData.bestSellers),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    flex: 2,
                    child: RecentTransactionsCard(
                      transactions: DashboardDemoData.recentTransactions,
                    ),
                  ),
                ],
              )
            else ...[
              BestSellersTable(items: DashboardDemoData.bestSellers),
              const SizedBox(height: AppSpacing.base),
              RecentTransactionsCard(
                transactions: DashboardDemoData.recentTransactions,
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Evening, Vikramaditya',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${DashboardDemoData.restaurantName} • ${DashboardDemoData.branchName}',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
        // Notification bell
        IconButton(
          onPressed: () {},
          icon: Badge(
            smallSize: 8,
            backgroundColor: AppColors.errorRed,
            child: const Icon(Icons.notifications_none_rounded, size: 22, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Profile
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.champagneGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.champagneGold.withValues(alpha: 0.3)),
          ),
          child: const Center(
            child: Text(
              'VR',
              style: TextStyle(
                color: AppColors.champagneGold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningAmber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.warningAmber),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'DEMO DATA — This dashboard displays sample data for development purposes. '
              'Real data will populate from backend APIs as modules are connected.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.warningAmber),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(bool isDesktop, bool isTablet) {
    final metrics = DashboardDemoData.metrics;
    final iconMap = {
      'today_sales': Icons.currency_rupee_rounded,
      'total_orders': Icons.shopping_bag_outlined,
      'active_tables': Icons.table_restaurant_outlined,
      'kitchen_queue': Icons.soup_kitchen_outlined,
      'avg_order': Icons.trending_up_rounded,
    };

    final entries = metrics.entries.toList();
    final crossAxisCount = isDesktop ? 5 : (isTablet ? 3 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        mainAxisExtent: 180,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final key = entries[index].key;
        final m = entries[index].value;
        return MetricCard(
          title: m['title'] as String,
          value: m['value'] as String,
          change: m['change'] as String,
          description: m['description'] as String,
          icon: iconMap[key] ?? Icons.insights_rounded,
          isPositive: m['trend'] != 'down',
        );
      },
    );
  }
}
