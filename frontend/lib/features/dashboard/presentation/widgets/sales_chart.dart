// Anabhay Ventures — Sales Chart Widget

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class SalesChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SalesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Sales", style: AppTypography.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Hourly revenue breakdown',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: _maxSales * 1.15,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = data[group.x];
                      return BarTooltipItem(
                        '${item['time']}\n₹${(rod.toY / 1000).toStringAsFixed(1)}K',
                        AppTypography.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 46,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}K',
                          style: AppTypography.labelSmall.copyWith(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= data.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data[value.toInt()]['time'] as String,
                            style: AppTypography.labelSmall.copyWith(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxSales / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.borderSubtle.withValues(alpha: 0.5),
                    strokeWidth: 0.8,
                    dashArray: [4, 4],
                  ),
                ),
                barGroups: List.generate(data.length, (i) {
                  final sales = (data[i]['sales'] as num).toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: sales,
                        width: 18,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        gradient: const LinearGradient(
                          colors: [AppColors.copper, AppColors.champagneGold],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get _maxSales {
    double max = 0;
    for (final d in data) {
      final v = (d['sales'] as num).toDouble();
      if (v > max) max = v;
    }
    return max == 0 ? 1 : max;
  }
}

