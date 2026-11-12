// Anabhay Ventures — Authentication Endpoint

import 'dart:convert';
import 'package:shelf/shelf.dart';

class AuthEndpoint {
  Response handleLogin(Request request) {
    // In Phase 1, realistic demo credentials are provided for testing
    return Response.ok(
      jsonEncode({
        'token': 'demo_jwt_token_anabhay_${DateTime.now().millisecondsSinceEpoch}',
        'token_type': 'Bearer',
        'expires_in': 86400,
        'user': {
          'id': 'usr_owner_001',
          'full_name': 'Vikramaditya Roy',
          'email': 'owner@anabhay.com',
          'role': 'restaurant_owner',
          'tenant_id': 'ten_royal_saffron',
          'branch_id': 'br_park_street',
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  }
}
