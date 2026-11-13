// Anabhay Ventures — Restaurant Management Backend Server
// Phase 1 & 2: Production Engine, Multi-Tenant Security & RBAC

import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import '../lib/src/config/app_config.dart';
import '../lib/src/database/database.dart';
import '../lib/src/endpoints/auth_endpoint.dart';
import '../lib/src/endpoints/dashboard_endpoint.dart';
import '../lib/src/endpoints/health_endpoint.dart';
import '../lib/src/endpoints/staff_endpoint.dart';
import '../lib/src/security/tenant_isolation.dart';

Future<void> main(List<String> args) async {
  final config = AppConfig.fromEnvironment();
  final dbService = DatabaseService(config);
  await dbService.initialize();

  final healthEndpoint = HealthEndpoint(config);
  final dashboardEndpoint = DashboardEndpoint();
  final authEndpoint = AuthEndpoint();
  final staffEndpoint = StaffEndpoint();

  final router = Router();

  // Root metadata endpoint
  router.get('/', (Request request) {
    return Response.ok(
      jsonEncode({
        'service': config.serverName,
        'company': config.companyName,
        'version': '2.0.0',
        'status': 'online',
        'health': '/api/v1/health',
        'documentation': '/api/v1/docs',
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // Health checks
  router.get('/health', healthEndpoint.handleHealth);
  router.get('/api/v1/health', healthEndpoint.handleHealth);

  // Authentication & Onboarding APIs
  router.post('/api/v1/auth/login', authEndpoint.handleLogin);
  router.post('/api/v1/auth/register-owner', authEndpoint.handleRegisterOwner);
  router.post('/api/v1/auth/forgot-password', authEndpoint.handleForgotPassword);
  router.post('/api/v1/auth/verify-otp', authEndpoint.handleVerifyOtp);
  router.post('/api/v1/auth/reset-password', authEndpoint.handleResetPassword);
  router.post('/api/v1/auth/verify-email', authEndpoint.handleVerifyEmail);
  router.post('/api/v1/auth/logout', authEndpoint.handleLogout);
  router.get('/api/v1/auth/me', authEndpoint.handleGetMe);

  // Staff & RBAC APIs
  router.get('/api/v1/staff', staffEndpoint.handleGetStaff);
  router.post('/api/v1/staff/invite', staffEndpoint.handleCreateStaff);
  router.get('/api/v1/staff/roles', staffEndpoint.handleGetRoles);
  router.put('/api/v1/staff/<id>', (Request request, String id) => staffEndpoint.handleUpdateStaff(request, id));
  router.patch('/api/v1/staff/<id>/status', (Request request, String id) => staffEndpoint.handleToggleStatus(request, id));
  router.post('/api/v1/staff/<id>/reset-access', (Request request, String id) => staffEndpoint.handleResetAccess(request, id));

  // Dashboard APIs
  router.get('/api/v1/dashboard/summary', dashboardEndpoint.handleSummary);

  // Pipeline with logging, CORS, and Tenant Isolation
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(
        headers: {
          ACCESS_CONTROL_ALLOW_ORIGIN: '*',
          ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
          ACCESS_CONTROL_ALLOW_HEADERS: 'Origin, Content-Type, Authorization, Accept, X-Tenant-ID, X-Branch-ID',
        },
      ))
      .addMiddleware(TenantIsolation.enforceTenantScoping(requireAuth: false))
      .addHandler(router.call);

  // Bind to port with automatic fallback if port is reserved
  HttpServer? server;
  final candidatePorts = [8085, 8080, 8000, 8888, 5000];
  for (final port in candidatePorts) {
    try {
      server = await io.serve(handler, InternetAddress.anyIPv4, port);
      break;
    } catch (_) {
      continue;
    }
  }

  if (server == null) {
    server = await io.serve(handler, InternetAddress.anyIPv4, 0);
  }

  print('=====================================================');
  print('${config.companyName} — ${config.serverName}');
  print('Server URL: http://localhost:${server.port}');
  print('Health check: http://localhost:${server.port}/api/v1/health');
  print('Auth API: http://localhost:${server.port}/api/v1/auth/login');
  print('Dashboard API: http://localhost:${server.port}/api/v1/dashboard/summary');
  print('=====================================================');

  ProcessSignal.sigint.watch().listen((signal) async {
    print('Shutting down server...');
    await dbService.close();
    await server?.close();
    exit(0);
  });
}
