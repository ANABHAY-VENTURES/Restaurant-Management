// Anabhay Ventures — Reports & Analytics Riverpod Providers
// Phase 6: Live Financial Analytics, Sales Trends, Product Performance, and Payment Breakdown

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/report_models.dart';
import '../../../pos/domain/models/order_models.dart';
import '../../../pos/presentation/providers/pos_providers.dart';

final selectedDateRangeProvider = StateProvider<ReportDateRange>((ref) {
  return ReportDateRange.today;
});

final customDateRangeProvider = StateProvider<DateTimeRange?>((ref) {
  return null;
});

/// Returns [start, end] for the active date range filter
DateTimeRange _resolveDateRange(ReportDateRange filter, DateTimeRange? custom) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

  switch (filter) {
    case ReportDateRange.today:
      return DateTimeRange(start: todayStart, end: todayEnd);
    case ReportDateRange.yesterday:
      final yStart = todayStart.subtract(const Duration(days: 1));
      final yEnd = DateTime(yStart.year, yStart.month, yStart.day, 23, 59, 59);
      return DateTimeRange(start: yStart, end: yEnd);
    case ReportDateRange.last7Days:
      return DateTimeRange(start: todayStart.subtract(const Duration(days: 6)), end: todayEnd);
    case ReportDateRange.last30Days:
      return DateTimeRange(start: todayStart.subtract(const Duration(days: 29)), end: todayEnd);
    case ReportDateRange.thisMonth:
      return DateTimeRange(start: DateTime(now.year, now.month, 1), end: todayEnd);
    case ReportDateRange.custom:
      return custom ?? DateTimeRange(start: todayStart.subtract(const Duration(days: 7)), end: todayEnd);
  }
}

final activeResolvedDateRangeProvider = Provider<DateTimeRange>((ref) {
  final filter = ref.watch(selectedDateRangeProvider);
  final custom = ref.watch(customDateRangeProvider);
  return _resolveDateRange(filter, custom);
});

/// Filtered orders matching the selected date range
final filteredOrdersForReportsProvider = Provider<List<RestaurantOrder>>((ref) {
  final orders = ref.watch(ordersProvider);
  final range = ref.watch(activeResolvedDateRangeProvider);

  return orders.where((o) {
    return o.createdAt.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
        o.createdAt.isBefore(range.end.add(const Duration(seconds: 1)));
  }).toList();
});

/// Primary Sales KPI summary
final salesSummaryProvider = Provider<SalesSummary>((ref) {
  final orders = ref.watch(filteredOrdersForReportsProvider);
  final menuItems = ref.watch(menuItemsProvider);

  // Helper map for food cost
  final foodCostMap = {for (final m in menuItems) m.id: m.foodCost};

  double gross = 0.0;
  double discounts = 0.0;
  double cgst = 0.0;
  double sgst = 0.0;
  double foodCost = 0.0;

  int paidCount = 0;
  int unpaidCount = 0;
  int cancelledCount = 0;

  for (final o in orders) {
    if (o.orderStatus == OrderStatus.cancelled) {
      cancelledCount++;
      continue;
    }

    // Only count paid or completed orders for revenue
    final isPaid = o.paymentStatus == PaymentStatus.paid || o.orderStatus == OrderStatus.completed || o.orderStatus == OrderStatus.served;

    if (isPaid) {
      paidCount++;
      gross += o.subtotal;
      discounts += o.discountAmount;
      cgst += o.cgstAmount;
      sgst += o.sgstAmount;

      for (final item in o.items) {
        final unitCost = foodCostMap[item.menuItemId] ?? (item.unitPrice * 0.30);
        foodCost += unitCost * item.quantity;
      }
    } else {
      unpaidCount++;
    }
  }

  final net = gross - discounts;
  final avg = paidCount > 0 ? (net + cgst + sgst) / paidCount : 0.0;
  final grossProfit = net - foodCost;

  return SalesSummary(
    grossSales: gross,
    totalDiscounts: discounts,
    cgstCollected: cgst,
    sgstCollected: sgst,
    netSales: net,
    paidOrdersCount: paidCount,
    unpaidOrdersCount: unpaidCount,
    cancelledOrdersCount: cancelledCount,
    averageOrderValue: avg,
    estimatedFoodCost: foodCost,
    estimatedGrossProfit: grossProfit,
  );
});

/// Product & Dish Analytics
final productAnalyticsProvider = Provider<List<ProductSalesMetric>>((ref) {
  final orders = ref.watch(filteredOrdersForReportsProvider);
  final menuItems = ref.watch(menuItemsProvider);
  final menuMap = {for (final m in menuItems) m.id: m};

  final Map<String, ProductSalesMetric> map = {};

  for (final o in orders) {
    if (o.orderStatus == OrderStatus.cancelled) continue;
    final isPaid = o.paymentStatus == PaymentStatus.paid || o.orderStatus == OrderStatus.completed || o.orderStatus == OrderStatus.served;
    if (!isPaid) continue;

    for (final item in o.items) {
      final key = item.menuItemId;
      final existing = map[key];
      final menuItem = menuMap[key];
      final unitCost = menuItem?.foodCost ?? (item.unitPrice * 0.30);
      final category = menuItem?.category ?? 'Main Course';

      if (existing != null) {
        map[key] = ProductSalesMetric(
          menuItemId: key,
          itemName: existing.itemName,
          category: category,
          quantitySold: existing.quantitySold + item.quantity,
          totalRevenue: existing.totalRevenue + item.totalPrice,
          unitFoodCost: unitCost,
          totalFoodCost: existing.totalFoodCost + (unitCost * item.quantity),
        );
      } else {
        map[key] = ProductSalesMetric(
          menuItemId: key,
          itemName: item.name,
          category: category,
          quantitySold: item.quantity,
          totalRevenue: item.totalPrice,
          unitFoodCost: unitCost,
          totalFoodCost: unitCost * item.quantity,
        );
      }
    }
  }

  final list = map.values.toList();
  list.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
  return list;
});

/// Payment Tender Breakdown (Cash, UPI, Card)
final paymentAnalyticsProvider = Provider<PaymentBreakdown>((ref) {
  final orders = ref.watch(filteredOrdersForReportsProvider);

  double cashTotal = 0.0;
  int cashCount = 0;
  double upiTotal = 0.0;
  int upiCount = 0;
  double cardTotal = 0.0;
  int cardCount = 0;

  for (final o in orders) {
    if (o.orderStatus == OrderStatus.cancelled) continue;
    final isPaid = o.paymentStatus == PaymentStatus.paid || o.orderStatus == OrderStatus.completed || o.orderStatus == OrderStatus.served;
    if (!isPaid) continue;

    final method = (o.paymentMethod ?? 'Demo Cash').toLowerCase();

    if (method.contains('upi')) {
      upiTotal += o.grandTotal;
      upiCount++;
    } else if (method.contains('card')) {
      cardTotal += o.grandTotal;
      cardCount++;
    } else {
      cashTotal += o.grandTotal;
      cashCount++;
    }
  }

  return PaymentBreakdown(
    cashTotal: cashTotal,
    cashCount: cashCount,
    upiTotal: upiTotal,
    upiCount: upiCount,
    cardTotal: cardTotal,
    cardCount: cardCount,
  );
});
