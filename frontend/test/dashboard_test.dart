// Anabhay Ventures — Dashboard Widget Test

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_management/main.dart';
import 'package:restaurant_management/features/dashboard/data/dashboard_demo_data.dart';

void main() {
  testWidgets('Dashboard renders header and metric cards', (WidgetTester tester) async {
    // Configure responsive desktop testing viewport
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build the app
    await tester.pumpWidget(
      const ProviderScope(
        child: RestaurantManagementApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify restaurant header & sidebar
    expect(find.textContaining('Vikramaditya'), findsWidgets);
    expect(find.textContaining('PARK STREET'), findsWidgets);

    // Verify demo data banner
    expect(find.textContaining('DEMO'), findsWidgets);

    // Verify key metrics
    expect(find.text("Today's Sales"), findsWidgets);
    expect(find.text("Total Orders"), findsWidgets);
    expect(find.text("Active Tables"), findsWidgets);
    expect(find.text("Kitchen Queue"), findsWidgets);
  });
}
