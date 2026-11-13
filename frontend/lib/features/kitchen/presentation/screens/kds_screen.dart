// Anabhay Ventures — Kitchen Display System (KDS) Screen
// Phase 3: Live Real-Time Kitchen Order Ticket (KOT) Station

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_management/core/theme/theme.dart';
import 'package:restaurant_management/shared/widgets/widgets.dart';
import 'package:restaurant_management/features/pos/domain/models/order_models.dart';
import 'package:restaurant_management/features/pos/presentation/providers/pos_providers.dart';

class KDSScreen extends ConsumerStatefulWidget {
  const KDSScreen({super.key});

  @override
  ConsumerState<KDSScreen> createState() => _KDSScreenState();
}

class _KDSScreenState extends ConsumerState<KDSScreen> {
  String _selectedStatusFilter = 'Active'; // 'Active', 'New', 'Preparing', 'Ready', 'Served', 'All'
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // 10-second ticker to update elapsed minute badges
    _ticker = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(ordersProvider);

    // Filter tickets for kitchen
    final filteredOrders = allOrders.where((order) {
      if (_selectedStatusFilter == 'Active') {
        return order.orderStatus == OrderStatus.newOrder ||
            order.orderStatus == OrderStatus.preparing ||
            order.orderStatus == OrderStatus.ready;
      } else if (_selectedStatusFilter == 'New') {
        return order.orderStatus == OrderStatus.newOrder;
      } else if (_selectedStatusFilter == 'Preparing') {
        return order.orderStatus == OrderStatus.preparing;
      } else if (_selectedStatusFilter == 'Ready') {
        return order.orderStatus == OrderStatus.ready;
      } else if (_selectedStatusFilter == 'Served') {
        return order.orderStatus == OrderStatus.served;
      }
      return true;
    }).toList();

    final activeCount = allOrders
        .where((o) =>
            o.orderStatus == OrderStatus.newOrder ||
            o.orderStatus == OrderStatus.preparing ||
            o.orderStatus == OrderStatus.ready)
        .length;

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            _buildTopBar(activeCount),
            const SizedBox(height: AppSpacing.md),

            // Status Filter Tabs
            _buildStatusFilters(allOrders),
            const SizedBox(height: AppSpacing.base),

