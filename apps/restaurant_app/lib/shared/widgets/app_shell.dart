// Anabhay Ventures — Main Application Shell with Responsive Sidebar

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import 'app_sidebar.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isSidebarExpanded = true;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/pos')) return 2;
    if (location.startsWith('/tables')) return 3;
    if (location.startsWith('/menu')) return 4;
    if (location.startsWith('/kitchen')) return 5;
    if (location.startsWith('/inventory')) return 6;
    if (location.startsWith('/staff')) return 7;
    if (location.startsWith('/customers')) return 8;
    if (location.startsWith('/reports')) return 9;
    if (location.startsWith('/expenses')) return 10;
    if (location.startsWith('/settings')) return 11;
    return 0; // Dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/orders');
        break;
      case 2:
        context.go('/pos');
        break;
      case 3:
        context.go('/tables');
        break;
      case 4:
        context.go('/menu');
        break;
      case 5:
        context.go('/kitchen');
        break;
      case 6:
        context.go('/inventory');
        break;
      case 7:
        context.go('/staff');
        break;
      case 8:
        context.go('/customers');
        break;
      case 9:
        context.go('/reports');
        break;
      case 10:
        context.go('/expenses');
        break;
      case 11:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final selectedIndex = _calculateSelectedIndex(context);

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.matteBlack,
        drawer: Drawer(
          backgroundColor: AppColors.surfaceDark,
          child: AppSidebar(
            selectedIndex: selectedIndex,
            isExpanded: true,
            onToggle: () => Navigator.of(context).pop(),
            onItemTapped: (idx) {
              Navigator.of(context).pop();
              _onItemTapped(idx, context);
            },
          ),
        ),
        appBar: AppBar(
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.champagneGold),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: const Text(
            'Restaurant Management',
            style: TextStyle(
              color: AppColors.champagneGold,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppColors.surfaceDark,
          elevation: 0,
        ),
        body: widget.child,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: selectedIndex,
            isExpanded: _isSidebarExpanded,
            onToggle: () {
              setState(() {
                _isSidebarExpanded = !_isSidebarExpanded;
              });
            },
            onItemTapped: (idx) => _onItemTapped(idx, context),
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

