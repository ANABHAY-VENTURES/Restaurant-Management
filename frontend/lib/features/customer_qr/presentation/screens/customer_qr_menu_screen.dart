// Anabhay Ventures — Customer Table QR Ordering Screen (Mobile-First Web Experience)
// Phase 5: Complete Customer QR Ordering, Item Customization, Live Cart & KDS Linking

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../pos/domain/models/order_models.dart';
import '../../../pos/presentation/providers/pos_providers.dart';
import '../../../inventory/domain/models/inventory_models.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';
import '../providers/customer_cart_provider.dart';
import '../widgets/food_customization_sheet.dart';
import '../widgets/customer_cart_sheet.dart';
import 'package:restaurant_management/features/settings/presentation/providers/settings_providers.dart';

class CustomerQRMenuScreen extends ConsumerStatefulWidget {
  final String tableNumber;

  const CustomerQRMenuScreen({super.key, this.tableNumber = 'Table 05'});

  @override
  ConsumerState<CustomerQRMenuScreen> createState() => _CustomerQRMenuScreenState();
}

class _CustomerQRMenuScreenState extends ConsumerState<CustomerQRMenuScreen> {
  String _selectedCategory = 'All';
  bool _vegOnly = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerCartProvider.notifier).setTableNumber(widget.tableNumber);
      final tax = ref.read(taxBillingConfigProvider);
      ref.read(customerCartProvider.notifier).setTaxConfig(
            taxRatePercent: tax.taxRatePercent,
            isGstEnabled: tax.isGstEnabled,
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTap(MenuItem item) {
    if (!item.isAvailable) return;

    if (item.variants.isNotEmpty || item.addOns.isNotEmpty) {
      FoodCustomizationSheet.show(context, item);
    } else {
      ref.read(customerCartProvider.notifier).addItem(menuItem: item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${item.name} to order!'),
          backgroundColor: AppColors.champagneGold,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(menuItemsProvider);
    final allCategories = ref.watch(categoriesProvider);
    final cart = ref.watch(customerCartProvider);
    final allOrders = ref.watch(ordersProvider);
    final profile = ref.watch(restaurantProfileProvider);

    // Check if table has an active order in kitchen
    final activeTableOrder = allOrders.where((o) {
      return o.tableNumber == widget.tableNumber &&
          (o.orderStatus == OrderStatus.newOrder ||
              o.orderStatus == OrderStatus.preparing ||
              o.orderStatus == OrderStatus.ready);
    }).firstOrNull;

    // Filter menu items
    final filtered = allItems.where((item) {
      if (_vegOnly && item.dietaryType != DietaryType.veg) return false;
      if (_selectedCategory != 'All' && item.category != _selectedCategory) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatches = item.name.toLowerCase().contains(q);
        final descMatches = item.description.toLowerCase().contains(q);
        if (!nameMatches && !descMatches) return false;
      }
      return true;
    }).toList();

    final featuredItems = allItems.where((i) => i.isFeatured && i.isAvailable).toList();

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // App Bar with Cover Image
                  SliverAppBar(
                    expandedHeight: 180,
                    pinned: true,
                    backgroundColor: AppColors.surfaceDark,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.champagneGold),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.champagneGold.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Veg Only', style: TextStyle(fontSize: 11, color: AppColors.warmIvory)),
                            const SizedBox(width: 4),
                            Transform.scale(
                              scale: 0.75,
                              child: Switch(
                                value: _vegOnly,
                                activeThumbColor: AppColors.successGreen,
                                onChanged: (val) => setState(() => _vegOnly = val),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.surfaceDark,
                              AppColors.champagneGold.withValues(alpha: 0.25),
                              AppColors.matteBlack,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.champagneGold, width: 1.5),
                                    ),
                                    child: const Icon(Icons.restaurant_rounded, size: 28, color: AppColors.champagneGold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    profile.name.toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.champagneGold,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  Text(
                                    profile.tagline.toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 9,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceCard,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${widget.tableNumber} • Digital Guest Menu',
                                      style: const TextStyle(fontSize: 10, color: AppColors.warmIvory, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Active Kitchen Order Banner (if guest already ordered)
                  if (activeTableOrder != null)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.champagneGold, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.champagneGold.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.soup_kitchen_rounded, size: 20, color: AppColors.champagneGold),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        activeTableOrder.kotNumber,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.champagneGold),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: activeTableOrder.orderStatus.color.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          activeTableOrder.orderStatus.label.toUpperCase(),
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: activeTableOrder.orderStatus.color),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text('Kitchen is working on your order.', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.champagneGold,
                                foregroundColor: AppColors.matteBlack,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: () => context.push('/track-order/${activeTableOrder.id}'),
                              child: const Text('Track Live', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.base, AppSpacing.base, 4),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(fontSize: 13, color: AppColors.warmIvory),
                        decoration: InputDecoration(
                          hintText: 'Search biryani, kebab, dal, dessert...',
                          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.champagneGold),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16, color: AppColors.textTertiary),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.surfaceCard,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                            borderSide: const BorderSide(color: AppColors.borderSubtle),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                            borderSide: const BorderSide(color: AppColors.champagneGold),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Featured / Chef's Special Carousel (when not searching)
                  if (_searchQuery.isEmpty && featuredItems.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.base, 12, AppSpacing.base, 6),
                        child: Row(
                          children: const [
                            Icon(Icons.stars_rounded, size: 18, color: AppColors.champagneGold),
                            SizedBox(width: 6),
                            Text('Chef\'s Royal Recommendations', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 140,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                          scrollDirection: Axis.horizontal,
                          itemCount: featuredItems.length,
                          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final item = featuredItems[index];
                            return InkWell(
                              onTap: () => _onItemTap(item),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 220,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.champagneGold.withValues(alpha: 0.5)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildDietaryDot(item.dietaryType),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.champagneGold.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('CHEF SPL', style: TextStyle(fontSize: 8, color: AppColors.champagneGold, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.warmIvory), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text(item.description, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('₹${item.basePrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.champagneGold,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text('+ ADD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.matteBlack)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // Category Selector Chips
                  SliverToBoxAdapter(
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryChip('All', allItems.length),
                          const SizedBox(width: AppSpacing.sm),
                          ...allCategories.map((cat) {
                            final count = allItems.where((i) => i.category == cat.name).length;
                            return Padding(
                              padding: const EdgeInsets.only(right: AppSpacing.sm),
                              child: _buildCategoryChip(cat.name, count),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Menu Items List
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    sliver: filtered.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(48),
                                child: Text('No dishes available matching your selection.', style: TextStyle(color: AppColors.textTertiary)),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = filtered[index];
                                final inCartCount = cart.items
                                    .where((i) => i.menuItem.id == item.id)
                                    .fold(0, (sum, i) => sum + i.quantity);

                                return _buildMenuItemCard(item, inCartCount);
                              },
                              childCount: filtered.length,
                            ),
                          ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),

              // Persistent Floating Cart Bottom Bar
              if (cart.totalItemCount > 0)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    color: AppColors.surfaceElevated,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      onTap: () => CustomerCartSheet.show(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                          border: Border.all(color: AppColors.champagneGold, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.champagneGold,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${cart.totalItemCount}',
                                style: const TextStyle(color: AppColors.matteBlack, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${cart.totalItemCount} items selected', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                Text('₹${cart.grandTotal.toStringAsFixed(0)}', style: AppTypography.currencyLarge.copyWith(color: AppColors.champagneGold)),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: const [
                                Text('View Order', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.champagneGold, fontSize: 13)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.champagneGold),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String name, int count) {
    final isSelected = name == _selectedCategory;
    return ChoiceChip(
      label: Text(name == 'All' ? 'All Dishes ($count)' : '$name ($count)'),
      selected: isSelected,
      selectedColor: AppColors.champagneGold,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.matteBlack : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      onSelected: (_) => setState(() => _selectedCategory = name),
    );
  }

  Widget _buildMenuItemCard(MenuItem item, int inCartCount) {
    final isAvailable = item.isAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: isAvailable ? AppColors.borderSubtle : AppColors.errorRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dietary Square Dot
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _buildDietaryDot(item.dietaryType),
          ),
          const SizedBox(width: AppSpacing.md),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTypography.titleMedium.copyWith(
                          color: isAvailable ? AppColors.warmIvory : AppColors.textTertiary,
                          decoration: isAvailable ? null : TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                    if (item.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.champagneGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('CHEF SPL', style: TextStyle(fontSize: 8, color: AppColors.champagneGold, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '₹${item.basePrice.toStringAsFixed(0)}',
                      style: AppTypography.currencyMedium.copyWith(
                        color: isAvailable ? AppColors.champagneGold : AppColors.textTertiary,
                      ),
                    ),
                    if (item.variants.isNotEmpty || item.addOns.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      const Text('• Customizable', style: TextStyle(fontSize: 10, color: AppColors.champagneGold)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Add / Customize Action
          if (!isAvailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.4)),
              ),
              child: const Text('SOLD OUT', style: TextStyle(fontSize: 10, color: AppColors.errorRed, fontWeight: FontWeight.bold)),
            )
          else if (inCartCount > 0)
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.champagneGold,
                    foregroundColor: AppColors.matteBlack,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(60, 32),
                  ),
                  onPressed: () => _onItemTap(item),
                  child: Text('$inCartCount IN CART', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                ),
                if (item.variants.isNotEmpty || item.addOns.isNotEmpty)
                  const Text('Custom', style: TextStyle(fontSize: 9, color: AppColors.textTertiary)),
              ],
            )
          else
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.champagneGold,
                side: const BorderSide(color: AppColors.champagneGold),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                minimumSize: const Size(60, 32),
              ),
              onPressed: () => _onItemTap(item),
              child: const Text('ADD +', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _buildDietaryDot(DietaryType type) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        border: Border.all(color: type.color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: type.color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
