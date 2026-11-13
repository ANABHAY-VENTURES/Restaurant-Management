// Anabhay Ventures — Sidebar Navigation

import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../features/auth/presentation/widgets/logout_confirmation_dialog.dart';
import '../../features/customer_qr/presentation/screens/customer_qr_menu_screen.dart';

class SidebarItem {
  final String label;
  final IconData icon;
  final String route;
  final List<SidebarItem>? children;

  const SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    this.children,
  });
}

class AppSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final bool isExpanded;
  final VoidCallback onToggle;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _widthAnim;

  static const List<SidebarItem> items = [
    SidebarItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/'),
    SidebarItem(label: 'POS Billing', icon: Icons.point_of_sale_rounded, route: '/pos'),
    SidebarItem(label: 'Orders & KOT', icon: Icons.soup_kitchen_outlined, route: '/kitchen'),
    SidebarItem(label: 'Tables', icon: Icons.table_restaurant_outlined, route: '/tables'),
    SidebarItem(label: 'Menu', icon: Icons.restaurant_menu_rounded, route: '/menu'),
    SidebarItem(label: 'Inventory', icon: Icons.inventory_2_outlined, route: '/inventory'),
    SidebarItem(label: 'Purchases', icon: Icons.shopping_cart_outlined, route: '/purchases'),
    SidebarItem(label: 'Staff', icon: Icons.badge_outlined, route: '/staff'),
    SidebarItem(label: 'Customers', icon: Icons.favorite_border_rounded, route: '/customers'),
    SidebarItem(label: 'Reports', icon: Icons.bar_chart_rounded, route: '/reports'),
    SidebarItem(label: 'Settings', icon: Icons.tune_rounded, route: '/settings'),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.isExpanded ? 1.0 : 0.0,
    );
    _widthAnim = Tween<double>(
      begin: AppSpacing.sidebarCollapsedWidth,
      end: AppSpacing.sidebarExpandedWidth,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant AppSidebar old) {
    super.didUpdateWidget(old);
    if (widget.isExpanded != old.isExpanded) {
      widget.isExpanded ? _animController.forward() : _animController.reverse();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnim,
      builder: (context, child) {
        return Container(
          width: _widthAnim.value,
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            border: Border(
              right: BorderSide(color: AppColors.borderSubtle, width: 1),
            ),
          ),
          child: Column(
            children: [
              // ── Logo / Brand ───────────────────────────
              _buildHeader(),
              const SizedBox(height: AppSpacing.sm),
              // ── Nav Items ──────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selected = index == widget.selectedIndex;
                    return _NavTile(
                      item: item,
                      isExpanded: widget.isExpanded,
                      isSelected: selected,
                      onTap: () => widget.onItemTapped(index),
                    );
                  },
                ),
              ),
              // ── Customer QR Menu Shortcut ──────────────
              if (widget.isExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.champagneGold,
                      side: BorderSide(color: AppColors.champagneGold.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                    icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                    label: const Text('Customer QR', style: TextStyle(fontSize: 12)),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CustomerQRMenuScreen()),
                    ),
                  ),
                ),
              // ── Active User Profile & Logout ───────────
              _buildUserProfile(context),
              // ── Collapse Toggle ────────────────────────
              _buildCollapseButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.champagneGold, AppColors.copper],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: AppColors.matteBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (widget.isExpanded) ...[
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Text(
                'Anabhay',
                style: TextStyle(
                  color: AppColors.champagneGold,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    if (!widget.isExpanded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: IconButton(
          icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.mutedGrey),
          tooltip: 'Sign Out',
          onPressed: () => LogoutConfirmationDialog.show(context),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.champagneGold.withValues(alpha: 0.2),
            child: const Text('V', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Vikramaditya Roy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                Text('Owner • Main CP', style: TextStyle(fontSize: 10, color: AppColors.champagneGold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.textTertiary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Sign Out',
            onPressed: () => LogoutConfirmationDialog.show(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapseButton() {
    return InkWell(
      onTap: widget.onToggle,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        child: Icon(
          widget.isExpanded ? Icons.menu_open_rounded : Icons.menu_rounded,
          size: 20,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final SidebarItem item;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isExpanded,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isSelected
            ? AppColors.champagneGold.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: onTap,
          child: Container(
            height: 44,
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? AppSpacing.md : 0,
            ),
            alignment: isExpanded ? Alignment.centerLeft : Alignment.center,
            child: Row(
              mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.champagneGold
                      : AppColors.textSecondary,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      item.label,
                      style: AppTypography.labelLarge.copyWith(
                        color: isSelected
                            ? AppColors.champagneGold
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
