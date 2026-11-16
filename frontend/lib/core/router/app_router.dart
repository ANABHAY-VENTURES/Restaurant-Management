// Anabhay Ventures — Application Router Configuration
// Phase 1 & Phase 2: Navigation & Authentication Shell

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/owner_registration_wizard_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/create_new_password_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/staff/presentation/screens/staff_management_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/pos/presentation/screens/pos_billing_screen.dart';
import '../../features/kitchen/presentation/screens/kds_screen.dart';
import '../../features/tables/presentation/screens/table_management_screen.dart';
import '../../features/menu/presentation/screens/menu_management_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/customer_qr/presentation/screens/customer_qr_menu_screen.dart';
import '../../features/customer_qr/presentation/screens/customer_order_tracking_screen.dart';
import '../../features/customer_qr/presentation/screens/qr_management_screen.dart';
import '../../features/customers/presentation/screens/customer_management_screen.dart';
import '../../features/reports/presentation/screens/reports_analytics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/module_placeholder_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // ── Authentication & Onboarding Routes ─────────────────────
    GoRoute(
      path: '/welcome',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register-owner',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OwnerRegistrationWizardScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OtpVerificationScreen(),
    ),
    GoRoute(
      path: '/create-new-password',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateNewPasswordScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EmailVerificationScreen(),
    ),

    // ── Standalone Customer QR Menu Route (No owner sidebar) ───
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
    GoRoute(
      path: '/track-order/:orderId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => CustomerOrderTrackingScreen(
        orderId: state.pathParameters['orderId'] ?? '',
      ),
    ),

    // ── Restaurant Operations Shell (Sidebar + Top bar) ────────
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
          path: '/qr-codes',
          builder: (context, state) => const QRManagementScreen(),
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
          path: '/staff',
          builder: (context, state) => const StaffManagementScreen(),
        ),
        GoRoute(
          path: '/purchases',
          builder: (context, state) => const InventoryScreen(),
        ),
        GoRoute(
          path: '/customers',
          builder: (context, state) => const CustomerManagementScreen(),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsAnalyticsScreen(),
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
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
