// Anabhay Ventures — Table Management & Floor Plan Screen
// Phase 3: Connected Live Table Occupancy & POS Linking

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurant_management/core/theme/theme.dart';
import 'package:restaurant_management/shared/widgets/widgets.dart';
import 'package:restaurant_management/features/pos/domain/models/order_models.dart';
import 'package:restaurant_management/features/pos/presentation/providers/pos_providers.dart';

class TableManagementScreen extends ConsumerStatefulWidget {
  const TableManagementScreen({super.key});

  @override
  ConsumerState<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends ConsumerState<TableManagementScreen> {
  String _selectedZone = 'All Zones';

  final List<String> _zones = [
    'All Zones',
    'Main Dining Hall',
    'Terrace Garden',
    'VIP Lounge',
    'Private Dining Room',
  ];

  void _showTableActions(RestaurantTable table, List<RestaurantOrder> orders) {
    RestaurantOrder? activeOrder;
    if (table.activeOrderId != null) {
      activeOrder = orders.firstWhere(
        (o) => o.id == table.activeOrderId,
        orElse: () => orders.first,
      );
    }

    AppDialog.show(
      context: context,
      title: '${table.number} (${table.code})',
      subtitle: '${table.zone} • Capacity: ${table.capacity} Guests',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Status:', style: AppTypography.bodySmall),
              StatusBadge(
                label: table.status.label,
                variant: table.status.badgeVariant,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Assigned Waiter:', style: AppTypography.bodySmall),
              Text(table.waiter ?? 'Vikramaditya R.', style: AppTypography.bodyMedium),
            ],
          ),
          if (table.status == TableStatus.occupied || table.status == TableStatus.billed) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Bill Amount:', style: AppTypography.bodySmall),
                Text('₹${table.currentBill.toStringAsFixed(0)}', style: AppTypography.currencyMedium),
              ],
            ),
            if (activeOrder != null) ...[
              const SizedBox(height: 8),
              const Divider(color: AppColors.borderSubtle, height: 12),
              Text('Order Items (${activeOrder.items.length}):', style: AppTypography.labelSmall.copyWith(color: AppColors.champagneGold)),
              const SizedBox(height: 4),
              ...activeOrder.items.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${i.quantity}× ${i.name}', style: const TextStyle(fontSize: 12, color: AppColors.warmIvory), overflow: TextOverflow.ellipsis)),
                        Text('₹${i.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  )),
            ],
          ],
        ],
      ),
      confirmLabel: table.status == TableStatus.available ? 'Create Order in POS' : 'Open in POS / Settle',
      onConfirm: () {
        Navigator.of(context).pop();
        ref.read(posCartProvider.notifier).setSelectedTable(table.number);
        context.go('/pos');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tables = ref.watch(tablesProvider);
    final orders = ref.watch(ordersProvider);

    final filteredTables = tables.where((t) {
      final matchesZone = _selectedZone == 'All Zones' || t.zone == _selectedZone;
      return matchesZone;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Table Management', style: AppTypography.headlineLarge),
                      const SizedBox(height: 2),
                      Text('Visual floor plan • Live occupancy & billing synchronization', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                _buildLegend(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Zone Tabs
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _zones.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final z = _zones[index];
                  final isSelected = z == _selectedZone;
                  return Material(
                    color: isSelected ? AppColors.champagneGold : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      onTap: () => setState(() => _selectedZone = z),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        alignment: Alignment.center,
                        child: Text(
                          z,
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected ? AppColors.matteBlack : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.base),

            // Table Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  mainAxisExtent: 170,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                itemCount: filteredTables.length,
                itemBuilder: (context, index) {
                  final table = filteredTables[index];
                  final statusColor = table.status.color;

                  return Material(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    child: InkWell(
                      onTap: () => _showTableActions(table, orders),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Table Number & Status Dot
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(table.number, style: AppTypography.headlineSmall),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                  ),
                                  child: Text(
                                    table.status.label,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${table.capacity} Seats • ${table.zone}', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                            const Spacer(),
                            const Divider(color: AppColors.borderSubtle, height: 1),
                            const SizedBox(height: 6),
                            // Waiter & Bill
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 14, color: AppColors.textTertiary),
                                    const SizedBox(width: 4),
                                    Text(table.waiter ?? 'Staff', style: AppTypography.labelSmall),
                                  ],
                                ),
                                if (table.currentBill > 0)
                                  Text(
                                    '₹${table.currentBill.toStringAsFixed(0)}',
                                    style: AppTypography.titleMedium.copyWith(color: AppColors.champagneGold),
                                  )
                                else
                                  const Text('Free', style: TextStyle(fontSize: 11, color: AppColors.successGreen)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendDot('Available', AppColors.successGreen),
        const SizedBox(width: AppSpacing.md),
        _legendDot('Occupied', AppColors.errorRed),
        const SizedBox(width: AppSpacing.md),
        _legendDot('Billed', AppColors.champagneGold),
        const SizedBox(width: AppSpacing.md),
        _legendDot('Reserved', AppColors.warningAmber),
      ],
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
      ],
    );
  }
}
