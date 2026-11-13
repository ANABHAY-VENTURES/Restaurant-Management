// Anabhay Ventures — Staff Account Management & Permissions Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  ConsumerState<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  String _selectedRoleFilter = 'All Roles';
  String _searchQuery = '';

  final List<String> _roleFilters = [
    'All Roles',
    'Owner',
    'Admin',
    'Branch Manager',
    'Cashier',
    'Waiter',
    'Kitchen Staff',
    'Inventory Manager',
    'Accountant',
  ];

  final List<Map<String, dynamic>> _staffList = [
    {
      'id': 'stf_001',
      'name': 'Vikramaditya Roy',
      'email': 'owner@anabhay.com',
      'phone': '+91 98765 43210',
      'role': 'Owner',
      'branch': 'Connaught Place Flagship',
      'isActive': true,
      'joined': '10 Jan 2026',
    },
    {
      'id': 'stf_002',
      'name': 'Rajesh Sharma',
      'email': 'admin@anabhay.com',
      'phone': '+91 98765 43211',
      'role': 'Admin',
      'branch': 'Connaught Place Flagship',
      'isActive': true,
      'joined': '15 Jan 2026',
    },
    {
      'id': 'stf_003',
      'name': 'Anita Roy',
      'email': 'cashier@anabhay.com',
      'phone': '+91 98765 43212',
      'role': 'Cashier',
      'branch': 'Connaught Place Flagship',
      'isActive': true,
      'joined': '02 Feb 2026',
    },
    {
      'id': 'stf_004',
      'name': 'Ramesh Kumar',
      'email': 'waiter@anabhay.com',
      'phone': '+91 98765 43213',
      'role': 'Waiter',
      'branch': 'Connaught Place Flagship',
      'isActive': true,
      'joined': '14 Feb 2026',
    },
    {
      'id': 'stf_005',
      'name': 'Chef Sanjeev Anand',
      'email': 'chef@anabhay.com',
      'phone': '+91 98765 43214',
      'role': 'Kitchen Staff',
      'branch': 'Connaught Place Flagship',
      'isActive': true,
      'joined': '20 Feb 2026',
    },
    {
      'id': 'stf_006',
      'name': 'Deepak Verma',
      'email': 'inventory@anabhay.com',
      'phone': '+91 98765 43215',
      'role': 'Inventory Manager',
      'branch': 'Connaught Place Flagship',
      'isActive': true,
      'joined': '01 Mar 2026',
    },
    {
      'id': 'stf_007',
      'name': 'Sunita Ghosh',
      'email': 'accountant@anabhay.com',
      'phone': '+91 98765 43216',
      'role': 'Accountant',
      'branch': 'Connaught Place Flagship',
      'isActive': true,
      'joined': '10 Mar 2026',
    },
  ];

  void _showInviteStaffDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String roleVal = 'Waiter';
    String branchVal = 'Connaught Place Flagship';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              title: const Text('Invite / Provision Staff Member', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField(
                        label: 'Full Legal Name',
                        hintText: 'e.g. Amit Kapoor',
                        controller: nameCtrl,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Staff Email Address',
                        hintText: 'staff@anabhay.com',
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Contact Mobile Number',
                        hintText: '+91 98765 43210',
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        initialValue: roleVal,
                        dropdownColor: AppColors.surfaceElevated,
                        decoration: InputDecoration(
                          labelText: 'Assigned Role',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                        ),
                        items: _roleFilters.where((r) => r != 'All Roles').map((r) {
                          return DropdownMenuItem(value: r, child: Text(r));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => roleVal = val);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        initialValue: branchVal,
                        dropdownColor: AppColors.surfaceElevated,
                        decoration: InputDecoration(
                          labelText: 'Assigned Branch',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Connaught Place Flagship', child: Text('Connaught Place Flagship')),
                          DropdownMenuItem(value: 'Gurugram CyberHub Outlet', child: Text('Gurugram CyberHub Outlet')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => branchVal = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                AppButton(
                  label: 'Send Invite & Create',
                  icon: Icons.person_add_rounded,
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                      setState(() {
                        _staffList.add({
                          'id': 'stf_${DateTime.now().millisecondsSinceEpoch}',
                          'name': nameCtrl.text.trim(),
                          'email': emailCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim(),
                          'role': roleVal,
                          'branch': branchVal,
                          'isActive': true,
                          'joined': 'Just now',
                        });
                      });
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Staff invitation dispatched to ${emailCtrl.text}!'),
                          backgroundColor: AppColors.successGreen,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showResetAccessDialog(Map<String, dynamic> staff) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: Text('Reset Credentials for ${staff['name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send a secure password reset link and temporary access PIN to ${staff['email']}.',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: const [
                  Icon(Icons.vpn_key_rounded, size: 16, color: AppColors.champagneGold),
                  SizedBox(width: 8),
                  Text('Temporary Access PIN: 839210', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          AppButton(
            label: 'Send Reset Link',
            size: AppButtonSize.small,
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reset link dispatched to ${staff['email']}'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final canManage = authState.hasPermission('staff.manage');

    final filtered = _staffList.where((s) {
      if (_selectedRoleFilter != 'All Roles' && s['role'] != _selectedRoleFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (s['name'] as String).toLowerCase();
        final email = (s['email'] as String).toLowerCase();
        final role = (s['role'] as String).toLowerCase();
        if (!name.contains(query) && !email.contains(query) && !role.contains(query)) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Screen Header ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Staff & Permissions Management', style: AppTypography.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Role-based access control (RBAC), multi-branch employee provisioning, and security credentials.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (canManage)
                  AppButton(
                    label: 'Invite Staff Member',
                    icon: Icons.person_add_rounded,
                    onPressed: _showInviteStaffDialog,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Search & Filter Controls ───────────────────
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search staff by name, email, or role...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                        prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.surfaceDark,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRoleFilter,
                      dropdownColor: AppColors.surfaceElevated,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      items: _roleFilters.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRoleFilter = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Staff Members Table ────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                  itemBuilder: (context, index) {
                    final staff = filtered[index];
                    final isActive = staff['isActive'] as bool;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.champagneGold.withValues(alpha: 0.15),
                        child: Text(
                          (staff['name'] as String).substring(0, 1),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.champagneGold),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(staff['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          StatusBadge(
                            label: staff['role'] as String,
                            variant: _getStatusBadgeType(staff['role'] as String),
                          ),
                          if (!isActive) ...[
                            const SizedBox(width: 8),
                            const StatusBadge(label: 'Deactivated', variant: BadgeVariant.error),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('${staff['email']} • ${staff['phone']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text('Branch: ${staff['branch']} • Joined: ${staff['joined']}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.vpn_key_outlined, size: 18, color: AppColors.champagneGold),
                            tooltip: 'Reset Credentials',
                            onPressed: () => _showResetAccessDialog(staff),
                          ),
                          Switch(
                            value: isActive,
                            activeThumbColor: AppColors.champagneGold,
                            onChanged: canManage
                                ? (val) {
                                    setState(() {
                                      staff['isActive'] = val;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${staff['name']} is now ${val ? "Active" : "Deactivated"}'),
                                        backgroundColor: val ? AppColors.successGreen : AppColors.errorRed,
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BadgeVariant _getStatusBadgeType(String role) {
    switch (role) {
      case 'Owner': return BadgeVariant.warning;
      case 'Admin': return BadgeVariant.info;
      case 'Branch Manager': return BadgeVariant.success;
      case 'Cashier': return BadgeVariant.info;
      case 'Kitchen Staff': return BadgeVariant.warning;
      default: return BadgeVariant.neutral;
    }
  }
}
