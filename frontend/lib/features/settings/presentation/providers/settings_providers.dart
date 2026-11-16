// Anabhay Ventures — Restaurant Settings Riverpod Providers
// Phase 7: Profile, Taxes, Receipts, POS Config, Theme, Language, and Local Backup

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/settings_models.dart';
import '../../../pos/presentation/providers/pos_providers.dart';
import '../../../pos/data/restaurant_storage_repository.dart';

// ── Restaurant Profile Provider ─────────────────────────────────────────────

class ProfileNotifier extends StateNotifier<RestaurantProfile> {
  final RestaurantStorageRepository _repo;

  ProfileNotifier(this._repo) : super(const RestaurantProfile()) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.loadProfile();
  }

  Future<void> updateProfile(RestaurantProfile updated) async {
    state = updated;
    await _repo.saveProfile(updated);
  }
}

final restaurantProfileProvider = StateNotifierProvider<ProfileNotifier, RestaurantProfile>((ref) {
  final repo = ref.watch(restaurantStorageRepositoryProvider);
  return ProfileNotifier(repo);
});

// ── Tax & Billing Configuration Provider ────────────────────────────────────

class TaxBillingNotifier extends StateNotifier<TaxBillingConfig> {
  final RestaurantStorageRepository _repo;

  TaxBillingNotifier(this._repo) : super(const TaxBillingConfig()) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.loadTaxBilling();
  }

  Future<void> updateConfig(TaxBillingConfig updated) async {
    state = updated;
    await _repo.saveTaxBilling(updated);
  }
}

final taxBillingConfigProvider = StateNotifierProvider<TaxBillingNotifier, TaxBillingConfig>((ref) {
  final repo = ref.watch(restaurantStorageRepositoryProvider);
  return TaxBillingNotifier(repo);
});

// ── Invoice & Receipt Configuration Provider ────────────────────────────────

class InvoiceConfigNotifier extends StateNotifier<InvoiceReceiptConfig> {
  final RestaurantStorageRepository _repo;

  InvoiceConfigNotifier(this._repo) : super(const InvoiceReceiptConfig()) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.loadInvoiceConfig();
  }

  Future<void> updateConfig(InvoiceReceiptConfig updated) async {
    state = updated;
    await _repo.saveInvoiceConfig(updated);
  }
}

final invoiceReceiptConfigProvider = StateNotifierProvider<InvoiceConfigNotifier, InvoiceReceiptConfig>((ref) {
  final repo = ref.watch(restaurantStorageRepositoryProvider);
  return InvoiceConfigNotifier(repo);
});

// ── Order & POS Configuration Provider ──────────────────────────────────────

class OrderPosConfigNotifier extends StateNotifier<OrderPosConfig> {
  final RestaurantStorageRepository _repo;

  OrderPosConfigNotifier(this._repo) : super(const OrderPosConfig()) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.loadOrderPosConfig();
  }

  Future<void> updateConfig(OrderPosConfig updated) async {
    state = updated;
    await _repo.saveOrderPosConfig(updated);
  }
}

final orderPosConfigProvider = StateNotifierProvider<OrderPosConfigNotifier, OrderPosConfig>((ref) {
  final repo = ref.watch(restaurantStorageRepositoryProvider);
  return OrderPosConfigNotifier(repo);
});

// ── Table & QR Configuration Provider ───────────────────────────────────────

class TableQrConfigNotifier extends StateNotifier<TableQrConfig> {
  final RestaurantStorageRepository _repo;

  TableQrConfigNotifier(this._repo) : super(const TableQrConfig()) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.loadTableQrConfig();
  }

  Future<void> updateConfig(TableQrConfig updated) async {
    state = updated;
    await _repo.saveTableQrConfig(updated);
  }
}

final tableQrConfigProvider = StateNotifierProvider<TableQrConfigNotifier, TableQrConfig>((ref) {
  final repo = ref.watch(restaurantStorageRepositoryProvider);
  return TableQrConfigNotifier(repo);
});

// ── Theme Mode Provider ─────────────────────────────────────────────────────

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final RestaurantStorageRepository _repo;

  ThemeModeNotifier(this._repo) : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final modeStr = await _repo.loadThemeMode();
    if (modeStr == 'light') {
      state = ThemeMode.light;
    } else if (modeStr == 'system') {
      state = ThemeMode.system;
    } else {
      state = ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final modeStr = mode == ThemeMode.light ? 'light' : (mode == ThemeMode.system ? 'system' : 'dark');
    await _repo.saveThemeMode(modeStr);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final repo = ref.watch(restaurantStorageRepositoryProvider);
  return ThemeModeNotifier(repo);
});

// ── Application Locale Provider ─────────────────────────────────────────────

class AppLocaleNotifier extends StateNotifier<Locale> {
  final RestaurantStorageRepository _repo;

  AppLocaleNotifier(this._repo) : super(const Locale('en')) {
    _load();
  }

  Future<void> _load() async {
    final code = await _repo.loadLanguage();
    state = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _repo.saveLanguage(locale.languageCode);
  }
}

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale>((ref) {
  final repo = ref.watch(restaurantStorageRepositoryProvider);
  return AppLocaleNotifier(repo);
});
