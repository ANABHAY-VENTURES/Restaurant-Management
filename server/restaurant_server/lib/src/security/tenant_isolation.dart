// Anabhay Ventures — Multi-Tenant Isolation & IDOR Protection Middleware

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'security_service.dart';

class TenantIsolation {
  static final SecurityService _securityService = SecurityService();

  /// Middleware to enforce strict tenant scoping and prevent cross-tenant IDOR access
  static Middleware enforceTenantScoping({bool requireAuth = true}) {
    return (Handler innerHandler) {
      return (Request request) async {
        // Allow public auth & health routes
        final path = request.url.path;
        if (path.startsWith('api/v1/auth/') ||
            path.startsWith('auth/') ||
            path.startsWith('health') ||
            path.startsWith('api/v1/health') ||
            request.method == 'OPTIONS') {
          return innerHandler(request);
        }

        final authHeader = request.headers['Authorization'] ?? request.headers['authorization'];
        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          if (!requireAuth) return innerHandler(request);
          return Response(401,
            body: jsonEncode({
              'error': 'UNAUTHORIZED',
              'message': 'Valid authentication token is required to access restaurant resources.',
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        final token = authHeader.substring(7).trim();
        final session = _securityService.getSession(token);

        if (session == null) {
          return Response(401,
            body: jsonEncode({
              'error': 'SESSION_EXPIRED',
              'message': 'Your session has expired. Please sign in again.',
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        final userTenantId = session['tenant_id'] as String?;
        final headerTenantId = request.headers['X-Tenant-ID'] ?? request.headers['x-tenant-id'];

        // Enforce tenant boundary: If client requests another tenant ID, strictly block as IDOR attack
        if (headerTenantId != null && userTenantId != null && headerTenantId != userTenantId) {
          return Response(403,
            body: jsonEncode({
              'error': 'FORBIDDEN_CROSS_TENANT_ACCESS',
              'message': 'Access denied: Attempted cross-tenant access to unowned restaurant data.',
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        // Attach verified user and tenant context to request
        final updatedRequest = request.change(context: {
          'user': session['user'],
          'tenant_id': userTenantId,
          'branch_id': session['branch_id'],
          'role': session['role'],
        });

        return innerHandler(updatedRequest);
      };
    };
  }
}
