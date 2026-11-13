// Anabhay Ventures — Phase 2 Authentication & Onboarding Tests

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_management/features/auth/presentation/screens/welcome_screen.dart';
import 'package:restaurant_management/features/auth/presentation/screens/login_screen.dart';
import 'package:restaurant_management/features/auth/presentation/screens/owner_registration_wizard_screen.dart';
import 'package:restaurant_management/features/staff/presentation/screens/staff_management_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('WelcomeScreen renders luxury branding and CTAs', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: WelcomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Restaurant Management'), findsOneWidget);
    expect(find.text('BY ANABHAY VENTURES'), findsOneWidget);
    expect(find.text('Sign In to Restaurant'), findsOneWidget);
    expect(find.text('Onboard New Restaurant (Register)'), findsOneWidget);
  });

  testWidgets('LoginScreen renders email/phone tabs and Quick Role Switcher', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Email Login'), findsOneWidget);
    expect(find.text('Phone Login'), findsOneWidget);
    expect(find.text('Sign In to Restaurant'), findsOneWidget);
    expect(find.text('Instant Role Switcher (Live Testing)'), findsOneWidget);
    expect(find.text('👑 Owner'), findsOneWidget);
    expect(find.text('💳 Cashier'), findsOneWidget);
    expect(find.text('🍽️ Waiter'), findsOneWidget);
    expect(find.text('🍳 Chef/KDS'), findsOneWidget);
  });

  testWidgets('OwnerRegistrationWizardScreen renders Step 1 with form fields', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: OwnerRegistrationWizardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Restaurant Onboarding'), findsOneWidget);
    expect(find.text('Step 1: Restaurant Owner Account'), findsOneWidget);
    expect(find.text('Full Legal Name'), findsOneWidget);
    expect(find.text('Work / Owner Email'), findsOneWidget);
    expect(find.text('Continue to Restaurant Profile'), findsOneWidget);
  });

  testWidgets('StaffManagementScreen renders staff list and invite button', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: StaffManagementScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Staff & Permissions Management'), findsOneWidget);
    expect(find.text('Invite Staff Member'), findsOneWidget);
    expect(find.text('Vikramaditya Roy'), findsOneWidget);
    expect(find.text('Rajesh Sharma'), findsOneWidget);
  });
}
