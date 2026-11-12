// Anabhay Ventures — Health Check Endpoint

import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/app_config.dart';

class HealthEndpoint {
  final AppConfig config;

  HealthEndpoint(this.config);

  Response handleHealth(Request request) {
    final payload = {
      'status': 'healthy',
      'service': config.serverName,
      'company': config.companyName,
      'version': config.version,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  }
}

