// Anabhay Ventures — Staff Account Management Endpoint

import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../security/rbac_service.dart';
import '../security/security_service.dart';

class StaffEndpoint {
  final SecurityService _security = SecurityService();

  // In-memory staff repository scoped by tenant
  final List<Map<String, dynamic>> _staffList = [
    {
      'id': 'stf_001',
      'tenant_id': 'ten_anabhay_001',
      'branch_id': 'br_flagship_cp',
      'full_name': 'Rajesh Sharma',
      'email': 'admin@anabhay.com',
      'phone': '+91 98765 43211',
      'role': RBACService.roleAdmin,
      'is_active': true,
      'created_at': '2026-01-10T10:00:00Z',
    },
    {
      'id': 'stf_002',
      'tenant_id': 'ten_anabhay_001',
      'branch_id': 'br_flagship_cp',
      'full_name': 'Anita Roy',
      'email': 'cashier@anabhay.com',
      'phone': '+91 98765 43212',
      'role': RBACService.roleCashier,
      'is_active': true,
      'created_at': '2026-02-15T09:30:00Z',
    },
    {
      'id': 'stf_003',
      'tenant_id': 'ten_anabhay_001',
      'branch_id': 'br_flagship_cp',
      'full_name': 'Ramesh Kumar',
      'email': 'waiter@anabhay.com',
      'phone': '+91 98765 43213',
      'role': RBACService.roleWaiter,
      'is_active': true,
      'created_at': '2026-03-01T11:00:00Z',
    },
    {
      'id': 'stf_004',
      'tenant_id': 'ten_anabhay_001',
      'branch_id': 'br_flagship_cp',
      'full_name': 'Chef Sanjeev Anand',
      'email': 'chef@anabhay.com',
      'phone': '+91 98765 43214',
      'role': RBACService.roleKitchenStaff,
      'is_active': true,
      'created_at': '2026-03-12T14:20:00Z',
    },
    {
      'id': 'stf_005',
      'tenant_id': 'ten_anabhay_001',
      'branch_id': 'br_flagship_cp',
      'full_name': 'Deepak Verma',
      'email': 'inventory@anabhay.com',
      'phone': '+91 98765 43215',
      'role': RBACService.roleInventoryManager,
      'is_active': true,
      'created_at': '2026-04-05T08:00:00Z',
    },
  ];

