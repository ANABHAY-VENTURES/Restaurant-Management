// Anabhay Ventures — Table Management & Floor Plan Screen

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';

class TableManagementScreen extends StatefulWidget {
  const TableManagementScreen({super.key});

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  String _selectedZone = 'All Zones';
  final String _selectedStatus = 'All Status';

  final List<String> _zones = [
    'All Zones',
    'Main Dining Hall',
    'Terrace Garden',
    'VIP Lounge',
    'Private Dining Room',
  ];

  final List<Map<String, dynamic>> _tables = [
    {'id': 't1', 'number': 'T-01', 'zone': 'Main Dining Hall', 'capacity': 4, 'status': 'Occupied', 'waiter': 'Ramesh K.', 'bill': 2450.0, 'time': '42 min'},
    {'id': 't2', 'number': 'T-02', 'zone': 'Main Dining Hall', 'capacity': 2, 'status': 'Available', 'waiter': '-', 'bill': 0.0, 'time': '-'},
    {'id': 't3', 'number': 'T-03', 'zone': 'Main Dining Hall', 'capacity': 4, 'status': 'Billed', 'waiter': 'Ramesh K.', 'bill': 4180.0, 'time': '65 min'},
    {'id': 't4', 'number': 'T-04', 'zone': 'Main Dining Hall', 'capacity': 6, 'status': 'Occupied', 'waiter': 'Priya S.', 'bill': 5890.0, 'time': '28 min'},
    {'id': 't5', 'number': 'T-05', 'zone': 'Terrace Garden', 'capacity': 4, 'status': 'Available', 'waiter': '-', 'bill': 0.0, 'time': '-'},
    {'id': 't6', 'number': 'T-06', 'zone': 'Terrace Garden', 'capacity': 4, 'status': 'Occupied', 'waiter': 'Priya S.', 'bill': 1850.0, 'time': '18 min'},
    {'id': 't7', 'number': 'T-07', 'zone': 'Terrace Garden', 'capacity': 2, 'status': 'Reserved', 'waiter': 'Priya S.', 'bill': 0.0, 'time': '8:30 PM'},
    {'id': 't8', 'number': 'T-08', 'zone': 'Terrace Garden', 'capacity': 8, 'status': 'Occupied', 'waiter': 'Ramesh K.', 'bill': 7200.0, 'time': '50 min'},
    {'id': 't9', 'number': 'VIP-01', 'zone': 'VIP Lounge', 'capacity': 8, 'status': 'Occupied', 'waiter': 'Sanjay V.', 'bill': 14500.0, 'time': '75 min'},
    {'id': 't10', 'number': 'VIP-02', 'zone': 'VIP Lounge', 'capacity': 10, 'status': 'Reserved', 'waiter': 'Sanjay V.', 'bill': 0.0, 'time': '9:00 PM'},
    {'id': 't11', 'number': 'PDR-01', 'zone': 'Private Dining Room', 'capacity': 12, 'status': 'Available', 'waiter': '-', 'bill': 0.0, 'time': '-'},
    {'id': 't12', 'number': 'PDR-02', 'zone': 'Private Dining Room', 'capacity': 16, 'status': 'Occupied', 'waiter': 'Sanjay V.', 'bill': 22800.0, 'time': '90 min'},
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return AppColors.successGreen;
      case 'Occupied':
        return AppColors.errorRed;
      case 'Billed':
        return AppColors.champagneGold;
      case 'Reserved':
        return AppColors.warningAmber;
      default:
        return AppColors.mutedGrey;
    }
  }

  void _showTableActions(Map<String, dynamic> table) {
    AppDialog.show(
      context: context,
      title: '${table['number']} Details',
      subtitle: '${table['zone']} • Capacity: ${table['capacity']} Guests',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Status:', style: AppTypography.bodySmall),
              StatusBadge(
                label: table['status'] as String,
                variant: table['status'] == 'Available'
                    ? BadgeVariant.success
                    : (table['status'] == 'Occupied' ? BadgeVariant.error : BadgeVariant.warning),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Assigned Waiter:', style: AppTypography.bodySmall),
              Text(table['waiter'] as String, style: AppTypography.bodyMedium),
            ],
          ),
          if (table['status'] == 'Occupied' || table['status'] == 'Billed') ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Bill Amount:', style: AppTypography.bodySmall),
                Text('₹${(table['bill'] as num).toStringAsFixed(0)}', style: AppTypography.currencyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Seated Duration:', style: AppTypography.bodySmall),
                Text(table['time'] as String, style: AppTypography.bodyMedium),
              ],
            ),
          ],
        ],
      ),
      confirmLabel: table['status'] == 'Available' ? 'Seat Guests / Order' : 'Settle Bill & Vacate',
      onConfirm: () {
        Navigator.of(context).pop();
        setState(() {
          if (table['status'] == 'Available') {
            table['status'] = 'Occupied';
            table['waiter'] = 'Ramesh K.';
          } else {
            table['status'] = 'Available';
            table['bill'] = 0.0;
            table['waiter'] = '-';
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTables = _tables.where((t) {
      final matchesZone = _selectedZone == 'All Zones' || t['zone'] == _selectedZone;
      final matchesStatus = _selectedStatus == 'All Status' || t['status'] == _selectedStatus;
      return matchesZone && matchesStatus;
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
                      Text('Visual floor plan • Live occupancy tracking', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                // Legend
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
                  final status = table['status'] as String;
                  final statusColor = _getStatusColor(status);

                  return Material(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    child: InkWell(
                      onTap: () => _showTableActions(table),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Table Number & Status Dot
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(table['number'] as String, style: AppTypography.headlineSmall),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                  ),
                                  child: Text(
                                    status,
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
                            Text('${table['capacity']} Seats • ${table['zone']}', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
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
                                    Text(table['waiter'] as String, style: AppTypography.labelSmall),
                                  ],
                                ),
                                if (table['bill'] > 0)
                                  Text(
                                    '₹${(table['bill'] as num).toStringAsFixed(0)}',
                                    style: AppTypography.titleMedium.copyWith(color: AppColors.champagneGold),
                                  ),
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
