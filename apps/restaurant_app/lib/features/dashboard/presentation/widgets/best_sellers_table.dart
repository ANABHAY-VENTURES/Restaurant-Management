// Anabhay Ventures — Best Sellers Table Widget

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/status_badge.dart';

class BestSellersTable extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const BestSellersTable({super.key, required this.items});

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
          const Row(
            children: [
              Icon(Icons.whatshot_rounded, size: 20, color: AppColors.copper),
              SizedBox(width: AppSpacing.sm),
              Text('Best Sellers', style: AppTypography.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          // Header
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Item', style: AppTypography.labelSmall)),
                Expanded(flex: 2, child: Text('Category', style: AppTypography.labelSmall)),
                Expanded(child: Text('Qty', style: AppTypography.labelSmall, textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text('Revenue', style: AppTypography.labelSmall, textAlign: TextAlign.right)),
                SizedBox(width: 70),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          ...items.map((item) => _BestSellerRow(item: item)),
        ],
      ),
    );
  }
}

class _BestSellerRow extends StatelessWidget {
  final Map<String, dynamic> item;

  const _BestSellerRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final inStock = item['inStock'] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item['name'] as String,
              style: AppTypography.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item['category'] as String,
              style: AppTypography.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              '${item['qty']}',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${_formatNumber(item['revenue'] as double)}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.champagneGold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 70,
            child: Align(
              alignment: Alignment.centerRight,
              child: StatusBadge(
                label: inStock ? 'In Stock' : 'Out',
                variant: inStock ? BadgeVariant.success : BadgeVariant.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toStringAsFixed(0);
  }
}
