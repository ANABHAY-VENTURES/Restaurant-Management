// Anabhay Ventures — POS Billing Screen

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/invoice_preview_dialog.dart';

class POSBillingScreen extends StatefulWidget {
  const POSBillingScreen({super.key});

  @override
  State<POSBillingScreen> createState() => _POSBillingScreenState();
}

class _POSBillingScreenState extends State<POSBillingScreen> {
  String _selectedCategory = 'All';
  String _selectedTable = 'Table 04';
  String _selectedOrderType = 'Dine-in';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Starters',
    'Main Course',
    'Breads',
    'Biryani',
    'Desserts',
    'Beverages',
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {'id': 'm1', 'name': 'Saffron Dum Biryani', 'category': 'Biryani', 'price': 540.0, 'isVeg': false, 'image': 'biryani.jpg'},
    {'id': 'm2', 'name': 'Murgh Malai Tikka', 'category': 'Starters', 'price': 460.0, 'isVeg': false, 'image': 'tikka.jpg'},
    {'id': 'm3', 'name': 'Paneer Tikka Angara', 'category': 'Starters', 'price': 390.0, 'isVeg': true, 'image': 'paneer.jpg'},
    {'id': 'm4', 'name': 'Dal Makhani Reserve', 'category': 'Main Course', 'price': 380.0, 'isVeg': true, 'image': 'dal.jpg'},
    {'id': 'm5', 'name': 'Butter Chicken Royale', 'category': 'Main Course', 'price': 520.0, 'isVeg': false, 'image': 'butter_chicken.jpg'},
    {'id': 'm6', 'name': 'Butter Garlic Naan', 'category': 'Breads', 'price': 110.0, 'isVeg': true, 'image': 'naan.jpg'},
    {'id': 'm7', 'name': 'Tandoori Roti', 'category': 'Breads', 'price': 45.0, 'isVeg': true, 'image': 'roti.jpg'},
    {'id': 'm8', 'name': 'Gulab Jamun Flambé', 'category': 'Desserts', 'price': 220.0, 'isVeg': true, 'image': 'jamun.jpg'},
    {'id': 'm9', 'name': 'Kesari Phirni', 'category': 'Desserts', 'price': 190.0, 'isVeg': true, 'image': 'phirni.jpg'},
    {'id': 'm10', 'name': 'Fresh Lime Soda', 'category': 'Beverages', 'price': 120.0, 'isVeg': true, 'image': 'soda.jpg'},
    {'id': 'm11', 'name': 'Royal Masala Chai', 'category': 'Beverages', 'price': 90.0, 'isVeg': true, 'image': 'chai.jpg'},
  ];

  // Active Cart State
  final List<Map<String, dynamic>> _cartItems = [
    {'id': 'm1', 'name': 'Saffron Dum Biryani', 'price': 540.0, 'qty': 2},
    {'id': 'm6', 'name': 'Butter Garlic Naan', 'price': 110.0, 'qty': 3},
    {'id': 'm4', 'name': 'Dal Makhani Reserve', 'price': 380.0, 'qty': 1},
  ];

  void _addItem(Map<String, dynamic> item) {
    setState(() {
      final index = _cartItems.indexWhere((c) => c['id'] == item['id']);
      if (index >= 0) {
        _cartItems[index]['qty'] = (_cartItems[index]['qty'] as int) + 1;
      } else {
        _cartItems.add({
          'id': item['id'],
          'name': item['name'],
          'price': item['price'],
          'qty': 1,
        });
      }
    });
  }

  void _removeItem(String id) {
    setState(() {
      final index = _cartItems.indexWhere((c) => c['id'] == id);
      if (index >= 0) {
        final currentQty = _cartItems[index]['qty'] as int;
        if (currentQty > 1) {
          _cartItems[index]['qty'] = currentQty - 1;
        } else {
          _cartItems.removeAt(index);
        }
      }
    });
  }

  double get _subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + (item['price'] as double) * (item['qty'] as int));
  }

  double get _cgst => _subtotal * 0.025; // 2.5% CGST
  double get _sgst => _subtotal * 0.025; // 2.5% SGST
  double get _grandTotal => _subtotal + _cgst + _sgst;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Menu & Categories
          Expanded(
            flex: isDesktop ? 6 : 5,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: AppSpacing.md),
                  _buildCategoryFilter(),
                  const SizedBox(height: AppSpacing.base),
                  Expanded(child: _buildMenuGrid()),
                ],
              ),
            ),
          ),
          // Right: Active Bill / Cart Panel
          Container(
            width: isDesktop ? 380 : 320,
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border(left: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: _buildCartPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            hintText: 'Search menu dishes, codes...',
            prefixIcon: Icons.search,
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Dine-in / Takeaway Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedOrderType,
              dropdownColor: AppColors.surfaceElevated,
              style: AppTypography.labelMedium.copyWith(color: AppColors.champagneGold),
              items: ['Dine-in', 'Takeaway', 'Delivery'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) => setState(() => _selectedOrderType = val!),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Table selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTable,
              dropdownColor: AppColors.surfaceElevated,
              style: AppTypography.labelMedium.copyWith(color: AppColors.warmIvory),
              items: ['Table 01', 'Table 04', 'Table 08', 'Table 12', 'Takeaway 01'].map((t) {
                return DropdownMenuItem(value: t, child: Text(t));
              }).toList(),
              onChanged: (val) => setState(() => _selectedTable = val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return Material(
            color: isSelected ? AppColors.champagneGold : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.center,
                child: Text(
                  cat,
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? AppColors.matteBlack : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuGrid() {
    final filtered = _menuItems.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item['category'] == _selectedCategory;
      final matchesSearch = item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 160,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final isVeg = item['isVeg'] as bool;
        return Material(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: InkWell(
            onTap: () => _addItem(item),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Veg / Non-veg dot + Category
                  Row(
                    children: [
                      Container(
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
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          item['category'] as String,
                          style: AppTypography.labelSmall.copyWith(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    item['name'] as String,
                    style: AppTypography.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${(item['price'] as num).toStringAsFixed(0)}',
                        style: AppTypography.currencyMedium.copyWith(fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.champagneGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.add, size: 16, color: AppColors.champagneGold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cart Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Bill', style: AppTypography.titleLarge),
                    Text('$_selectedTable • $_selectedOrderType', style: AppTypography.bodySmall),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _cartItems.clear()),
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textTertiary),
                tooltip: 'Clear Cart',
              ),
            ],
          ),
        ),
        // Item List
        Expanded(
          child: _cartItems.isEmpty
              ? const AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order is empty',
                  description: 'Select dishes from the menu to start billing.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  itemCount: _cartItems.length,
                  separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 16),
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    final price = (item['price'] as num).toDouble();
                    final qty = item['qty'] as int;
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'] as String, style: AppTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('₹${price.toStringAsFixed(0)} each', style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                        // Qty controls
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _removeItem(item['id'] as String),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(4)),
                                child: const Icon(Icons.remove, size: 14, color: AppColors.warmIvory),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text('$qty', style: AppTypography.titleMedium),
                            ),
                            InkWell(
                              onTap: () => _addItem(item),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(4)),
                                child: const Icon(Icons.add, size: 14, color: AppColors.warmIvory),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          '₹${(price * qty).toStringAsFixed(0)}',
                          style: AppTypography.titleMedium.copyWith(color: AppColors.champagneGold),
                        ),
                      ],
                    );
                  },
                ),
        ),
        // Bill Summary Footer
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: const BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Column(
            children: [
              _summaryRow('Subtotal', '₹${_subtotal.toStringAsFixed(2)}'),
              _summaryRow('CGST (2.5%)', '₹${_cgst.toStringAsFixed(2)}'),
              _summaryRow('SGST (2.5%)', '₹${_sgst.toStringAsFixed(2)}'),
              const Divider(color: AppColors.borderSubtle, height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: AppTypography.titleLarge),
                  Text('₹${_grandTotal.toStringAsFixed(2)}', style: AppTypography.currencyLarge),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Send KOT',
                      variant: AppButtonVariant.secondary,
                      icon: Icons.soup_kitchen_outlined,
                      onPressed: _cartItems.isEmpty ? null : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('KOT sent to kitchen for $_selectedTable!'),
                            backgroundColor: AppColors.warningAmber,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: 'Pay & Bill',
                      variant: AppButtonVariant.primary,
                      icon: Icons.receipt_long,
                      onPressed: _cartItems.isEmpty ? null : () {
                        InvoicePreviewDialog.show(
                          context: context,
                          invoiceNumber: 'INV-2026-0924',
                          tableNumber: _selectedTable,
                          orderType: _selectedOrderType,
                          items: List.from(_cartItems),
                          subtotal: _subtotal,
                          cgst: _cgst,
                          sgst: _sgst,
                          total: _grandTotal,
                          paymentMethod: 'UPI / Card',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
