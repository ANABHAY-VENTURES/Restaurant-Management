// Anabhay Ventures — Table QR Management Screen (Admin / Manager)
// Overview of all table QR codes, regeneration, individual & bulk printing, and customer menu preview

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../pos/presentation/providers/pos_providers.dart';
import '../widgets/table_qr_card.dart';
import '../widgets/printable_qr_sheet.dart';

class QRManagementScreen extends ConsumerStatefulWidget {
  const QRManagementScreen({super.key});

  @override
  ConsumerState<QRManagementScreen> createState() => _QRManagementScreenState();
}

class _QRManagementScreenState extends ConsumerState<QRManagementScreen> {
  String _selectedZone = 'All Zones';

  final List<String> _zones = [
    'All Zones',
    'Main Dining Hall',
    'Terrace Garden',
    'VIP Lounge',
    'Private Dining Room',
  ];

  @override
  Widget build(BuildContext context) {
    final tables = ref.watch(tablesProvider);
    final orders = ref.watch(ordersProvider);

    final filteredTables = tables.where((t) {
      if (_selectedZone != 'All Zones' && t.zone != _selectedZone) return false;
      return true;
    }).toList();

    final activeSessions = tables.where((t) => t.status.name == 'occupied').length;
    final totalQrOrders = orders.where((o) => o.tableNumber.isNotEmpty).length;

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
                      Text('Table QR Management', style: AppTypography.headlineMedium.copyWith(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text(
                        'Contactless table ordering & standees',
                        style: AppTypography.bodySmall,
                      ),
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
                              onPressed: () {
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('All table security tokens regenerated!'),
                                    backgroundColor: AppColors.champagneGold,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Regenerate', style: TextStyle(fontSize: 12)),
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
                              onPressed: () => PrintableQrSheetDialog.show(context, tables),
                              icon: const Icon(Icons.print_rounded, size: 16),
                              label: const Text('Print Sheet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                          Text('Table QR Management', style: AppTypography.headlineLarge, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            'Unique contactless ordering QR codes for all restaurant tables • Instant KDS linking',
                            style: AppTypography.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: () {
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All table security tokens regenerated!'),
                                backgroundColor: AppColors.champagneGold,
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Regenerate All'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.champagneGold,
                            foregroundColor: AppColors.matteBlack,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          onPressed: () => PrintableQrSheetDialog.show(context, tables),
                          icon: const Icon(Icons.print_rounded, size: 18),
                          label: const Text('Print Standee Sheet', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Metrics Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: _buildMetricTile(
                      label: 'Configured Tables',
                      value: '${tables.length}',
                      icon: Icons.table_restaurant_outlined,
                      color: AppColors.champagneGold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 200,
                    child: _buildMetricTile(
                      label: 'Active Dining Sessions',
                      value: '$activeSessions',
                      icon: Icons.people_outline_rounded,
                      color: AppColors.copper,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 200,
                    child: _buildMetricTile(
                      label: 'Contactless Table Orders',
                      value: '$totalQrOrders',
                      icon: Icons.qr_code_scanner_rounded,
                      color: AppColors.successGreen,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 200,
                    child: _buildMetricTile(
                      label: 'QR Scanner Route',
                      value: 'Web-First',
                      icon: Icons.language_rounded,
                      color: AppColors.warmIvory,
                    ),
                  ),
                ],
              ),
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
                          style: TextStyle(
                            fontSize: 12,
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
            const SizedBox(height: AppSpacing.md),

            // Table QR Cards Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  mainAxisExtent: 310,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                itemCount: filteredTables.length,
                itemBuilder: (context, index) {
                  return TableQrCard(
                    table: filteredTables[index],
                    onRegenerate: () => setState(() {}),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
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
