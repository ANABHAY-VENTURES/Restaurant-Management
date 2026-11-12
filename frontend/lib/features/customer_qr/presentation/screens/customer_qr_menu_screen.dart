// Anabhay Ventures — Customer Table QR Ordering Screen (Mobile-First Web Experience)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';

class CustomerQRMenuScreen extends StatefulWidget {
  final String tableNumber;

  const CustomerQRMenuScreen({super.key, this.tableNumber = 'Table 04'});

  @override
  State<CustomerQRMenuScreen> createState() => _CustomerQRMenuScreenState();
}

class _CustomerQRMenuScreenState extends State<CustomerQRMenuScreen> {
  String _selectedCategory = 'All';
  bool _vegOnly = false;
  final Map<String, int> _cart = {};

  final List<String> _categories = [
    'All',
    'Chef Specials',
    'Starters',
    'Main Course',
    'Breads',
    'Desserts',
    'Drinks',
  ];

  final List<Map<String, dynamic>> _menu = [
    {
      'id': 'qr1',
      'name': 'Saffron Dum Biryani',
      'desc': 'Slow-cooked fragrant basmati rice, tender spiced meat, and premium saffron in a sealed clay pot.',
      'category': 'Chef Specials',
      'price': 540.0,
      'isVeg': false,
    },
    {
      'id': 'qr2',
      'name': 'Murgh Malai Tikka',
      'desc': 'Creamy chicken morsels marinated in cheese, cardamom, and fresh green chilies charred in clay tandoor.',
      'category': 'Starters',
      'price': 460.0,
      'isVeg': false,
    },
    {
      'id': 'qr3',
      'name': 'Paneer Tikka Angara',
      'desc': 'Soft malai paneer cubes stuffed with dry fruit chutney, rolled in spiced yoghurt marinade.',
      'category': 'Starters',
      'price': 390.0,
      'isVeg': true,
    },
    {
      'id': 'qr4',
      'name': 'Dal Makhani Reserve',
      'desc': '24-hour slow simmered black lentils infused with churned white butter and vine-ripened tomatoes.',
      'category': 'Main Course',
      'price': 380.0,
      'isVeg': true,
    },
    {
      'id': 'qr5',
      'name': 'Butter Garlic Naan',
      'desc': 'Classic leavened refined flour flatbread brushed with garlic butter and fresh coriander.',
      'category': 'Breads',
      'price': 110.0,
      'isVeg': true,
    },
    {
      'id': 'qr6',
      'name': 'Gulab Jamun Flambé',
      'desc': 'Warm golden khoya dumplings flambéed with aged dark rum and cardamom syrup.',
      'category': 'Desserts',
      'price': 220.0,
      'isVeg': true,
    },
  ];

  void _addToCart(String id) {
    setState(() {
      _cart[id] = (_cart[id] ?? 0) + 1;
    });
  }

  void _removeFromCart(String id) {
    setState(() {
      if ((_cart[id] ?? 0) > 1) {
        _cart[id] = _cart[id]! - 1;
      } else {
        _cart.remove(id);
      }
    });
  }

  int get _totalItems => _cart.values.fold(0, (a, b) => a + b);
  double get _cartTotal {
    double total = 0.0;
    _cart.forEach((id, qty) {
      final item = _menu.firstWhere((m) => m['id'] == id);
      total += (item['price'] as double) * qty;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _menu.where((item) {
      if (_vegOnly && !(item['isVeg'] as bool)) return false;
      if (_selectedCategory != 'All' && item['category'] != _selectedCategory) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The Royal Saffron', style: TextStyle(color: AppColors.champagneGold, fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${widget.tableNumber} • Digital Menu', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          Row(
            children: [
              const Text('Veg Only', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Switch(
                value: _vegOnly,
                activeThumbColor: AppColors.successGreen,
                onChanged: (val) => setState(() => _vegOnly = val),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Category filter
              SliverToBoxAdapter(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _selectedCategory;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.champagneGold,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.matteBlack : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (val) => setState(() => _selectedCategory = cat),
                      );
                    },
                  ),
                ),
              ),
              // Menu items
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.base),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filtered[index];
                      final id = item['id'] as String;
                      final isVeg = item['isVeg'] as bool;
                      final inCart = _cart[id] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.base),
                        padding: const EdgeInsets.all(AppSpacing.base),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Veg / Non-Veg Indicator
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  border: Border.all(color: isVeg ? AppColors.successGreen : AppColors.errorRed, width: 1.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isVeg ? AppColors.successGreen : AppColors.errorRed,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'] as String, style: AppTypography.titleMedium),
                                  const SizedBox(height: 2),
                                  Text('₹${(item['price'] as num).toStringAsFixed(0)}', style: AppTypography.currencyMedium.copyWith(fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['desc'] as String,
                                    style: AppTypography.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            // Add button
                            if (inCart == 0)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceElevated,
                                  foregroundColor: AppColors.champagneGold,
                                  side: const BorderSide(color: AppColors.champagneGold, width: 1),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                onPressed: () => _addToCart(id),
                                child: const Text('ADD +', style: TextStyle(fontWeight: FontWeight.w700)),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.champagneGold,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.remove, size: 16, color: AppColors.matteBlack),
                                      onPressed: () => _removeFromCart(id),
                                    ),
                                    Text('$inCart', style: const TextStyle(color: AppColors.matteBlack, fontWeight: FontWeight.w800)),
                                    IconButton(
                                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.add, size: 16, color: AppColors.matteBlack),
                                      onPressed: () => _addToCart(id),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
          // Floating Cart Bar
          if (_totalItems > 0)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Material(
                color: AppColors.champagneGold,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                elevation: 8,
                child: InkWell(
                  onTap: () {
                    AppDialog.show(
                      context: context,
                      title: 'Confirm Table Order',
                      subtitle: 'Sending direct to kitchen for ${widget.tableNumber}',
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$_totalItems items selected • Total: ₹${_cartTotal.toStringAsFixed(0)}'),
                          const SizedBox(height: 8),
                          const Text('The kitchen will begin preparing your food immediately.'),
                        ],
                      ),
                      confirmLabel: 'Place Order Now',
                      onConfirm: () {
                        Navigator.of(context).pop();
                        setState(() => _cart.clear());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order placed successfully! Chef has received your KOT.'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_totalItems Items in Cart',
                              style: const TextStyle(color: AppColors.matteBlack, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              '₹${_cartTotal.toStringAsFixed(0)}',
                              style: const TextStyle(color: AppColors.matteBlack, fontWeight: FontWeight.w800, fontSize: 18),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'View Cart & Order',
                          style: TextStyle(color: AppColors.matteBlack, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: AppColors.matteBlack, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
