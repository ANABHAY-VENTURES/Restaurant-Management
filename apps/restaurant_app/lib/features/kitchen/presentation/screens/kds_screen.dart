// Anabhay Ventures — Kitchen Display System (KDS) Screen

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';

class KDSScreen extends StatefulWidget {
  const KDSScreen({super.key});

  @override
  State<KDSScreen> createState() => _KDSScreenState();
}

class _KDSScreenState extends State<KDSScreen> {
  String _selectedStation = 'All Stations';

  final List<String> _stations = [
    'All Stations',
    'Tandoor & Grill',
    'Curry & Main',
    'Breads Station',
    'Dessert & Bar',
  ];

  final List<Map<String, dynamic>> _tickets = [
    {
      'kot': 'KOT-104',
      'table': 'Table 04',
      'server': 'Ramesh K.',
      'station': 'Tandoor & Grill',
      'elapsedMinutes': 14,
      'isUrgent': true,
      'items': [
        {'name': '2× Murgh Malai Tikka', 'done': true},
        {'name': '1× Saffron Dum Biryani', 'done': false},
        {'name': '2× Burani Raita', 'done': false},
      ],
    },
    {
      'kot': 'KOT-105',
      'table': 'Table 12',
      'server': 'Priya S.',
      'station': 'Curry & Main',
      'elapsedMinutes': 8,
      'isUrgent': false,
      'items': [
        {'name': '1× Dal Makhani Reserve', 'done': true},
        {'name': '1× Butter Chicken Royale', 'done': false},
        {'name': '3× Butter Garlic Naan', 'done': false},
      ],
    },
    {
      'kot': 'KOT-106',
      'table': 'Table 08',
      'server': 'Ramesh K.',
      'station': 'Breads Station',
      'elapsedMinutes': 4,
      'isUrgent': false,
      'items': [
        {'name': '4× Butter Garlic Naan', 'done': false},
        {'name': '2× Tandoori Roti', 'done': false},
      ],
    },
    {
      'kot': 'KOT-107',
      'table': 'Takeaway 03',
      'server': 'Counter',
      'station': 'Curry & Main',
      'elapsedMinutes': 2,
      'isUrgent': false,
      'items': [
        {'name': '2× Saffron Dum Biryani', 'done': false},
        {'name': '1× Chicken Tikka Roll', 'done': false},
        {'name': '2× Fresh Lime Soda', 'done': false},
      ],
    },
  ];

  void _toggleItem(int ticketIndex, int itemIndex) {
    setState(() {
      final items = _tickets[ticketIndex]['items'] as List<Map<String, dynamic>>;
      items[itemIndex]['done'] = !(items[itemIndex]['done'] as bool);
    });
  }

  void _bumpTicket(int ticketIndex) {
    setState(() {
      _tickets.removeAt(ticketIndex);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('KOT bumped and marked Ready! Order dispatch notified.'),
        backgroundColor: AppColors.successGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTickets = _tickets.where((t) {
      if (_selectedStation == 'All Stations') return true;
      return t['station'] == _selectedStation;
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
                      Text('Kitchen Display System (KDS)', style: AppTypography.headlineLarge),
                      const SizedBox(height: 2),
                      Text(
                        'Live kitchen station dispatch • Real-time preparation timers',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Active tickets count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warningAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.soup_kitchen_outlined, size: 18, color: AppColors.warningAmber),
                      const SizedBox(width: 8),
                      Text(
                        '${_tickets.length} Active Tickets',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.warningAmber,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Station Tabs
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _stations.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final st = _stations[index];
                  final isSelected = st == _selectedStation;
                  return Material(
                    color: isSelected ? AppColors.champagneGold : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      onTap: () => setState(() => _selectedStation = st),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        alignment: Alignment.center,
                        child: Text(
                          st,
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

            // KOT Cards Grid
            Expanded(
              child: filteredTickets.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.check_circle_outline,
                      title: 'All Kitchen Orders Clear!',
                      description: 'No pending orders in this kitchen station.',
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 360,
                            mainAxisExtent: 380,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                          ),
                          itemCount: filteredTickets.length,
                          itemBuilder: (context, index) {
                            final ticket = filteredTickets[index];
                            final elapsed = ticket['elapsedMinutes'] as int;
                            final isOverdue = elapsed > 12;
                            final isWarning = elapsed >= 8 && elapsed <= 12;
                            final timerColor = isOverdue
                                ? AppColors.errorRed
                                : (isWarning ? AppColors.warningAmber : AppColors.successGreen);

                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceCard,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                border: Border.all(
                                  color: isOverdue ? AppColors.errorRed : AppColors.borderSubtle,
                                  width: isOverdue ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Ticket Header
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: timerColor.withValues(alpha: 0.12),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          ticket['kot'] as String,
                                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceDark,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            ticket['table'] as String,
                                            style: AppTypography.labelSmall.copyWith(color: AppColors.champagneGold, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        const Spacer(),
                                        // Timer
                                        Row(
                                          children: [
                                            Icon(Icons.timer_outlined, size: 16, color: timerColor),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$elapsed min',
                                              style: AppTypography.titleMedium.copyWith(color: timerColor, fontWeight: FontWeight.w800),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Meta Subheader
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Station: ${ticket['station']}', style: AppTypography.bodySmall),
                                        Text('Waiter: ${ticket['server']}', style: AppTypography.bodySmall),
                                      ],
                                    ),
                                  ),
                                  const Divider(color: AppColors.borderSubtle, height: 1),

                                  // Items Checklist
                                  Expanded(
                                    child: ListView.separated(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      itemCount: (ticket['items'] as List).length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                                      itemBuilder: (context, itemIdx) {
                                        final item = (ticket['items'] as List)[itemIdx] as Map<String, dynamic>;
                                        final isDone = item['done'] as bool;
                                        return InkWell(
                                          onTap: () => _toggleItem(index, itemIdx),
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isDone ? AppColors.surfaceDark : AppColors.surfaceElevated,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: isDone ? AppColors.successGreen.withValues(alpha: 0.3) : AppColors.borderSubtle,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isDone ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                                  size: 18,
                                                  color: isDone ? AppColors.successGreen : AppColors.textTertiary,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    item['name'] as String,
                                                    style: AppTypography.bodyMedium.copyWith(
                                                      color: isDone ? AppColors.textTertiary : AppColors.warmIvory,
                                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                                      fontWeight: isDone ? FontWeight.w400 : FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // Footer Bump Button
                                  Padding(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    child: AppButton(
                                      label: 'Bump / Ready',
                                      icon: Icons.check_circle_outline,
                                      variant: AppButtonVariant.primary,
                                      isFullWidth: true,
                                      onPressed: () => _bumpTicket(index),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
