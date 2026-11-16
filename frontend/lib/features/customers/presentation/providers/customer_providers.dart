// Anabhay Ventures — Customer CRM & Loyalty Providers
// Phase 6: Customer Directory, Loyalty Rewards, and CRM Analytics

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/customer_models.dart';
import '../../../pos/presentation/providers/pos_providers.dart';
import '../../../pos/data/restaurant_storage_repository.dart';

class CustomersNotifier extends StateNotifier<List<CustomerRecord>> {
  final RestaurantStorageRepository _repo;
  final Ref _ref;

  CustomersNotifier(this._repo, this._ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.loadCustomers();
  }

  Future<CustomerRecord> addCustomerManually({
    required String name,
    required String phone,
    String? email,
    String? birthday,
    String? address,
    String? notes,
  }) async {
    final existingIndex = state.indexWhere((c) => c.phone == phone.trim());
    if (existingIndex >= 0) {
      final existing = state[existingIndex];
      final updated = existing.copyWith(
        name: name,
        email: email ?? existing.email,
        birthday: birthday ?? existing.birthday,
        address: address ?? existing.address,
        notes: notes ?? existing.notes,
      );
      state = [
        for (final c in state)
          if (c.id == existing.id) updated else c,
      ];
      await _repo.saveCustomers(state);
      return updated;
    }

    final newCust = CustomerRecord(
      id: 'cust-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone.trim(),
      email: email,
      birthday: birthday,
      address: address,
      notes: notes,
      totalOrders: 0,
      totalSpend: 0.0,
      lastVisit: DateTime.now(),
      loyaltyPoints: 0,
      createdAt: DateTime.now(),
    );

    state = [newCust, ...state];
    await _repo.saveCustomers(state);
    return newCust;
  }

  Future<void> updateCustomer(CustomerRecord updated) async {
    state = [
      for (final c in state)
        if (c.id == updated.id) updated else c,
    ];
    await _repo.saveCustomers(state);
  }

  /// Automatically called on completed and paid orders with customer details
  Future<void> addOrUpdateFromOrder({
    required String name,
    required String phone,
    required double orderAmount,
    required String orderId,
  }) async {
    final cleanPhone = phone.trim();
    if (cleanPhone.isEmpty) return;

    final earnedPoints = (orderAmount / 20.0).floor(); // 1 pt per ₹20 spent
    final existingIndex = state.indexWhere((c) => c.phone == cleanPhone);

    if (existingIndex >= 0) {
      final current = state[existingIndex];
      final updated = current.copyWith(
        name: name.isNotEmpty ? name : current.name,
        totalOrders: current.totalOrders + 1,
        totalSpend: current.totalSpend + orderAmount,
        lastVisit: DateTime.now(),
        loyaltyPoints: current.loyaltyPoints + earnedPoints,
      );
      state = [
        for (final c in state)
          if (c.id == current.id) updated else c,
      ];
      await _repo.saveCustomers(state);

      if (earnedPoints > 0) {
        _ref.read(loyaltyProvider.notifier).recordTransaction(
              customerId: current.id,
              orderId: orderId,
              points: earnedPoints,
              type: 'earned',
              description: 'Earned $earnedPoints pts on Order #$orderId (₹${orderAmount.toStringAsFixed(0)})',
            );
      }
    } else {
      final newCust = CustomerRecord(
        id: 'cust-${DateTime.now().millisecondsSinceEpoch}',
        name: name.isNotEmpty ? name : 'Guest Patron',
        phone: cleanPhone,
        totalOrders: 1,
        totalSpend: orderAmount,
        lastVisit: DateTime.now(),
        loyaltyPoints: earnedPoints,
        createdAt: DateTime.now(),
      );
      state = [newCust, ...state];
      await _repo.saveCustomers(state);

      if (earnedPoints > 0) {
        _ref.read(loyaltyProvider.notifier).recordTransaction(
              customerId: newCust.id,
              orderId: orderId,
              points: earnedPoints,
              type: 'earned',
              description: 'Welcome loyalty reward on Order #$orderId (₹${orderAmount.toStringAsFixed(0)})',
            );
      }
    }
  }

