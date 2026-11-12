// Anabhay Ventures — Customer Table QR Ordering Application
// Standalone Mobile Web Application for In-Dine Digital Ordering

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CustomerQRApp());
}

final GoRouter _qrRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CustomerOrderingScreen(tableNumber: 'Table 04'),
    ),
    GoRoute(
      path: '/table/:tableId',
      builder: (context, state) => CustomerOrderingScreen(
        tableNumber: state.pathParameters['tableId'] ?? 'Table 04',
      ),
    ),
  ],
);

class CustomerQRApp extends StatelessWidget {
  const CustomerQRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Anabhay Royal Kitchen — Digital Menu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _qrRouter,
    );
  }
}

class CustomerOrderingScreen extends StatefulWidget {
  final String tableNumber;

  const CustomerOrderingScreen({super.key, required this.tableNumber});

  @override
  State<CustomerOrderingScreen> createState() => _CustomerOrderingScreenState();
}

class _CustomerOrderingScreenState extends State<CustomerOrderingScreen> {
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
      'desc': 'Smoked cottage cheese cubes tossed with bell peppers and roasted spices.',
      'category': 'Starters',
      'price': 390.0,
      'isVeg': true,
    },
    {
      'id': 'qr4',
      'name': 'Dal Makhani Bukhara',
      'desc': 'Simmered 24 hours on slow charcoal embers with white butter, vine tomatoes, and ginger.',
      'category': 'Main Course',
      'price': 380.0,
      'isVeg': true,
    },
    {
      'id': 'qr5',
      'name': 'Butter Garlic Naan',
      'desc': 'Hand-stretched leavened bread brushed with slow-roasted golden garlic butter.',
      'category': 'Breads',
      'price': 85.0,
      'isVeg': true,
    },
    {
      'id': 'qr6',
      'name': 'Kashmiri Saffron Phirni',
      'desc': 'Stone-ground rice pudding infused with pure Pampore saffron, served in earthen sakoras.',
      'category': 'Desserts',
      'price': 220.0,
      'isVeg': true,
    },
  ];

  int get _cartCount => _cart.values.fold(0, (a, b) => a + b);

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
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryFilter(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final itemId = item['id'] as String;
                  final qty = _cart[itemId] ?? 0;

                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.only(top: 3, right: AppSpacing.sm),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: item['isVeg'] as bool ? AppColors.successGreen : AppColors.errorRed,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: item['isVeg'] as bool ? AppColors.successGreen : AppColors.errorRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'] as String, style: AppTypography.titleMedium),
                              const SizedBox(height: 2),
                              Text('₹${(item['price'] as double).toStringAsFixed(0)}',
                                  style: AppTypography.titleSmall.copyWith(color: AppColors.champagneGold)),
                              const SizedBox(height: 4),
                              Text(item['desc'] as String,
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        qty == 0
                            ? OutlinedButton(
                                onPressed: () {
                                  setState(() => _cart[itemId] = 1);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.champagneGold),
                                  foregroundColor: AppColors.champagneGold,
                                  minimumSize: const Size(70, 34),
                                ),
                                child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              )
                            : Container(
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  border: Border.all(color: AppColors.champagneGold),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 14, color: AppColors.champagneGold),
                                      onPressed: () {
                                        setState(() {
                                          if (_cart[itemId]! > 1) {
                                            _cart[itemId] = _cart[itemId]! - 1;
                                          } else {
                                            _cart.remove(itemId);
                                          }
                                        });
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 28),
                                    ),
                                    Text('$qty', style: AppTypography.labelMedium.copyWith(color: AppColors.champagneGold)),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 14, color: AppColors.champagneGold),
                                      onPressed: () {
                                        setState(() => _cart[itemId] = (_cart[itemId] ?? 0) + 1);
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 28),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_cartCount > 0) _buildCartBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.champagneGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(Icons.restaurant_rounded, color: AppColors.champagneGold, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Anabhay Royal Kitchen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                Text(widget.tableNumber, style: const TextStyle(fontSize: 12, color: AppColors.champagneGold)),
              ],
            ),
          ),
          Row(
            children: [
              const Text('Veg Only', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: _vegOnly,
                  activeColor: AppColors.successGreen,
                  onChanged: (val) => setState(() => _vegOnly = val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat, style: TextStyle(fontSize: 12, color: isSelected ? AppColors.matteBlack : AppColors.textSecondary)),
              selected: isSelected,
              selectedColor: AppColors.champagneGold,
              backgroundColor: AppColors.surfaceElevated,
              side: BorderSide(color: isSelected ? AppColors.champagneGold : AppColors.borderSubtle),
              onSelected: (_) => setState(() => _selectedCategory = cat),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$_cartCount ITEMS', style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey)),
              Text('₹${_cartTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.champagneGold)),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.champagneGold,
              foregroundColor: AppColors.matteBlack,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
            ),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('Place Order to Kitchen', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order dispatched to Kitchen Display System for ${widget.tableNumber}!'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
              setState(() => _cart.clear());
            },
          ),
        ],
      ),
    );
  }
}

