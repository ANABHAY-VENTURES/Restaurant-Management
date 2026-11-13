// Anabhay Ventures — Role-Based Access Control (RBAC) & Permissions Engine

class RBACService {
  static const String roleOwner = 'owner';
  static const String roleAdmin = 'admin';
  static const String roleBranchManager = 'branch_manager';
  static const String roleCashier = 'cashier';
  static const String roleWaiter = 'waiter';
  static const String roleKitchenStaff = 'kitchen_staff';
  static const String roleInventoryManager = 'inventory_manager';
  static const String roleAccountant = 'accountant';

  static const List<Map<String, dynamic>> allRoles = [
    {
      'id': roleOwner,
      'name': 'Restaurant Owner',
      'description': 'Full administrative and financial authority across all branches and organization settings.',
    },
    {
      'id': roleAdmin,
      'name': 'Restaurant Admin',
      'description': 'Operations manager with staff, menu, table, and operational control.',
    },
    {
      'id': roleBranchManager,
      'name': 'Branch Manager',
      'description': 'Head of branch with shift, table, inventory, and order dispatch authority.',
    },
    {
      'id': roleCashier,
      'name': 'Cashier / POS Operator',
      'description': 'Counter billing, invoice generation, payment settlements, and cash drawer management.',
    },
    {
      'id': roleWaiter,
      'name': 'Table Waiter / Captain',
      'description': 'Dine-in table taking, live order punch, KOT dispatch, and customer service.',
    },
    {
      'id': roleKitchenStaff,
      'name': 'Kitchen Chef / Line Cook',
      'description': 'Kitchen Display System (KDS), preparation status bump, and item readiness.',
    },
    {
      'id': roleInventoryManager,
      'name': 'Inventory & Stock Manager',
      'description': 'Raw ingredients inward, recipe deductions, wastage logging, and supplier orders.',
    },
    {
      'id': roleAccountant,
      'name': 'Accountant',
      'description': 'Financial reports, GST tax audit, operational expense ledgers, and revenue analysis.',
    },
  ];

  static const Map<String, List<String>> _rolePermissions = {
    roleOwner: ['*'], // Wildcard - unrestricted
    roleAdmin: [
      'dashboard.view',
      'orders.create',
      'orders.view',
      'orders.update',
      'billing.create',
      'billing.view',
      'billing.cancel',
      'tables.manage',
      'menu.manage',
      'inventory.manage',
      'purchases.manage',
      'staff.manage',
      'reports.view',
      'settings.manage',
    ],
    roleBranchManager: [
      'dashboard.view',
      'orders.create',
      'orders.view',
      'orders.update',
      'billing.create',
      'billing.view',
      'tables.manage',
      'menu.manage',
      'kds.view',
      'kds.bump',
      'inventory.manage',
      'staff.view',
      'reports.view',
    ],
    roleCashier: [
      'dashboard.view',
      'billing.create',
      'billing.view',
      'billing.cancel',
      'orders.create',
      'orders.view',
      'tables.view',
    ],
    roleWaiter: [
      'orders.create',
      'orders.view',
      'orders.update',
      'tables.view',
      'tables.update',
      'menu.view',
    ],
    roleKitchenStaff: [
      'kds.view',
      'kds.bump',
      'orders.view',
    ],
    roleInventoryManager: [
      'dashboard.view',
      'inventory.manage',
      'purchases.manage',
      'menu.view',
    ],
    roleAccountant: [
      'dashboard.view',
      'reports.view',
      'reports.export',
      'billing.view',
      'expenses.manage',
    ],
  };

  /// Check if a given role possesses a specific permission
  static bool hasPermission(String role, String permission) {
    final permissions = _rolePermissions[role];
    if (permissions == null) return false;
    if (permissions.contains('*')) return true;
    return permissions.contains(permission);
  }

  /// Get the list of all permissions assigned to a role
  static List<String> getPermissionsForRole(String role) {
    if (role == roleOwner) {
      return [
        'dashboard.view',
        'orders.create',
        'orders.view',
        'orders.update',
        'billing.create',
        'billing.view',
        'billing.cancel',
        'kds.view',
        'kds.bump',
        'tables.manage',
        'menu.manage',
        'inventory.manage',
        'purchases.manage',
        'staff.manage',
        'reports.view',
        'reports.export',
        'expenses.manage',
        'settings.manage',
        'subscription.manage',
      ];
    }
    return _rolePermissions[role] ?? [];
  }
}
