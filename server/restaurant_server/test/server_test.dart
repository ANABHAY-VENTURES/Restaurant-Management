// Anabhay Ventures — Backend Server Tests

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import '../lib/src/config/app_config.dart';
import '../lib/src/endpoints/dashboard_endpoint.dart';
import '../lib/src/endpoints/health_endpoint.dart';

void main() {
  group('Backend Endpoint Tests', () {
    late AppConfig config;

    setUp(() {
      config = const AppConfig(
        serverName: 'Restaurant Management Backend',
        companyName: 'Anabhay Ventures',
        version: '1.0.0',
        port: 8080,
        dbHost: 'localhost',
        dbPort: 5432,
        dbUser: 'postgres',
        dbPassword: 'password',
        dbName: 'restaurant_db',
      );
    });

    test('Health endpoint returns healthy status and metadata', () async {
      final endpoint = HealthEndpoint(config);
      final request = Request('GET', Uri.parse('http://localhost:8080/api/v1/health'));
      final response = endpoint.handleHealth(request);

      expect(response.statusCode, equals(200));
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['status'], equals('healthy'));
      expect(body['company'], equals('Anabhay Ventures'));
      expect(body['service'], equals('Restaurant Management Backend'));
      expect(body['version'], equals('1.0.0'));
    });

    test('Dashboard endpoint returns realistic demo summary', () async {
      final endpoint = DashboardEndpoint();
      final request = Request('GET', Uri.parse('http://localhost:8080/api/v1/dashboard/summary'));
      final response = endpoint.handleSummary(request);

      expect(response.statusCode, equals(200));
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['restaurant_name'], equals('The Royal Saffron Fine Dining'));
      expect(body['metrics'], isNotNull);
      expect(body['hourly_sales'], isNotEmpty);
      expect(body['best_sellers'], isNotEmpty);
      expect(body['kitchen_queue'], isNotEmpty);
    });
  });
}

