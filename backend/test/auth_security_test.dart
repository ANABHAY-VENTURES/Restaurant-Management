// Anabhay Ventures — Authentication, Security & Tenant Isolation Tests

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import '../lib/src/endpoints/auth_endpoint.dart';
import '../lib/src/endpoints/staff_endpoint.dart';
import '../lib/src/security/rbac_service.dart';
import '../lib/src/security/security_service.dart';
import '../lib/src/security/tenant_isolation.dart';

void main() {
  group('SecurityService Password & Rate Limiting Tests', () {
    final security = SecurityService();

    test('Password hashing produces secure salted output and verifies correctly', () {
      const password = 'StrongPassword@2026';
      final hash = security.hashPassword(password);

      expect(hash, isNot(equals(password)));
      expect(hash.contains(':'), isTrue);
      expect(security.verifyPassword(password, hash), isTrue);
      expect(security.verifyPassword('WrongPassword', hash), isFalse);
    });

    test('Rate limiter locks out after 5 consecutive failed attempts', () {
      const testIdentifier = 'test_lockout_user@example.com';
      security.clearFailedAttempts(testIdentifier);

      expect(security.isLockedOut(testIdentifier), isFalse);

      for (int i = 1; i <= 4; i++) {
        security.recordFailedAttempt(testIdentifier);
        expect(security.isLockedOut(testIdentifier), isFalse);
      }

      // 5th failed attempt triggers lockout
      security.recordFailedAttempt(testIdentifier);
      expect(security.isLockedOut(testIdentifier), isTrue);

      // Clear attempts releases lockout
      security.clearFailedAttempts(testIdentifier);
      expect(security.isLockedOut(testIdentifier), isFalse);
    });

    test('OTP generation returns 6 digits', () {
      final otp = security.generateOtp();
      expect(otp.length, equals(6));
      expect(int.tryParse(otp), isNotNull);
    });
  });

  group('RBAC Permissions Tests', () {
    test('Owner role has wildcard permissions', () {
      expect(RBACService.hasPermission(RBACService.roleOwner, 'billing.create'), isTrue);
      expect(RBACService.hasPermission(RBACService.roleOwner, 'settings.manage'), isTrue);
      expect(RBACService.hasPermission(RBACService.roleOwner, 'subscription.manage'), isTrue);
    });

    test('Cashier has billing permissions but lacks staff or settings permissions', () {
      expect(RBACService.hasPermission(RBACService.roleCashier, 'billing.create'), isTrue);
      expect(RBACService.hasPermission(RBACService.roleCashier, 'orders.create'), isTrue);
      expect(RBACService.hasPermission(RBACService.roleCashier, 'staff.manage'), isFalse);
      expect(RBACService.hasPermission(RBACService.roleCashier, 'settings.manage'), isFalse);
    });

    test('Waiter has order take permissions but lacks financial reports access', () {
      expect(RBACService.hasPermission(RBACService.roleWaiter, 'orders.create'), isTrue);
      expect(RBACService.hasPermission(RBACService.roleWaiter, 'tables.view'), isTrue);
      expect(RBACService.hasPermission(RBACService.roleWaiter, 'reports.view'), isFalse);
    });

    test('Kitchen staff has KDS access only', () {
      expect(RBACService.hasPermission(RBACService.roleKitchenStaff, 'kds.view'), isTrue);
      expect(RBACService.hasPermission(RBACService.roleKitchenStaff, 'kds.bump'), isTrue);
      expect(RBACService.hasPermission(RBACService.roleKitchenStaff, 'billing.create'), isFalse);
    });
  });

  group('AuthEndpoint Integration Tests', () {
    late AuthEndpoint authEndpoint;

    setUp(() {
      authEndpoint = AuthEndpoint();
    });

    test('Login with valid demo credentials returns 200 and token', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/auth/login'),
        body: jsonEncode({
          'email': 'owner@anabhay.com',
          'password': 'Anabhay@2026',
        }),
      );

      final response = await authEndpoint.handleLogin(request);
      expect(response.statusCode, equals(200));

      final data = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(data['success'], isTrue);
      expect(data['token'], isNotNull);
      expect(data['user']['role'], equals('owner'));
      expect(data['tenant']['id'], equals('ten_anabhay_001'));
    });

    test('Login with invalid password returns 401', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/auth/login'),
        body: jsonEncode({
          'email': 'owner@anabhay.com',
          'password': 'IncorrectPassword',
        }),
      );

      final response = await authEndpoint.handleLogin(request);
      expect(response.statusCode, equals(401));

      final data = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(data['error'], equals('INVALID_CREDENTIALS'));
    });

    test('Restaurant Owner Onboarding Registration creates tenant and user', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/auth/register-owner'),
        body: jsonEncode({
          'owner_name': 'Rohan Sen',
          'owner_email': 'rohan.sen@newrestaurant.com',
          'owner_phone': '+91 91234 56789',
          'password': 'SecurePass@2026',
          'restaurant_name': 'Saffron Bay Fine Dining',
          'restaurant_type': 'fine_dining',
          'description': 'Coastal royal delicacies',
          'gst_registered': true,
          'gstin': '07ABCDE1234F1Z5',
          'business_address': 'Connaught Place, Central Delhi',
          'city': 'New Delhi',
          'state': 'Delhi',
          'pincode': '110001',
          'currency': 'INR',
          'branch_name': 'Saffron Bay Flagship',
        }),
      );

      final response = await authEndpoint.handleRegisterOwner(request);
      expect(response.statusCode, equals(201));

      final data = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(data['success'], isTrue);
      expect(data['token'], isNotNull);
      expect(data['user']['email'], equals('rohan.sen@newrestaurant.com'));
      expect(data['tenant']['name'], equals('Saffron Bay Fine Dining'));
    });

    test('Forgot Password generates verification token and OTP', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/auth/forgot-password'),
        body: jsonEncode({'email': 'owner@anabhay.com'}),
      );

      final response = await authEndpoint.handleForgotPassword(request);
      expect(response.statusCode, equals(200));

      final data = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(data['success'], isTrue);
      expect(data['reset_token'], isNotNull);
      expect(data['demo_otp'], isNotNull);

      // Verify OTP step
      final verifyRequest = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/auth/verify-otp'),
        body: jsonEncode({
          'reset_token': data['reset_token'],
          'otp': data['demo_otp'],
        }),
      );

      final verifyResponse = await authEndpoint.handleVerifyOtp(verifyRequest);
      expect(verifyResponse.statusCode, equals(200));
      final verifyData = jsonDecode(await verifyResponse.readAsString()) as Map<String, dynamic>;
      expect(verifyData['verified'], isTrue);
    });
  });

  group('Tenant Isolation & IDOR Protection Tests', () {
    final security = SecurityService();

    test('Request with mismatched tenant ID is blocked with 403 Forbidden', () async {
      final token = security.generateBearerToken();
      security.storeSession(token, {
        'token': token,
        'user': {'id': 'usr_1', 'role': 'owner'},
        'tenant_id': 'ten_anabhay_001',
      });

      final handler = const Pipeline()
          .addMiddleware(TenantIsolation.enforceTenantScoping(requireAuth: true))
          .addHandler((Request request) => Response.ok('authorized'));

      // Attacking client passes another restaurant's tenant ID
      final attackRequest = Request(
        'GET',
        Uri.parse('http://localhost/api/v1/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'X-Tenant-ID': 'ten_another_victim_restaurant',
        },
      );

      final response = await handler(attackRequest);
      expect(response.statusCode, equals(403));

      final data = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(data['error'], equals('FORBIDDEN_CROSS_TENANT_ACCESS'));
    });

    test('Request with matching tenant ID succeeds', () async {
      final token = security.generateBearerToken();
      security.storeSession(token, {
        'token': token,
        'user': {'id': 'usr_1', 'role': 'owner'},
        'tenant_id': 'ten_anabhay_001',
      });

      final handler = const Pipeline()
          .addMiddleware(TenantIsolation.enforceTenantScoping(requireAuth: true))
          .addHandler((Request request) => Response.ok('authorized'));

      final validRequest = Request(
        'GET',
        Uri.parse('http://localhost/api/v1/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'X-Tenant-ID': 'ten_anabhay_001',
        },
      );

      final response = await handler(validRequest);
      expect(response.statusCode, equals(200));
    });
  });

  group('Staff Management Endpoint Tests', () {
    final staffEndpoint = StaffEndpoint();

    test('Staff list returns tenant-scoped staff members', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/api/v1/staff'),
        context: {'role': 'owner', 'tenant_id': 'ten_anabhay_001'},
      );

      final response = await staffEndpoint.handleGetStaff(request);
      expect(response.statusCode, equals(200));

      final data = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(data['success'], isTrue);
      expect((data['staff'] as List).isNotEmpty, isTrue);
    });

    test('Non-authorized role cannot create staff', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/staff/invite'),
        context: {'role': 'cashier', 'tenant_id': 'ten_anabhay_001'},
        body: jsonEncode({
          'full_name': 'Test New Waiter',
          'email': 'newwaiter@anabhay.com',
          'phone': '+91 99999 88888',
        }),
      );

      final response = await staffEndpoint.handleCreateStaff(request);
      expect(response.statusCode, equals(403));
    });
  });
}
