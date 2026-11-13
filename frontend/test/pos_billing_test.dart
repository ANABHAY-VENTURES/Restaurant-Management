// Anabhay Ventures — Phase 3 POS Billing, KDS, Tables & Financial Calculation Tests

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_management/features/pos/data/restaurant_storage_repository.dart';
import 'package:restaurant_management/features/pos/domain/models/order_models.dart';
import 'package:restaurant_management/features/pos/presentation/providers/pos_providers.dart';
import 'package:restaurant_management/features/pos/presentation/screens/pos_billing_screen.dart';
import 'package:restaurant_management/features/kitchen/presentation/screens/kds_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Phase 3: Financial & Cart Calculation Engine', () {
    test('Calculates subtotal, 2.5% CGST, 2.5% SGST and grand total correctly', () {
      const item1 = OrderItem(
        id: 'i1',
        menuItemId: 'm1',
        name: 'Chicken Dum Biryani',
        unitPrice: 480.0,
        quantity: 2,
        isVeg: false,
      );
      const item2 = OrderItem(
        id: 'i2',
        menuItemId: 'm2',
        name: 'Butter Naan',
        unitPrice: 90.0,
        quantity: 1,
        isVeg: true,
      );

      final cart = const PosCartState(
        selectedTable: 'Table 05',
        items: [item1, item2],
      );

      // 480 * 2 + 90 = 1050
      expect(cart.subtotal, 1050.0);
      expect(cart.discountAmount, 0.0);
      // CGST: 1050 * 0.025 = 26.25
      expect(cart.cgst, 26.25);
      // SGST: 1050 * 0.025 = 26.25
      expect(cart.sgst, 26.25);
      // Grand Total: 1050 + 26.25 + 26.25 = 1102.50
      expect(cart.grandTotal, 1102.50);
      expect(cart.totalItemCount, 3);
    });

    test('Applies percentage discount before calculating GST', () {
      const item = OrderItem(
        id: 'i1',
        menuItemId: 'm1',
        name: 'Saffron Dum Biryani',
        unitPrice: 500.0,
        quantity: 2,
        isVeg: false,
      );

      // Subtotal = 1000, 10% discount = 100 off, taxable = 900
      final cart = const PosCartState(
        items: [item],
        discountPercent: 10.0,
      );

      expect(cart.subtotal, 1000.0);
      expect(cart.discountAmount, 100.0);
      expect(cart.taxableAmount, 900.0);
      expect(cart.cgst, 22.50); // 900 * 0.025
      expect(cart.sgst, 22.50); // 900 * 0.025
      expect(cart.grandTotal, 945.0); // 900 + 45
    });

    test('Applies fixed amount discount correctly', () {
      const item = OrderItem(
        id: 'i1',
        menuItemId: 'm1',
        name: 'Curry Banquet',
        unitPrice: 1000.0,
        quantity: 1,
        isVeg: false,
      );

      final cart = const PosCartState(
        items: [item],
        fixedDiscountAmount: 200.0,
      );

      expect(cart.subtotal, 1000.0);
      expect(cart.discountAmount, 200.0);
      expect(cart.taxableAmount, 800.0);
      expect(cart.cgst, 20.0);
      expect(cart.sgst, 20.0);
      expect(cart.grandTotal, 840.0);
    });
  });

  group('Phase 3: Complete Requirement 8 Demo Workflow', () {
    test('Executes full Table 05 -> KDS -> Settle Bill -> Release Table lifecycle', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 1. Verify Table 05 is initially Available
      final initialTables = container.read(tablesProvider);
      final table05 = initialTables.firstWhere((t) => t.number == 'Table 05');
      expect(table05.status, TableStatus.available);

      // 2. Select Table 05 in POS
      container.read(posCartProvider.notifier).setSelectedTable('Table 05');

      // 3 & 4. Add 2 Chicken Dum Biryanis and 1 Butter Naan
      final menuItems = container.read(menuItemsProvider);
      final biryani = menuItems.firstWhere((m) => m.name == 'Chicken Dum Biryani');
      final naan = menuItems.firstWhere((m) => m.name == 'Butter Naan');

      container.read(posCartProvider.notifier).addItem(biryani);
      container.read(posCartProvider.notifier).addItem(biryani);
      container.read(posCartProvider.notifier).addItem(naan);

      // 5. Add cooking instruction
      container.read(posCartProvider.notifier).setSpecialInstructions('Less spicy, extra gravy');

      final cartState = container.read(posCartProvider);
      expect(cartState.items.length, 2);
      expect(cartState.items.firstWhere((i) => i.name == 'Chicken Dum Biryani').quantity, 2);
      expect(cartState.items.firstWhere((i) => i.name == 'Butter Naan').quantity, 1);
      expect(cartState.specialInstructions, 'Less spicy, extra gravy');

      // 6. Place Order (Send KOT)
      final placedOrder = container.read(posCartProvider.notifier).placeOrder();
      expect(placedOrder.tableNumber, 'Table 05');
      expect(placedOrder.orderStatus, OrderStatus.newOrder);
      expect(placedOrder.generalInstructions, 'Less spicy, extra gravy');

      // Verify Table 05 is now Occupied with active bill
      final updatedTables = container.read(tablesProvider);
      final occupiedTable05 = updatedTables.firstWhere((t) => t.number == 'Table 05');
      expect(occupiedTable05.status, TableStatus.occupied);
      expect(occupiedTable05.activeOrderId, placedOrder.id);
      expect(occupiedTable05.currentBill, placedOrder.grandTotal);

      // 7 & 8. Verify Kitchen KDS has the order
      final orders = container.read(ordersProvider);
      final kdsOrder = orders.firstWhere((o) => o.id == placedOrder.id);
      expect(kdsOrder.tableNumber, 'Table 05');
      expect(kdsOrder.orderStatus, OrderStatus.newOrder);

      // 9. Change status to Preparing
      container.read(ordersProvider.notifier).updateOrderStatus(placedOrder.id, OrderStatus.preparing);
      expect(
        container.read(ordersProvider).firstWhere((o) => o.id == placedOrder.id).orderStatus,
        OrderStatus.preparing,
      );

      // 10. Change status to Ready
      container.read(ordersProvider.notifier).updateOrderStatus(placedOrder.id, OrderStatus.ready);
      expect(
        container.read(ordersProvider).firstWhere((o) => o.id == placedOrder.id).orderStatus,
        OrderStatus.ready,
      );

      // 11. Mark order Served
      container.read(ordersProvider.notifier).updateOrderStatus(placedOrder.id, OrderStatus.served);
      expect(
        container.read(ordersProvider).firstWhere((o) => o.id == placedOrder.id).orderStatus,
        OrderStatus.served,
      );

      // 12, 13 & 14. Return to POS, settle bill with Demo Cash
      final invoice = container.read(ordersProvider.notifier).settleOrder(
            placedOrder.id,
            paymentMethod: 'Demo Cash',
          );

      // 15. Verify Invoice generated
      expect(invoice.orderId, placedOrder.id);
      expect(invoice.tableNumber, 'Table 05');
      expect(invoice.paymentMethod, 'Demo Cash');
      expect(invoice.paymentStatus, 'PAID (DEMO)');
      expect(invoice.grandTotal, placedOrder.grandTotal);

      // 16. Verify Table 05 is Released back to Available
      final finalTables = container.read(tablesProvider);
      final releasedTable05 = finalTables.firstWhere((t) => t.number == 'Table 05');
      expect(releasedTable05.status, TableStatus.available);
      expect(releasedTable05.activeOrderId, isNull);
      expect(releasedTable05.currentBill, 0.0);

      // 17. Verify Dashboard Metrics updated
      final metrics = container.read(dashboardMetricsProvider);
      expect(metrics.recentTransactions.any((inv) => inv.orderId == placedOrder.id), isTrue);
      expect(metrics.todaySales, greaterThan(148250.0));
    });
  });

  group('Phase 3: Domain Model & Persistence Serialization', () {
    test('MenuItem to/from JSON matches exactly', () {
      const item = MenuItem(
        id: 'test_m1',
        name: 'Murgh Malai Tikka',
        category: 'Starters',
        basePrice: 460.0,
        isVeg: false,
        variants: [ItemVariant(name: 'Single', additionalPrice: 0.0)],
        addOns: [ItemAddOn(id: 'a1', name: 'Mint Chutney', price: 30.0)],
      );

      final json = item.toJson();
      final revived = MenuItem.fromJson(json);

      expect(revived.id, item.id);
      expect(revived.name, item.name);
      expect(revived.basePrice, item.basePrice);
      expect(revived.variants.first.name, 'Single');
      expect(revived.addOns.first.name, 'Mint Chutney');
    });

    test('RestaurantOrder to/from JSON preserves all financial snapshots', () {
      final now = DateTime.now();
      final order = RestaurantOrder(
        id: 'ORD-999',
        kotNumber: 'KOT-999',
        orderType: OrderType.dineIn,
        tableNumber: 'Table 05',
        items: const [
          OrderItem(
            id: 'oi1',
            menuItemId: 'm1',
            name: 'Chicken Dum Biryani',
            unitPrice: 480.0,
            quantity: 2,
            isVeg: false,
          ),
        ],
        subtotal: 960.0,
        cgstAmount: 24.0,
        sgstAmount: 24.0,
        grandTotal: 1008.0,
        orderStatus: OrderStatus.newOrder,
        paymentStatus: PaymentStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      final json = order.toJson();
      final revived = RestaurantOrder.fromJson(json);

      expect(revived.id, 'ORD-999');
      expect(revived.kotNumber, 'KOT-999');
      expect(revived.items.length, 1);
      expect(revived.items.first.name, 'Chicken Dum Biryani');
      expect(revived.grandTotal, 1008.0);
    });
  });

  group('Phase 3: UI Screen Widget Tests', () {
    testWidgets('POSBillingScreen renders menu, search bar, categories and cart panel', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: POSBillingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(POSBillingScreen), findsOneWidget);
      expect(find.text('Current Bill'), findsOneWidget);
      expect(find.text('Send KOT'), findsOneWidget);
      expect(find.text('Pay & Settle'), findsOneWidget);
      expect(find.text('Chicken Dum Biryani'), findsWidgets);
    });

    testWidgets('KDSScreen renders Kitchen Display header, status filters and KOT cards', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: KDSScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kitchen Display System (KDS)'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
      expect(find.text('Preparing'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Served'), findsOneWidget);
    });
  });
}