  // ── 1. GET ALL STAFF (Tenant-Scoped) ──────────────────────────────────
  Future<Response> handleGetStaff(Request request) async {
    final tenantId = request.context['tenant_id'] as String? ?? 'ten_anabhay_001';
    final userRole = request.context['role'] as String? ?? RBACService.roleOwner;

    // RBAC check: only Owner, Admin, and Branch Manager can view staff
    if (!RBACService.hasPermission(userRole, 'staff.view') &&
        !RBACService.hasPermission(userRole, 'staff.manage')) {
      return Response(403,
        body: jsonEncode({
          'error': 'FORBIDDEN',
          'message': 'You do not have permission to view staff records.',
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    final tenantStaff = _staffList.where((s) => s['tenant_id'] == tenantId).toList();
    return Response.ok(
      jsonEncode({
        'success': true,
        'count': tenantStaff.length,
        'staff': tenantStaff,
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  // ── 2. INVITE / CREATE STAFF MEMBER ───────────────────────────────────
  Future<Response> handleCreateStaff(Request request) async {
    try {
      final userRole = request.context['role'] as String? ?? RBACService.roleOwner;
      if (!RBACService.hasPermission(userRole, 'staff.manage')) {
        return Response(403,
          body: jsonEncode({'error': 'FORBIDDEN', 'message': 'Only Owners and Admins can create or invite staff.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final bodyStr = await request.readAsString();
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final fullName = (body['full_name'] ?? '').toString().trim();
      final email = (body['email'] ?? '').toString().trim().toLowerCase();
      final phone = (body['phone'] ?? '').toString().trim();
      final role = (body['role'] ?? RBACService.roleWaiter).toString();
      final branchId = (body['branch_id'] ?? request.context['branch_id'] ?? 'br_flagship_cp').toString();
      final tenantId = request.context['tenant_id'] as String? ?? 'ten_anabhay_001';

      if (fullName.isEmpty || email.isEmpty || phone.isEmpty) {
        return Response(400,
          body: jsonEncode({'error': 'VALIDATION_ERROR', 'message': 'Full name, email, and phone are required.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final newStaff = {
        'id': 'stf_${DateTime.now().millisecondsSinceEpoch}',
        'tenant_id': tenantId,
        'branch_id': branchId,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'role': role,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      _staffList.add(newStaff);

      return Response(201,
        body: jsonEncode({
          'success': true,
          'message': 'Staff invitation dispatched and account provisioned successfully.',
          'staff': newStaff,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response(500,
        body: jsonEncode({'error': 'SERVER_ERROR', 'message': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ── 3. UPDATE STAFF MEMBER ────────────────────────────────────────────
  Future<Response> handleUpdateStaff(Request request, String id) async {
    try {
      final userRole = request.context['role'] as String? ?? RBACService.roleOwner;
      if (!RBACService.hasPermission(userRole, 'staff.manage')) {
        return Response(403,
          body: jsonEncode({'error': 'FORBIDDEN', 'message': 'Permission denied.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final bodyStr = await request.readAsString();
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final index = _staffList.indexWhere((s) => s['id'] == id);
      if (index == -1) {
        return Response(404,
          body: jsonEncode({'error': 'NOT_FOUND', 'message': 'Staff member not found.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final staff = _staffList[index];
      if (body['full_name'] != null) staff['full_name'] = body['full_name'];
      if (body['phone'] != null) staff['phone'] = body['phone'];
      if (body['role'] != null) staff['role'] = body['role'];
      if (body['branch_id'] != null) staff['branch_id'] = body['branch_id'];

      return Response.ok(
        jsonEncode({'success': true, 'message': 'Staff details updated.', 'staff': staff}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response(500,
        body: jsonEncode({'error': 'SERVER_ERROR', 'message': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ── 4. ACTIVATE / DEACTIVATE STAFF ────────────────────────────────────
  Future<Response> handleToggleStatus(Request request, String id) async {
    try {
      final userRole = request.context['role'] as String? ?? RBACService.roleOwner;
      if (!RBACService.hasPermission(userRole, 'staff.manage')) {
        return Response(403,
          body: jsonEncode({'error': 'FORBIDDEN', 'message': 'Permission denied.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final staff = _staffList.firstWhere((s) => s['id'] == id, orElse: () => {});
      if (staff.isEmpty) {
        return Response(404,
          body: jsonEncode({'error': 'NOT_FOUND', 'message': 'Staff member not found.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final currentStatus = staff['is_active'] as bool? ?? true;
      staff['is_active'] = !currentStatus;

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Staff status changed to ${staff['is_active'] ? 'Active' : 'Deactivated'}.',
          'staff': staff,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response(500,
        body: jsonEncode({'error': 'SERVER_ERROR', 'message': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ── 5. RESET STAFF ACCESS / CREDENTIALS ───────────────────────────────
  Future<Response> handleResetAccess(Request request, String id) async {
    final staff = _staffList.firstWhere((s) => s['id'] == id, orElse: () => {});
    if (staff.isEmpty) {
      return Response(404,
        body: jsonEncode({'error': 'NOT_FOUND', 'message': 'Staff member not found.'}),
        headers: {'content-type': 'application/json'},
      );
    }

    final tempPassword = 'Pass@${_security.generateOtp()}';
    return Response.ok(
      jsonEncode({
        'success': true,
        'message': 'Access credentials regenerated successfully.',
        'temporary_password': tempPassword,
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  // ── 6. LIST SYSTEM ROLES & PERMISSIONS ────────────────────────────────
  Future<Response> handleGetRoles(Request request) async {
    final rolesWithPermissions = RBACService.allRoles.map((role) {
      final roleId = role['id'] as String;
      return {
        ...role,
        'permissions': RBACService.getPermissionsForRole(roleId),
      };
    }).toList();

    return Response.ok(
      jsonEncode({'success': true, 'roles': rolesWithPermissions}),
      headers: {'content-type': 'application/json'},
    );
  }
}
