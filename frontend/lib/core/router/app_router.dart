// Anabhay Ventures — Application Router Configuration

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/pos/presentation/screens/pos_billing_screen.dart';
import '../../features/kitchen/presentation/screens/kds_screen.dart';
import '../../features/tables/presentation/screens/table_management_screen.dart';
import '../../features/menu/presentation/screens/menu_management_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/customer_qr/presentation/screens/customer_qr_menu_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/module_placeholder_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Standalone Customer QR Menu Route (No owner sidebar)
    GoRoute(
      path: '/qr-menu',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CustomerQRMenuScreen(),
    ),
    GoRoute(
      path: '/qr/:table',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => CustomerQRMenuScreen(
        tableNumber: state.pathParameters['table'] ?? 'Table 04',
      ),
    ),

    // Restaurant Operations Shell (Sidebar + Top bar navigation)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/pos',
          builder: (context, state) => const POSBillingScreen(),
        ),
        GoRoute(
          path: '/kitchen',
          builder: (context, state) => const KDSScreen(),
        ),
        GoRoute(
          path: '/tables',
          builder: (context, state) => const TableManagementScreen(),
        ),
        GoRoute(
          path: '/menu',
          builder: (context, state) => const MenuManagementScreen(),
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const KDSScreen(),
        ),
        GoRoute(
          path: '/purchases',
          builder: (context, state) => const ModulePlaceholderScreen(
            title: 'Purchase & Supplier Management',
            phase: 'Phase 10 Scheduled',
            description: 'Vendor directories, automated purchase orders, goods receipt notes (GRN), and payment tracking.',
            icon: Icons.shopping_cart_outlined,
          ),
        ),
        GoRoute(
          path: '/staff',
          builder: (context, state) => const ModulePlaceholderScreen(
            title: 'Staff & Shift Management',
            phase: 'Phase 11 Scheduled',
            description: 'Employee profiles, role-based access, attendance logs, shifts, tips, and performance analytics.',
            icon: Icons.badge_outlined,
          ),
        ),
        GoRoute(
          path: '/customers',
          builder: (context, state) => const ModulePlaceholderScreen(
            title: 'Customer Relationship & Loyalty',
            phase: 'Phase 11 Scheduled',
            description: 'Customer profiles, order frequency, loyalty reward points, coupons, and feedback collection.',
            icon: Icons.favorite_border_rounded,
          ),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ModulePlaceholderScreen(
            title: 'Analytics & Financial Reports',
            phase: 'Phase 13 Scheduled',
            description: 'Sales summaries, tax reports, food cost calculation, wastage reports, and PDF/Excel exports.',
            icon: Icons.bar_chart_rounded,
          ),
        ),
        GoRoute(
          path: '/expenses',
          builder: (context, state) => const ModulePlaceholderScreen(
            title: 'Expense Management',
            phase: 'Phase 11 Scheduled',
            description: 'Daily operational expenses, petty cash, vendor disbursements, and category breakdown.',
            icon: Icons.receipt_long_outlined,
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const ModulePlaceholderScreen(
            title: 'Restaurant & System Settings',
            phase: 'Phase 4 & 5 Scheduled',
            description: 'Branch profiles, taxation settings, receipt header customisation, printer bridges, and user roles.',
            icon: Icons.tune_rounded,
          ),
        ),
      ],
    ),
  ],
);