            // KOT Cards Grid
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(
                      child: AppEmptyState(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'All Kitchen Orders Cleared',
                        description: _selectedStatusFilter == 'Active'
                            ? 'No active orders in kitchen queue. All stations clear!'
                            : 'No tickets found matching the "$_selectedStatusFilter" filter.',
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final crossAxisCount = width > 1300
                            ? 4
                            : (width > 900 ? 3 : (width > 600 ? 2 : 1));

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            mainAxisExtent: 410,
                          ),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _buildKOTCard(order);
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

  Widget _buildTopBar(int activeCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.soup_kitchen_rounded, color: AppColors.champagneGold, size: 28),
            const SizedBox(width: AppSpacing.sm),
            Text('Kitchen Display System (KDS)', style: AppTypography.headlineSmall),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: activeCount > 0 ? AppColors.copper.withValues(alpha: 0.2) : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(color: activeCount > 0 ? AppColors.copper : AppColors.borderSubtle),
              ),
              child: Text(
                '$activeCount Active Orders',
                style: TextStyle(
                  color: activeCount > 0 ? AppColors.copper : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: const [
                  Icon(Icons.wifi_rounded, size: 14, color: AppColors.successGreen),
                  SizedBox(width: 6),
                  Text('KDS Live Sync', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusFilters(List<RestaurantOrder> allOrders) {
    final filters = ['Active', 'New', 'Preparing', 'Ready', 'Served', 'All'];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedStatusFilter == filter;

          int count = 0;
          if (filter == 'Active') {
            count = allOrders
                .where((o) =>
                    o.orderStatus == OrderStatus.newOrder ||
                    o.orderStatus == OrderStatus.preparing ||
                    o.orderStatus == OrderStatus.ready)
                .length;
          } else if (filter == 'New') {
            count = allOrders.where((o) => o.orderStatus == OrderStatus.newOrder).length;
          } else if (filter == 'Preparing') {
            count = allOrders.where((o) => o.orderStatus == OrderStatus.preparing).length;
          } else if (filter == 'Ready') {
            count = allOrders.where((o) => o.orderStatus == OrderStatus.ready).length;
          } else if (filter == 'Served') {
            count = allOrders.where((o) => o.orderStatus == OrderStatus.served).length;
          } else {
            count = allOrders.length;
          }

          return Material(
            color: isSelected ? AppColors.champagneGold : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              onTap: () => setState(() => _selectedStatusFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Text(
                      filter,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? AppColors.matteBlack : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.matteBlack.withValues(alpha: 0.15) : AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.matteBlack : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKOTCard(RestaurantOrder order) {
    final elapsedMinutes = DateTime.now().difference(order.createdAt).inMinutes;
    final isOverdue = elapsedMinutes >= 15;
    final isNew = order.orderStatus == OrderStatus.newOrder;
    final isPrep = order.orderStatus == OrderStatus.preparing;
    final isReady = order.orderStatus == OrderStatus.ready;

    Color headerColor;
    if (isNew) {
      headerColor = AppColors.warningAmber;
    } else if (isPrep) {
      headerColor = AppColors.copper;
    } else if (isReady) {
      headerColor = AppColors.champagneGold;
    } else {
      headerColor = AppColors.successGreen;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isNew ? AppColors.warningAmber : (isOverdue ? AppColors.errorRed : AppColors.borderSubtle),
          width: isNew || isOverdue ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KOT Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd - 1)),
              border: Border(bottom: BorderSide(color: headerColor.withValues(alpha: 0.4))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.tableNumber,
                      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${order.kotNumber} • ${order.orderType.label}',
                      style: TextStyle(color: headerColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Elapsed Timer Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOverdue ? AppColors.errorRed : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: isOverdue ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${elapsedMinutes.toString().padLeft(2, '0')}:${(DateTime.now().difference(order.createdAt).inSeconds % 60).toString().padLeft(2, '0')}m',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isOverdue ? Colors.white : AppColors.warmIvory,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // General cooking instruction alert if present
          if (order.generalInstructions != null && order.generalInstructions!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
              color: AppColors.copper.withValues(alpha: 0.2),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.copper),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'KITCHEN NOTE: ${order.generalInstructions}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.copper),
                    ),
                  ),
                ],
              ),
            ),

          // Items Checklist
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: order.items.length,
              separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 12),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return InkWell(
                  onTap: () {
                    ref.read(ordersProvider.notifier).toggleItemPrepared(order.id, item.id);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.isPrepared ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 20,
                        color: item.isPrepared ? AppColors.successGreen : AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.quantity}× ${item.name}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: item.isPrepared ? AppColors.textTertiary : AppColors.warmIvory,
                                decoration: item.isPrepared ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            if (item.variantName != null)
                              Text(
                                '(${item.variantName})',
                                style: const TextStyle(fontSize: 11, color: AppColors.champagneGold),
                              ),
                            if (item.selectedAddOns.isNotEmpty)
                              Text(
                                '+ ${item.selectedAddOns.join(', ')}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            if (item.specialInstruction != null && item.specialInstruction!.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.warningAmber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  'Note: ${item.specialInstruction}',
                                  style: const TextStyle(fontSize: 10, color: AppColors.warningAmber, fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Tactile Touch Actions Bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppSpacing.radiusMd - 1)),
            ),
            child: _buildActionButtons(order),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(RestaurantOrder order) {
    if (order.orderStatus == OrderStatus.newOrder) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.copper,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () {
            ref.read(ordersProvider.notifier).updateOrderStatus(order.id, OrderStatus.preparing);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${order.kotNumber} for ${order.tableNumber} is now PREPARING!'),
                backgroundColor: AppColors.copper,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.soup_kitchen_rounded, size: 18),
          label: const Text('Start Preparation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      );
    } else if (order.orderStatus == OrderStatus.preparing) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.champagneGold,
            foregroundColor: AppColors.matteBlack,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () {
            ref.read(ordersProvider.notifier).updateOrderStatus(order.id, OrderStatus.ready);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${order.kotNumber} for ${order.tableNumber} is READY to Serve!'),
                backgroundColor: AppColors.champagneGold,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.check_circle_rounded, size: 18),
          label: const Text('Mark as Ready', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      );
    } else if (order.orderStatus == OrderStatus.ready) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.successGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () {
            ref.read(ordersProvider.notifier).updateOrderStatus(order.id, OrderStatus.served);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${order.kotNumber} for ${order.tableNumber} marked SERVED!'),
                backgroundColor: AppColors.successGreen,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.room_service_rounded, size: 18),
          label: const Text('Mark Served to Table', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.done_all_rounded, size: 16, color: AppColors.successGreen),
            SizedBox(width: 6),
            Text('ORDER SERVED TO GUEST', style: TextStyle(color: AppColors.successGreen, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
  }
}
