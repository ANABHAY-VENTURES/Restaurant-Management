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
    final index = AppSidebar.items.indexWhere(
      (it) => it.route == location || (it.route != '/' && location.startsWith(it.route)),
    );
    return index >= 0 ? index : 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index >= 0 && index < AppSidebar.items.length) {
      context.go(AppSidebar.items[index].route);
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

