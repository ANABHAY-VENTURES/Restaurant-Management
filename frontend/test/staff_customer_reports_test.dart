// Anabhay Ventures — Phase 6 Staff Management, Customer CRM & Reports Analytics Tests

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_management/features/pos/domain/models/order_models.dart';
import 'package:restaurant_management/features/pos/presentation/providers/pos_providers.dart';
import 'package:restaurant_management/features/staff/domain/models/staff_models.dart';
import 'package:restaurant_management/features/staff/presentation/providers/staff_providers.dart';
import 'package:restaurant_management/features/staff/presentation/screens/staff_management_screen.dart';
import 'package:restaurant_management/features/customers/domain/models/customer_models.dart';
import 'package:restaurant_management/features/customers/presentation/providers/customer_providers.dart';
import 'package:restaurant_management/features/customers/presentation/screens/customer_management_screen.dart';
import 'package:restaurant_management/features/reports/domain/models/report_models.dart';
import 'package:restaurant_management/features/reports/presentation/providers/report_providers.dart';
import 'package:restaurant_management/features/reports/presentation/screens/reports_analytics_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 6: Staff Management & Attendance Lifecycle', () {
    test('Adds a new chef, edits details, marks attendance, and calculates roster metrics', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final staffNotifier = container.read(staffProvider.notifier);
      final attendanceNotifier = container.read(attendanceProvider.notifier);

      // 1. Add new chef
      await staffNotifier.addStaff(
        name: 'Chef Ranveer Brar',
        phone: '+91 98999 11223',
        email: 'ranveer@royalsaffron.com',
        role: StaffRole.chef,
        monthlySalary: 70000.0,
        address: 'Defence Colony, New Delhi',
        notes: 'Celebrity Awadhi master chef',
      );

      final staffList = container.read(staffProvider);
      final chef = staffList.firstWhere((s) => s.name == 'Chef Ranveer Brar');
      expect(chef.role, equals(StaffRole.chef));
      expect(chef.monthlySalary, equals(70000.0));
      expect(chef.isActive, isTrue);

      // 2. Edit chef details
      await staffNotifier.updateStaff(
        chef.copyWith(monthlySalary: 75000.0, notes: 'Promoted to Culinary Director'),
      );
      final updatedChef = container.read(staffProvider).firstWhere((s) => s.id == chef.id);
      expect(updatedChef.monthlySalary, equals(75000.0));
      expect(updatedChef.notes, equals('Promoted to Culinary Director'));

      // 3. Mark attendance
      final today = DateTime.now();
      await attendanceNotifier.markAttendance(
        staffId: chef.id,
        staffName: chef.name,
        date: today,
        status: AttendanceStatus.present,
        checkInTime: '09:45 AM',
        checkOutTime: '06:30 PM',
      );

      final attendanceList = container.read(attendanceProvider);
      final todayRecord = attendanceList.firstWhere((a) => a.staffId == chef.id);
      expect(todayRecord.status, equals(AttendanceStatus.present));
      expect(todayRecord.checkInTime, equals('09:45 AM'));

      // 4. Verify staff metrics
      final metrics = container.read(staffMetricsProvider);
      expect(metrics.totalStaff, greaterThanOrEqualTo(8));
      expect(metrics.onDutyToday, greaterThanOrEqualTo(1));
    });
  });

  group('Phase 6: Customer CRM & Loyalty Rewards Engine', () {
    test('Registers customer, updates dining history from completed order, awards loyalty points, and redeems voucher', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final customersNotifier = container.read(customersProvider.notifier);

      // 1. Add customer manually
      final cust = await customersNotifier.addCustomerManually(
        name: 'Kabir Thapar',
        phone: '+91 99112 33445',
        email: 'kabir@adventure.com',
        birthday: '24 July',
        address: 'Hauz Khas, New Delhi',
        notes: 'Loves Biryani. Sits in Terrace Garden.',
      );

      expect(cust.name, equals('Kabir Thapar'));
      expect(cust.totalOrders, equals(0));
      expect(cust.loyaltyPoints, equals(0));

      // 2. Order completion auto-update (Customer spends ₹1,200)
      await customersNotifier.addOrUpdateFromOrder(
        name: 'Kabir Thapar',
        phone: '+91 99112 33445',
        orderAmount: 1200.0,
        orderId: 'ORD-991',
      );

      final updatedCust = container.read(customersProvider).firstWhere((c) => c.phone == '+91 99112 33445');
      expect(updatedCust.totalOrders, equals(1));
      expect(updatedCust.totalSpend, equals(1200.0));
      // 1 pt per ₹20 spent: 1200 / 20 = 60 points earned
      expect(updatedCust.loyaltyPoints, equals(60));

      // Verify loyalty ledger
      final loyaltyTxs = container.read(loyaltyProvider);
      final tx = loyaltyTxs.firstWhere((t) => t.customerId == updatedCust.id);
      expect(tx.points, equals(60));
      expect(tx.type, equals('earned'));

      // 3. Redeem 50 points for ₹50 discount voucher
      await customersNotifier.redeemPoints(
        customerId: updatedCust.id,
        pointsToRedeem: 50,
        discountValue: 50.0,
      );

      final redeemedCust = container.read(customersProvider).firstWhere((c) => c.id == updatedCust.id);
      expect(redeemedCust.loyaltyPoints, equals(10)); // 60 - 50 = 10 points left

      // Verify redemption ledger
      final redemptionTx = container.read(loyaltyProvider).firstWhere((t) => t.customerId == updatedCust.id && t.type == 'redeemed');
      expect(redemptionTx.points, equals(-50));
    });

    test('Prevents duplicate customer profile creation when same phone number is used', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final customersNotifier = container.read(customersProvider.notifier);

      await customersNotifier.addCustomerManually(
        name: 'Zoya Akhtar',
        phone: '+91 98888 77777',
      );

      // Add again with same phone
      await customersNotifier.addCustomerManually(
        name: 'Zoya Akhtar Updated',
        phone: '+91 98888 77777',
      );

      final matching = container.read(customersProvider).where((c) => c.phone == '+91 98888 77777').toList();
      expect(matching.length, equals(1));
      expect(matching.first.name, equals('Zoya Akhtar Updated'));
    });
  });

  group('Phase 6: Financial Reports, Analytics & Auditing Engine', () {
    test('Calculates sales summary distinguishing paid from unpaid and cancelled orders', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final ordersNotifier = container.read(ordersProvider.notifier);

      // Paid Order
      final paidOrder = ordersNotifier.createOrder(
        tableNumber: 'Table 01',
        orderType: OrderType.dineIn,
        items: const [
          OrderItem(id: 'p1', menuItemId: 'menu-1', name: 'Murgh Awadhi Dum Biryani', unitPrice: 380.0, quantity: 2, isVeg: false),
        ],
      );
      ordersNotifier.settleOrder(paidOrder.id, paymentMethod: 'Demo UPI');

      // Unpaid Order
      ordersNotifier.createOrder(
        tableNumber: 'Table 02',
        orderType: OrderType.dineIn,
        items: const [
          OrderItem(id: 'u1', menuItemId: 'menu-2', name: 'Paneer Lababdar', unitPrice: 340.0, quantity: 1, isVeg: true),
        ],
      );

      // Cancelled Order
      final cancelledOrder = ordersNotifier.createOrder(
        tableNumber: 'Table 03',
        orderType: OrderType.dineIn,
        items: const [
          OrderItem(id: 'c1', menuItemId: 'menu-3', name: 'Butter Chicken Royale', unitPrice: 520.0, quantity: 2, isVeg: false),
        ],
      );
      ordersNotifier.cancelOrder(cancelledOrder.id);

      final summary = container.read(salesSummaryProvider);

      // Paid order is counted in revenue
      expect(summary.paidOrdersCount, greaterThanOrEqualTo(1));
      expect(summary.grossSales, greaterThanOrEqualTo(760.0));
      expect(summary.netSales, greaterThanOrEqualTo(760.0));
      // Cancelled order is recorded as voided, NOT counted in revenue
      expect(summary.cancelledOrdersCount, greaterThanOrEqualTo(1));
      // Unpaid order recorded as pending
      expect(summary.unpaidOrdersCount, greaterThanOrEqualTo(1));
    });

    test('Generates product analytics with food cost and profit margins', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final ordersNotifier = container.read(ordersProvider.notifier);

      final order = ordersNotifier.createOrder(
        tableNumber: 'Table 05',
        orderType: OrderType.dineIn,
        items: const [
          OrderItem(id: 'item-b', menuItemId: 'menu-1', name: 'Murgh Awadhi Dum Biryani', unitPrice: 380.0, quantity: 3, isVeg: false),
        ],
      );
      ordersNotifier.settleOrder(order.id, paymentMethod: 'Demo Cash');

      final productMetrics = container.read(productAnalyticsProvider);
      final biryani = productMetrics.firstWhere((p) => p.itemName.contains('Biryani'));

      expect(biryani.quantitySold, greaterThanOrEqualTo(3));
      expect(biryani.totalRevenue, greaterThanOrEqualTo(1140.0));
      expect(biryani.grossProfit, greaterThan(0.0));
    });

    test('Breakdown payments into Cash, UPI and Card correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final ordersNotifier = container.read(ordersProvider.notifier);

      final orderUpi = ordersNotifier.createOrder(
        tableNumber: 'Table 01',
        orderType: OrderType.dineIn,
        items: const [OrderItem(id: 'i1', menuItemId: 'menu-1', name: 'Biryani', unitPrice: 400.0, quantity: 1, isVeg: false)],
      );
      ordersNotifier.settleOrder(orderUpi.id, paymentMethod: 'Demo UPI');

      final orderCash = ordersNotifier.createOrder(
        tableNumber: 'Table 02',
        orderType: OrderType.dineIn,
        items: const [OrderItem(id: 'i2', menuItemId: 'menu-2', name: 'Naan', unitPrice: 100.0, quantity: 2, isVeg: true)],
      );
      ordersNotifier.settleOrder(orderCash.id, paymentMethod: 'Demo Cash');

      final payments = container.read(paymentAnalyticsProvider);
      expect(payments.upiCount, greaterThanOrEqualTo(1));
      expect(payments.cashCount, greaterThanOrEqualTo(1));
      expect(payments.totalCollected, greaterThanOrEqualTo(600.0));
    });
  });

  group('Phase 6: UI Widget Smoke Tests', () {
    testWidgets('StaffManagementScreen renders metrics, tabs and staff roster', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StaffManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Staff Management'), findsOneWidget);
      expect(find.text('Total Staff'), findsOneWidget);
      expect(find.text('Active Accounts'), findsOneWidget);
      expect(find.text('Staff Roster'), findsOneWidget);
      expect(find.text('Daily Attendance'), findsOneWidget);
      expect(find.text('Add Staff Member'), findsOneWidget);
    });

    testWidgets('CustomerManagementScreen renders guest directory, CRM metrics and VIP insights', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CustomerManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Customer Relationship & Loyalty'), findsOneWidget);
      expect(find.text('Total Registered Guests'), findsOneWidget);
      expect(find.text('Returning Patrons'), findsOneWidget);
      expect(find.text('Guest Directory'), findsOneWidget);
      expect(find.text('VIP Insights & Spenders'), findsOneWidget);
      expect(find.text('Add Customer'), findsOneWidget);
    });

    testWidgets('ReportsAnalyticsScreen renders financial KPIs, period filter chips and export bar', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportsAnalyticsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Financial Reports & Business Analytics'), findsOneWidget);
      expect(find.text('Net Revenue'), findsOneWidget);
      expect(find.text('Est. Gross Profit'), findsOneWidget);
      expect(find.text('Food Cost (Raw Materials)'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Export CSV'), findsOneWidget);
      expect(find.text('Print Summary / PDF'), findsOneWidget);
    });
  });
}
