// Anabhay Ventures — Restaurant Management Backend Server

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

Future<void> main(List<String> args) async {
  final config = AppConfig.fromEnvironment();
  final dbService = DatabaseService(config);
  await dbService.initialize();

  final healthEndpoint = HealthEndpoint(config);
  final dashboardEndpoint = DashboardEndpoint();
  final authEndpoint = AuthEndpoint();

  final router = Router();

  // Root endpoint
  router.get('/', (Request request) {
    return Response.ok(
      jsonEncode({
        'service': config.serverName,
        'company': config.companyName,
        'version': config.version,
        'status': 'online',
        'documentation': '/api/v1/docs',
        'health': '/api/v1/health',
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // Health checks
  router.get('/health', healthEndpoint.handleHealth);
  router.get('/api/v1/health', healthEndpoint.handleHealth);

  // Dashboard APIs
  router.get('/api/v1/dashboard/summary', dashboardEndpoint.handleSummary);

  // Authentication APIs
  router.post('/api/v1/auth/login', authEndpoint.handleLogin);

  // Pipeline with logging and CORS
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(
        headers: {
          ACCESS_CONTROL_ALLOW_ORIGIN: '*',
          ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, PUT, DELETE, OPTIONS',
          ACCESS_CONTROL_ALLOW_HEADERS: 'Origin, Content-Type, Authorization, Accept',
        },
      ))
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
    server = await io.serve(handler, InternetAddress.anyIPv4, 0); // OS assigned port
  }

  print('=====================================================');
  print('${config.companyName} — ${config.serverName}');
  print('Server URL: http://localhost:${server.port}');
  print('Health check: http://localhost:${server.port}/api/v1/health');
  print('Dashboard API: http://localhost:${server.port}/api/v1/dashboard/summary');
  print('=====================================================');

  ProcessSignal.sigint.watch().listen((signal) async {
    print('Shutting down server...');
    await dbService.close();
    await server?.close();
    exit(0);
  });
}
