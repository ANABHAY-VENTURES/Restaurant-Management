// Anabhay Ventures — Restaurant Owner Dashboard Screen
// Phase 3: Connected Live Metrics (Revenue, Orders, Active Tables, Kitchen Queue)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_management/core/theme/theme.dart';
import 'package:restaurant_management/shared/widgets/widgets.dart';
import 'package:restaurant_management/features/dashboard/data/dashboard_demo_data.dart';
import 'package:restaurant_management/features/pos/presentation/providers/pos_providers.dart';
import 'package:restaurant_management/features/settings/domain/models/settings_models.dart';
import 'package:restaurant_management/features/settings/presentation/providers/settings_providers.dart';
import '../widgets/sales_chart.dart';
import '../widgets/kitchen_queue_card.dart';
import '../widgets/best_sellers_table.dart';
import '../widgets/recent_transactions_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveMetrics = ref.watch(dashboardMetricsProvider);
    final profile = ref.watch(restaurantProfileProvider);
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
            _buildHeader(context, profile),
            const SizedBox(height: AppSpacing.xl),

            // ── DEMO NOTICE ──────────────────────────────
            _buildDemoNotice(),
            const SizedBox(height: AppSpacing.xl),

            // ── Metric Cards ─────────────────────────────
            _buildMetricsGrid(isDesktop, isTablet, liveMetrics),
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
                    child: KitchenQueueCard(
                      liveOrders: liveMetrics.activeKitchenTickets,
                      tickets: DashboardDemoData.kitchenQueue,
                    ),
                  ),
                ],
              )
            else ...[
              SalesChart(data: DashboardDemoData.hourlySales),
              const SizedBox(height: AppSpacing.base),
              KitchenQueueCard(
                liveOrders: liveMetrics.activeKitchenTickets,
                tickets: DashboardDemoData.kitchenQueue,
              ),
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

  Widget _buildHeader(BuildContext context, RestaurantProfile profile) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name.isNotEmpty ? profile.name : 'Restaurant Management',
                style: AppTypography.headlineLarge.copyWith(fontSize: 22),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      profile.tagline.isNotEmpty ? profile.tagline.toUpperCase() : 'PARK STREET FLAGSHIP',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.champagneGold,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    ' • Live Operations',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Quick user avatar
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.champagneGold.withValues(alpha: 0.4)),
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
          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.warningAmber),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'DEMO CLIENT PROTOTYPE — Connected live POS, Kitchen KDS, Table Occupancy and Invoices. '
              'Actions in POS and KDS immediately synchronize with dashboard revenue and metrics.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.warningAmber),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(bool isDesktop, bool isTablet, DashboardMetrics liveMetrics) {
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
        mainAxisExtent: isDesktop ? 180 : (isTablet ? 170 : 160),
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final key = entries[index].key;
        final m = entries[index].value;

        String displayValue = m['value'] as String;
        String desc = m['description'] as String;

        if (key == 'today_sales') {
          displayValue = '₹${liveMetrics.todaySales.toStringAsFixed(0)}';
          desc = 'Live today gross';
        } else if (key == 'total_orders') {
          displayValue = '${liveMetrics.totalOrders}';
          desc = 'Live order volume';
        } else if (key == 'active_tables') {
          displayValue = '${liveMetrics.activeTablesCount} / 12';
          desc = 'Occupied / Billed';
        } else if (key == 'kitchen_queue') {
          displayValue = '${liveMetrics.kitchenQueueCount} tickets';
          desc = 'Live KOT queue';
        }

        return MetricCard(
          title: m['title'] as String,
          value: displayValue,
          change: m['change'] as String,
          description: desc,
          icon: iconMap[key] ?? Icons.insights_rounded,
          isPositive: m['trend'] != 'down',
        );
      },
    );
  }
}
