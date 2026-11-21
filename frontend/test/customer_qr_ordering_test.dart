// Anabhay Ventures — Phase 5 Customer QR Ordering, Mobile Menu & Live Order Tracking Tests

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_management/features/pos/data/restaurant_storage_repository.dart';
import 'package:restaurant_management/features/pos/domain/models/order_models.dart';
import 'package:restaurant_management/features/pos/presentation/providers/pos_providers.dart';
import 'package:restaurant_management/features/inventory/domain/models/inventory_models.dart';
import 'package:restaurant_management/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:restaurant_management/features/customer_qr/presentation/providers/customer_cart_provider.dart';
import 'package:restaurant_management/features/customer_qr/presentation/widgets/qr_painter.dart';
import 'package:restaurant_management/features/customer_qr/presentation/screens/qr_management_screen.dart';
import 'package:restaurant_management/features/customer_qr/presentation/screens/customer_qr_menu_screen.dart';
import 'package:restaurant_management/features/customer_qr/presentation/screens/customer_order_tracking_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 5: QR Code Matrix & Generator Engine', () {
    test('Generates valid 25x25 QR matrix with compliant finder & timing patterns', () {
      const url = 'https://royalsaffron.anabhay.com/#/qr/Table%2005';
      final matrix = QrMatrixGenerator.generate(url);

      expect(matrix.length, equals(25));
      expect(matrix[0].length, equals(25));

      // Check Top-Left 7x7 Finder Pattern outer border
      for (int c = 0; c < 7; c++) {
        expect(matrix[0][c], isTrue);
        expect(matrix[6][c], isTrue);
      }
      for (int r = 0; r < 7; r++) {
        expect(matrix[r][0], isTrue);
        expect(matrix[r][6], isTrue);
      }
      // Inner 3x3 dark square
      expect(matrix[2][2], isTrue);
      expect(matrix[3][3], isTrue);
      expect(matrix[4][4], isTrue);

      // Check Top-Right Finder Pattern
      expect(matrix[0][18], isTrue);
      expect(matrix[0][24], isTrue);
      expect(matrix[6][18], isTrue);
      expect(matrix[6][24], isTrue);

      // Check Bottom-Left Finder Pattern
      expect(matrix[18][0], isTrue);
      expect(matrix[24][0], isTrue);

      // Check Timing Pattern alternating modules at row 6 and col 6
      expect(matrix[6][8], isTrue);
      expect(matrix[6][9], isFalse);
      expect(matrix[6][10], isTrue);
      expect(matrix[8][6], isTrue);
      expect(matrix[9][6], isFalse);
      expect(matrix[10][6], isTrue);
    });
  });

  group('Phase 5: Customer Cart Calculation & Variants Engine', () {
    test('Calculates base price, portion variant and add-on combinations correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const biryani = MenuItem(
        id: 'biryani-01',
        name: 'Murgh Awadhi Dum Biryani',
        category: 'Rice & Biryani',
        basePrice: 240.0,
        isVeg: false,
        variants: [
          ItemVariant(name: 'Half Portion', additionalPrice: 0.0),
          ItemVariant(name: 'Full Portion', additionalPrice: 140.0),
        ],
        addOns: [
          ItemAddOn(id: 'addon-1', name: 'Extra Chicken Pieces', price: 80.0),
          ItemAddOn(id: 'addon-2', name: 'Burani Garlic Raita', price: 30.0),
        ],
      );

      const coldCoffee = MenuItem(
        id: 'beverage-01',
        name: 'Royal Cold Brew',
        category: 'Beverages',
        basePrice: 160.0,
        isVeg: true,
      );

      final notifier = container.read(customerCartProvider.notifier);

      // Add 2× Full Portion Biryani with Extra Chicken + Raita
      notifier.addItem(
        menuItem: biryani,
        variant: biryani.variants[1], // Full: +140 -> 380 each
        addOns: [biryani.addOns[0], biryani.addOns[1]], // +80 +30 = +110 -> 490 each
        instructions: 'Less spicy, extra crisp fried onions',
        quantity: 2,
      );

      // Add 1× Cold Coffee (160 each)
      notifier.addItem(
        menuItem: coldCoffee,
        quantity: 1,
      );

      final cart = container.read(customerCartProvider);

      expect(cart.items.length, equals(2));
      expect(cart.totalItemCount, equals(3));

      // Biryani line: (240 + 140 + 80 + 30) * 2 = 490 * 2 = 980
      expect(cart.items[0].totalPrice, equals(980.0));
      // Cold coffee line: 160 * 1 = 160
      expect(cart.items[1].totalPrice, equals(160.0));

      // Subtotal: 980 + 160 = 1140
      expect(cart.subtotal, equals(1140.0));
      // CGST (2.5%): 1140 * 0.025 = 28.50
      expect(cart.cgstAmount, equals(28.50));
      // SGST (2.5%): 1140 * 0.025 = 28.50
      expect(cart.sgstAmount, equals(28.50));
      // Grand Total: 1140 + 28.50 + 28.50 = 1197.0
      expect(cart.grandTotal, equals(1197.0));
    });

    test('Increases, decreases and removes cart items properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const item = MenuItem(
        id: 'test-1',
        name: 'Paneer Tikka',
        category: 'Starters',
        basePrice: 280.0,
        isVeg: true,
      );

      final notifier = container.read(customerCartProvider.notifier);
      notifier.addItem(menuItem: item, quantity: 2);

      expect(container.read(customerCartProvider).totalItemCount, equals(2));

      notifier.updateQuantity(0, 1);
      expect(container.read(customerCartProvider).totalItemCount, equals(3));

      notifier.updateQuantity(0, -1);
      expect(container.read(customerCartProvider).totalItemCount, equals(2));

      notifier.removeItem(0);
      expect(container.read(customerCartProvider).items.isEmpty, isTrue);
    });
  });

  group('Phase 5: Complete End-to-End Workflow with KDS & Live Tracking', () {
    test('Places customer order, creates KOT, updates table, and drives live 4-stage tracking', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final ordersNotifier = container.read(ordersProvider.notifier);
      final tablesNotifier = container.read(tablesProvider.notifier);

      // 1. Customer places order from Table 05
      const biryaniItem = OrderItem(
        id: 'ord-item-1',
        menuItemId: 'menu-1',
        name: 'Murgh Awadhi Dum Biryani',
        unitPrice: 380.0,
        quantity: 2,
        isVeg: false,
        variantName: 'Full Portion',
        selectedAddOns: ['Burani Garlic Raita'],
        addOnsTotal: 30.0,
      );

      const coffeeItem = OrderItem(
        id: 'ord-item-2',
        menuItemId: 'menu-8',
        name: 'Royal Cold Brew',
        unitPrice: 160.0,
        quantity: 1,
        isVeg: true,
      );

      final placedOrder = ordersNotifier.createOrder(
        tableNumber: 'Table 05',
        orderType: OrderType.dineIn,
        items: [biryaniItem, coffeeItem],
        customerName: 'Aarav Malhotra',
        customerPhone: '+91 98765 43210',
        generalInstructions: 'Table QR digital order',
      );

      // 2. Verify Order properties & KOT ticket
      expect(placedOrder.tableNumber, equals('Table 05'));
      expect(placedOrder.kotNumber, startsWith('KOT-'));
      expect(placedOrder.orderStatus, equals(OrderStatus.newOrder));
      expect(placedOrder.paymentStatus, equals(PaymentStatus.pending));
      expect(placedOrder.hasInventoryDeducted, isTrue);

      // 3. Verify Table 05 is now occupied
      final table05 = container.read(tablesProvider).firstWhere((t) => t.number == 'Table 05');
      expect(table05.status, equals(TableStatus.occupied));
      expect(table05.activeOrderId, equals(placedOrder.id));

      // 4. Kitchen staff starts preparing (Step 2: Preparing)
      ordersNotifier.updateOrderStatus(placedOrder.id, OrderStatus.preparing);
      var trackedOrder = container.read(ordersProvider).firstWhere((o) => o.id == placedOrder.id);
      expect(trackedOrder.orderStatus, equals(OrderStatus.preparing));

      // 5. Kitchen marks order ready (Step 3: Ready)
      ordersNotifier.updateOrderStatus(placedOrder.id, OrderStatus.ready);
      trackedOrder = container.read(ordersProvider).firstWhere((o) => o.id == placedOrder.id);
      expect(trackedOrder.orderStatus, equals(OrderStatus.ready));

      // 6. Waiter serves the order (Step 4: Served)
      ordersNotifier.updateOrderStatus(placedOrder.id, OrderStatus.served);
      trackedOrder = container.read(ordersProvider).firstWhere((o) => o.id == placedOrder.id);
      expect(trackedOrder.orderStatus, equals(OrderStatus.served));
    });

    test('Prevents duplicate inventory deduction across KOT kitchen lifecycle transitions', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialIngredients = container.read(ingredientsProvider);
      final chicken = initialIngredients.firstWhere((i) => i.name.contains('Chicken'));
      final initialStock = chicken.currentStock;

      final ordersNotifier = container.read(ordersProvider.notifier);

      final order = ordersNotifier.createOrder(
        tableNumber: 'Table 03',
        orderType: OrderType.dineIn,
        items: [
          const OrderItem(
            id: 'ord-chk-1',
            menuItemId: 'm1', // Matches default recipe for Chicken Dum Biryani
            name: 'Chicken Dum Biryani',
            unitPrice: 380.0,
            quantity: 1,
            isVeg: false,
          ),
        ],
      );

      final stockAfterOrder = container.read(ingredientsProvider).firstWhere((i) => i.id == chicken.id).currentStock;
      expect(stockAfterOrder, lessThan(initialStock));

      // Kitchen lifecycle changes: Preparing -> Ready -> Served
      ordersNotifier.updateOrderStatus(order.id, OrderStatus.preparing);
      ordersNotifier.updateOrderStatus(order.id, OrderStatus.ready);
      ordersNotifier.updateOrderStatus(order.id, OrderStatus.served);

      final stockAfterTransitions = container.read(ingredientsProvider).firstWhere((i) => i.id == chicken.id).currentStock;
      // Stock must NOT have deducted again!
      expect(stockAfterTransitions, equals(stockAfterOrder));
    });
  });

  group('Phase 5: UI Widgets Rendering Tests', () {
    testWidgets('QRManagementScreen renders table standee cards and metrics', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: QRManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Table QR Management'), findsOneWidget);
      expect(find.text('Configured Tables'), findsOneWidget);
      expect(find.text('Print Standee Sheet'), findsOneWidget);
      expect(find.text('Table 01'), findsWidgets);
    });

    testWidgets('CustomerQRMenuScreen renders dishes, category selector and table header', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(480, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CustomerQRMenuScreen(tableNumber: 'Table 05'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('THE ROYAL SAFFRON'), findsWidgets);
      expect(find.text('Table 05 • Digital Guest Menu'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // Search bar
    });

    testWidgets('CustomerOrderTrackingScreen renders 4-stage progress stepper and order breakdown', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(480, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const SizedBox(),
        ),
      );
      await tester.pumpAndSettle();

      final order = container.read(ordersProvider.notifier).createOrder(
        tableNumber: 'Table 05',
        orderType: OrderType.dineIn,
        items: [
          const OrderItem(
            id: 'item-demo-1',
            menuItemId: 'menu-1',
            name: 'Murgh Awadhi Dum Biryani',
            unitPrice: 380.0,
            quantity: 2,
            isVeg: false,
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CustomerOrderTrackingScreen(orderId: order.id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Table 05 • Live Kitchen Tracking'), findsOneWidget);
      expect(find.text('Live Kitchen Progress'), findsOneWidget);
      expect(find.text('Order Received by Kitchen'), findsOneWidget);
      expect(find.text('Murgh Awadhi Dum Biryani'), findsOneWidget);
      expect(find.text('Order More Items'), findsOneWidget);
    });
  });
}