  Future<void> redeemPoints({
    required String customerId,
    required int pointsToRedeem,
    required double discountValue,
  }) async {
    final existingIndex = state.indexWhere((c) => c.id == customerId);
    if (existingIndex < 0) return;

    final current = state[existingIndex];
    if (current.loyaltyPoints < pointsToRedeem) return;

    final updated = current.copyWith(
      loyaltyPoints: current.loyaltyPoints - pointsToRedeem,
    );
    state = [
      for (final c in state)
        if (c.id == current.id) updated else c,
    ];
    await _repo.saveCustomers(state);

    _ref.read(loyaltyProvider.notifier).recordTransaction(
          customerId: customerId,
          points: -pointsToRedeem,
          type: 'redeemed',
          description: 'Redeemed $pointsToRedeem pts for ₹${discountValue.toStringAsFixed(0)} discount voucher',
        );
  }

  Future<void> deleteCustomer(String id) async {
    state = state.where((c) => c.id != id).toList();
    await _repo.saveCustomers(state);
  }
}

final customersProvider = StateNotifierProvider<CustomersNotifier, List<CustomerRecord>>((ref) {
  final repo = ref.watch(restaurantStorageRepositoryProvider);
  return CustomersNotifier(repo, ref);
});

class LoyaltyNotifier extends StateNotifier<List<LoyaltyTransaction>> {
  final RestaurantStorageRepository _repo;

  LoyaltyNotifier(this._repo) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.loadLoyalty();
  }

  Future<void> recordTransaction({
    required String customerId,
    String? orderId,
    required int points,
    required String type,
    required String description,
  }) async {
    final newTx = LoyaltyTransaction(
      id: 'lt-${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      orderId: orderId,
      points: points,
      type: type,
      description: description,
      timestamp: DateTime.now(),
    );
    state = [newTx, ...state];
    await _repo.saveLoyalty(state);
  }
}

final loyaltyProvider = StateNotifierProvider<LoyaltyNotifier, List<LoyaltyTransaction>>((ref) {
  final repo = ref.watch(restaurantStorageRepositoryProvider);
  return LoyaltyNotifier(repo);
});

class CustomerMetrics {
  final int totalCustomers;
  final int newCustomers;
  final int returningCustomers;
  final int totalOrders;
  final double totalSpend;
  final double averageSpendPerCustomer;
  final List<CustomerRecord> topSpenders;
  final List<CustomerRecord> mostFrequent;

  const CustomerMetrics({
    required this.totalCustomers,
    required this.newCustomers,
    required this.returningCustomers,
    required this.totalOrders,
    required this.totalSpend,
    required this.averageSpendPerCustomer,
    required this.topSpenders,
    required this.mostFrequent,
  });
}

final customerMetricsProvider = Provider<CustomerMetrics>((ref) {
  final customers = ref.watch(customersProvider);
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));

  final newCount = customers.where((c) => c.createdAt.isAfter(thirtyDaysAgo)).length;
  final returningCount = customers.where((c) => c.isReturning).length;
  final totalOrders = customers.fold<int>(0, (sum, c) => sum + c.totalOrders);
  final totalSpend = customers.fold<double>(0.0, (sum, c) => sum + c.totalSpend);
  final avgSpend = customers.isNotEmpty ? totalSpend / customers.length : 0.0;

  final topSpenders = List<CustomerRecord>.from(customers)..sort((a, b) => b.totalSpend.compareTo(a.totalSpend));
  final mostFrequent = List<CustomerRecord>.from(customers)..sort((a, b) => b.totalOrders.compareTo(a.totalOrders));

  return CustomerMetrics(
    totalCustomers: customers.length,
    newCustomers: newCount,
    returningCustomers: returningCount,
    totalOrders: totalOrders,
    totalSpend: totalSpend,
    averageSpendPerCustomer: avgSpend,
    topSpenders: topSpenders.take(5).toList(),
    mostFrequent: mostFrequent.take(5).toList(),
  );
});
