// Anabhay Ventures — Recent Transactions Widget

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class RecentTransactionsCard extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const RecentTransactionsCard({super.key, required this.transactions});

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
              Icon(Icons.receipt_long_outlined, size: 20, color: AppColors.champagneGold),
              SizedBox(width: AppSpacing.sm),
              Text('Recent Transactions', style: AppTypography.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          ...transactions.map((tx) => _TxRow(tx: tx)),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final Map<String, dynamic> tx;

  const _TxRow({required this.tx});

  IconData _methodIcon(String method) {
    return switch (method) {
      'UPI'  => Icons.qr_code_scanner_rounded,
      'Card' => Icons.credit_card_rounded,
      'Cash' => Icons.payments_outlined,
      _      => Icons.account_balance_wallet_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Method icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(_methodIcon(tx['method'] as String), size: 18, color: AppColors.champagneGold),
          ),
          const SizedBox(width: AppSpacing.md),
          // Invoice + Table
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['invoice'] as String,
                  style: AppTypography.bodyMedium,
                ),
                Text(
                  '${tx['table']} • ${tx['method']}',
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ),
          // Amount + Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${(tx['amount'] as num).toStringAsFixed(0)}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.successGreen,
                ),
              ),
              Text(
                tx['time'] as String,
                style: AppTypography.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
