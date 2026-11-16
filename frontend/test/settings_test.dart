// Anabhay Ventures — Phase 7 Settings, Restaurant Profile & Billing Configuration Tests

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:restaurant_management/core/localization/app_localizations.dart';
import 'package:restaurant_management/features/pos/data/restaurant_storage_repository.dart';
import 'package:restaurant_management/features/pos/domain/models/order_models.dart';
import 'package:restaurant_management/features/pos/presentation/providers/pos_providers.dart';
import 'package:restaurant_management/features/settings/domain/models/settings_models.dart';
import 'package:restaurant_management/features/settings/presentation/providers/settings_providers.dart';
import 'package:restaurant_management/features/settings/presentation/screens/settings_screen.dart';
import 'package:restaurant_management/features/settings/presentation/widgets/live_receipt_preview.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 7: Restaurant Profile Persistence & Propagation', () {
    test('Default restaurant profile is pre-populated with Anabhay Ventures demo data', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final profile = container.read(restaurantProfileProvider);
      expect(profile.name, contains('The Royal Saffron'));
      expect(profile.tagline, contains('Awadhi'));
      expect(profile.phone, equals('+91 98765 43210'));
      expect(profile.email, equals('reservations@royalsaffron.com'));
      expect(profile.gstin, equals('07AAAAA0000A1Z5'));
      expect(profile.fssai, equals('10019011006543'));
    });

    test('Updating profile changes state and persists to storage', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final profileNotifier = container.read(restaurantProfileProvider.notifier);

      final updatedProfile = container.read(restaurantProfileProvider).copyWith(
        name: 'The Royal Saffron Flagship',
        phone: '+91 98300 99999',
        address: '12 Park Street, 2nd Floor, Kolkata 700016',
        openingTime: '11:00 AM',
        closingTime: '11:30 PM',
        weeklyClosingDay: 'Tuesday',
      );

      await profileNotifier.updateProfile(updatedProfile);

      final current = container.read(restaurantProfileProvider);
      expect(current.name, equals('The Royal Saffron Flagship'));
      expect(current.phone, equals('+91 98300 99999'));
      expect(current.address, equals('12 Park Street, 2nd Floor, Kolkata 700016'));
      expect(current.weeklyClosingDay, equals('Tuesday'));

      // Verify repository read from storage matches
      final repo = container.read(restaurantStorageRepositoryProvider);
      final storedProfile = await repo.loadProfile();
      expect(storedProfile.name, equals('The Royal Saffron Flagship'));
      expect(storedProfile.weeklyClosingDay, equals('Tuesday'));
    });
  });

  group('Phase 7: Tax & Billing Configuration & Calculation Impact', () {
    test('Default tax config is 5% Indian Composite GST', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final taxConfig = container.read(taxBillingConfigProvider);
      expect(taxConfig.isGstEnabled, isTrue);
      expect(taxConfig.taxRatePercent, equals(5.0));
      expect(taxConfig.isTaxInclusive, isFalse);
      expect(taxConfig.serviceChargePercent, equals(0.0));
    });

    test('Updating tax configuration updates POS order calculations', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final taxNotifier = container.read(taxBillingConfigProvider.notifier);
      final cartNotifier = container.read(posCartProvider.notifier);
      final ordersNotifier = container.read(ordersProvider.notifier);

      // 1. Add item to POS cart: Subtotal = ₹500
      cartNotifier.addItem(
        const MenuItem(
          id: 'test-biryani',
          name: 'Awadhi Biryani',
          description: 'Slow-cooked saffron basmati rice with tender chicken',
          basePrice: 500.0,
          category: 'Biryani',
          isVeg: false,
        ),
      );

      // Default 5% GST: 2.5% CGST (₹12.50) + 2.5% SGST (₹12.50) => Tax ₹25.00, Total ₹525.00
      final orderDefault = ordersNotifier.createOrder(
        orderType: OrderType.dineIn,
        tableNumber: 'Table 01',
        customerName: 'Aarav Mehta',
        items: container.read(posCartProvider).items,
        discountPercent: 0.0,
      );

      expect(orderDefault.subtotal, equals(500.0));
      expect(orderDefault.cgstAmount, closeTo(12.5, 0.01));
      expect(orderDefault.sgstAmount, closeTo(12.5, 0.01));
      expect(orderDefault.grandTotal, closeTo(525.0, 0.01));

      // 2. Change tax configuration to 18% AC GST Preset
      await taxNotifier.updateConfig(
        container.read(taxBillingConfigProvider).copyWith(
          taxRatePercent: 18.0,
        ),
      );

      final order18 = ordersNotifier.createOrder(
        orderType: OrderType.dineIn,
        tableNumber: 'Table 02',
        customerName: 'Priya Sen',
        items: container.read(posCartProvider).items,
        discountPercent: 0.0,
      );

      // 18% GST: 9% CGST (₹45.00) + 9% SGST (₹45.00) => Tax ₹90.00, Total ₹590.00
      expect(order18.subtotal, equals(500.0));
      expect(order18.cgstAmount, closeTo(45.0, 0.01));
      expect(order18.sgstAmount, closeTo(45.0, 0.01));
      expect(order18.grandTotal, closeTo(590.0, 0.01));

      // 3. Disable GST completely
      await taxNotifier.updateConfig(
        container.read(taxBillingConfigProvider).copyWith(
          isGstEnabled: false,
        ),
      );

      final orderNoTax = ordersNotifier.createOrder(
        orderType: OrderType.takeaway,
        tableNumber: 'Takeaway',
        customerName: 'Kunal Roy',
        items: container.read(posCartProvider).items,
        discountPercent: 0.0,
      );

      expect(orderNoTax.subtotal, equals(500.0));
      expect(orderNoTax.cgstAmount, equals(0.0));
      expect(orderNoTax.sgstAmount, equals(0.0));
      expect(orderNoTax.grandTotal, equals(500.0));
    });
  });

  group('Phase 7: Invoice & Receipt Configuration & Numbering Prefixes', () {
    test('Configures custom invoice and KOT prefixes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final invoiceNotifier = container.read(invoiceReceiptConfigProvider.notifier);
      final posNotifier = container.read(orderPosConfigProvider.notifier);

      await invoiceNotifier.updateConfig(
        container.read(invoiceReceiptConfigProvider).copyWith(
          invoicePrefix: 'ROYAL-INV-',
          thankYouMessage: 'Thank you for dining with royalty!',
        ),
      );

      await posNotifier.updateConfig(
        container.read(orderPosConfigProvider).copyWith(
          kotPrefix: 'ROYAL-KOT-',
          orderPrefix: 'ROYAL-ORD-',
        ),
      );

      final invConfig = container.read(invoiceReceiptConfigProvider);
      final posConfig = container.read(orderPosConfigProvider);

      expect(invConfig.invoicePrefix, equals('ROYAL-INV-'));
      expect(invConfig.thankYouMessage, equals('Thank you for dining with royalty!'));
      expect(posConfig.kotPrefix, equals('ROYAL-KOT-'));
      expect(posConfig.orderPrefix, equals('ROYAL-ORD-'));
    });
  });

  group('Phase 7: Localization & Multi-Language Support', () {
    test('AppLocalizations provides translated strings for en, hi, and bn', () {
      final en = AppLocalizations(const Locale('en'));
      final hi = AppLocalizations(const Locale('hi'));
      final bn = AppLocalizations(const Locale('bn'));

      // English
      expect(en.get('settings'), equals('Settings'));
      expect(en.get('posBilling'), equals('POS Billing'));

      // Hindi
      expect(hi.get('settings'), equals('सेटिंग्स'));
      expect(hi.get('posBilling'), equals('पीओएस बिलिंग'));

      // Bengali
      expect(bn.get('settings'), equals('সেটিংস'));
      expect(bn.get('posBilling'), equals('পিওএস বিলিং'));
    });

    test('LocaleNotifier changes language and persists preference', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final localeNotifier = container.read(appLocaleProvider.notifier);

      expect(container.read(appLocaleProvider).languageCode, equals('en'));

      await localeNotifier.setLocale(const Locale('hi'));
      expect(container.read(appLocaleProvider).languageCode, equals('hi'));

      await localeNotifier.setLocale(const Locale('bn'));
      expect(container.read(appLocaleProvider).languageCode, equals('bn'));

      // Verify persisted value in storage repository
      final repo = container.read(restaurantStorageRepositoryProvider);
      final storedLang = await repo.loadLanguage();
      expect(storedLang, equals('bn'));
    });
  });

  group('Phase 7: Appearance & Theme Switching', () {
    test('ThemeModeNotifier switches between Dark, Light, and System modes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final themeNotifier = container.read(themeModeProvider.notifier);

      expect(container.read(themeModeProvider), equals(ThemeMode.dark));

      await themeNotifier.setThemeMode(ThemeMode.light);
      expect(container.read(themeModeProvider), equals(ThemeMode.light));

      await themeNotifier.setThemeMode(ThemeMode.system);
      expect(container.read(themeModeProvider), equals(ThemeMode.system));

      final repo = container.read(restaurantStorageRepositoryProvider);
      final storedTheme = await repo.loadThemeMode();
      expect(storedTheme, equals('system'));
    });
  });

  group('Phase 7: Full Database JSON Backup, Validation, Import & Reset', () {
    test('Exports full database JSON containing all modules and settings', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(restaurantStorageRepositoryProvider);
      final jsonString = await repo.exportFullDatabaseJson();
      expect(jsonString, isNotEmpty);

      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(data['version'], equals('1.0.0'));
      expect(data['exportedAt'], isNotNull);
      expect(data.containsKey('profile'), isTrue);
      expect(data.containsKey('taxBilling'), isTrue);
      expect(data.containsKey('invoiceConfig'), isTrue);
      expect(data.containsKey('orderPosConfig'), isTrue);
      expect(data.containsKey('tableQrConfig'), isTrue);
      expect(data.containsKey('categories'), isTrue);
      expect(data.containsKey('menu'), isTrue);
      expect(data.containsKey('staff'), isTrue);
      expect(data.containsKey('customers'), isTrue);
    });

    test('Imports validated backup JSON and restores data cleanly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(restaurantStorageRepositoryProvider);

      // Create custom export JSON with modified profile
      final backupData = {
        'version': '1.0.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'profile': {
          'name': 'Heritage Awadhi RestoBar',
          'tagline': 'Signature Dining Experience',
          'address': 'Sector V, Salt Lake, Kolkata',
          'phone': '+91 98300 77777',
          'email': 'heritage@awadhi.in',
          'website': 'https://heritageawadhi.in',
          'gstin': '19AABCH9999K1Z2',
          'fssai': '12823019000999',
          'description': 'Luxury Heritage Cuisine',
          'openingTime': '12:00 PM',
          'closingTime': '11:00 PM',
          'weeklyClosingDay': 'Monday',
        },
        'taxBilling': {
          'isGstEnabled': true,
          'taxRatePercent': 18.0,
          'isTaxInclusive': true,
          'serviceChargePercent': 5.0,
          'roundingPreference': 'Nearest Rupee',
        },
        'menu': <dynamic>[],
      };

      final success = await repo.importFullDatabaseJson(jsonEncode(backupData));
      expect(success, isTrue);

      final restoredProfile = await repo.loadProfile();
      expect(restoredProfile.name, equals('Heritage Awadhi RestoBar'));
      expect(restoredProfile.phone, equals('+91 98300 77777'));
      expect(restoredProfile.weeklyClosingDay, equals('Monday'));

      final restoredTax = await repo.loadTaxBilling();
      expect(restoredTax.taxRatePercent, equals(18.0));
      expect(restoredTax.serviceChargePercent, equals(5.0));
      expect(restoredTax.isTaxInclusive, isTrue);
    });

    test('Rejects invalid JSON payload on import', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(restaurantStorageRepositoryProvider);
      const invalidJson = '{"something": "unrelated"}';

      final success = await repo.importFullDatabaseJson(invalidJson);
      expect(success, isFalse);
    });

    test('Factory reset restores default demo data across all modules', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(restaurantStorageRepositoryProvider);

      // Save a modified profile
      await repo.saveProfile(
        const RestaurantProfile(
          name: 'Modified Name Before Reset',
          address: 'Random Address',
        ),
      );

      // Trigger reset
      await repo.resetDatabaseToDefaults();

      // Verify reset back to original default
      final profile = await repo.loadProfile();
      expect(profile.name, contains('The Royal Saffron'));

      final tax = await repo.loadTaxBilling();
      expect(tax.taxRatePercent, equals(5.0));
      expect(tax.isGstEnabled, isTrue);
    });
  });

  group('Phase 7: Settings Screen & Live Receipt Preview Widgets', () {
    testWidgets('LiveReceiptPreview renders thermal 80mm format and switches to A4 Tax Invoice', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));

      const profile = RestaurantProfile(
        name: 'The Royal Saffron',
        tagline: 'Awadhi & Mughlai Fine Dining',
        address: '12 Park Street, Kolkata',
        phone: '+91 98300 12345',
        gstin: '19AABCR1234F1Z5',
        fssai: '12823019000456',
      );

      const invoiceConfig = InvoiceReceiptConfig(
        invoiceTitle: 'TAX INVOICE',
        thankYouMessage: 'Thank you for dining with us!',
        footerMessage: 'Visit again soon',
      );

      const taxBilling = TaxBillingConfig(
        isGstEnabled: true,
        taxRatePercent: 5.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LiveReceiptPreview(
                profile: profile,
                invoiceConfig: invoiceConfig,
                taxBilling: taxBilling,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check default 80mm thermal preview items
      expect(find.text('Live Receipt & Invoice Preview'), findsOneWidget);
      expect(find.text('80mm Thermal Receipt'), findsOneWidget);
      expect(find.text('A4 Tax Invoice'), findsOneWidget);
      expect(find.text('The Royal Saffron'), findsOneWidget);
      expect(find.text('Thank you for dining with us!'), findsOneWidget);

      // Tap on A4 Tax Invoice tab
      await tester.tap(find.text('A4 Tax Invoice'));
      await tester.pumpAndSettle();

      // In A4 mode, standard tax table headers exist
      expect(find.text('TAX INVOICE'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
    });

    testWidgets('SettingsScreen renders tab bar and navigates tabs smoothly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
            ],
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header and tabs exist
      expect(find.text('Restaurant Profile'), findsOneWidget);
      expect(find.text('Tax & Billing'), findsOneWidget);
      expect(find.text('Receipt & Invoices'), findsOneWidget);
      expect(find.text('Orders & POS'), findsOneWidget);
      expect(find.text('Tables & QR'), findsOneWidget);
      expect(find.text('Theme & Language'), findsOneWidget);
      expect(find.text('Backup & About'), findsOneWidget);

      // Restaurant name field is visible in the profile tab
      expect(find.text('Restaurant Name *'), findsOneWidget);

      // Tap on 'Tax & Billing' tab
      await tester.tap(find.text('Tax & Billing'));
      await tester.pumpAndSettle();

      expect(find.text('Goods & Services Tax (GST)'), findsOneWidget);
      expect(find.text('Indian GST Rate Presets'), findsOneWidget);

      // Tap on 'Theme & Language' tab
      await tester.tap(find.text('Theme & Language'));
      await tester.pumpAndSettle();

      expect(find.text('Application Theme'), findsOneWidget);
      expect(find.text('Matte Black Dark'), findsOneWidget);
      expect(find.text('Warm Ivory Light'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);

      // Tap on 'Backup & About' tab
      await tester.tap(find.text('Backup & About'));
      await tester.pumpAndSettle();

      expect(find.text('Data Backup & Migration'), findsOneWidget);
      expect(find.text('Export Database JSON'), findsOneWidget);
      expect(find.text('Factory Data Reset'), findsOneWidget);
      expect(find.text('Anabhay Ventures Restaurant Management'), findsOneWidget);
    });
  });
}
