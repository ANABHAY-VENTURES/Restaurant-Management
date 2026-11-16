// Anabhay Ventures — Restaurant Settings Domain Models
// Phase 7: Restaurant Profile, Tax & Billing, Invoice/Receipt Templates, POS, Theme & Language

import '../../../pos/domain/models/order_models.dart';

class RestaurantProfile {
  final String name;
  final String tagline;
  final String logoUrl;
  final String coverUrl;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String gstin;
  final String fssai;
  final String description;
  final String openingTime;
  final String closingTime;
  final String weeklyClosingDay;

  const RestaurantProfile({
    this.name = 'The Royal Saffron',
    this.tagline = 'Fine Dine & Royal Awadhi Cuisine',
    this.logoUrl = 'assets/images/logo.png',
    this.coverUrl = 'assets/images/cover.jpg',
    this.address = 'Connaught Place, Central Delhi, New Delhi 110001',
    this.phone = '+91 98765 43210',
    this.email = 'reservations@royalsaffron.com',
    this.website = 'https://royalsaffron.anabhay.com',
    this.gstin = '07AAAAA0000A1Z5',
    this.fssai = '10019011006543',
    this.description = 'Authentic royal Awadhi culinary experience with heritage recipes, slow dum-pukht cuisine, and signature kebabs.',
    this.openingTime = '11:00 AM',
    this.closingTime = '11:30 PM',
    this.weeklyClosingDay = 'Open 7 Days',
  });

  RestaurantProfile copyWith({
    String? name,
    String? tagline,
    String? logoUrl,
    String? coverUrl,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? gstin,
    String? fssai,
    String? description,
    String? openingTime,
    String? closingTime,
    String? weeklyClosingDay,
  }) {
    return RestaurantProfile(
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      gstin: gstin ?? this.gstin,
      fssai: fssai ?? this.fssai,
      description: description ?? this.description,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      weeklyClosingDay: weeklyClosingDay ?? this.weeklyClosingDay,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'tagline': tagline,
        'logoUrl': logoUrl,
        'coverUrl': coverUrl,
        'address': address,
        'phone': phone,
        'email': email,
        'website': website,
        'gstin': gstin,
        'fssai': fssai,
        'description': description,
        'openingTime': openingTime,
        'closingTime': closingTime,
        'weeklyClosingDay': weeklyClosingDay,
      };

  factory RestaurantProfile.fromJson(Map<String, dynamic> json) => RestaurantProfile(
        name: json['name'] as String? ?? 'The Royal Saffron',
        tagline: json['tagline'] as String? ?? 'Fine Dine & Royal Awadhi Cuisine',
        logoUrl: json['logoUrl'] as String? ?? 'assets/images/logo.png',
        coverUrl: json['coverUrl'] as String? ?? 'assets/images/cover.jpg',
        address: json['address'] as String? ?? 'Connaught Place, Central Delhi, New Delhi 110001',
        phone: json['phone'] as String? ?? '+91 98765 43210',
        email: json['email'] as String? ?? 'reservations@royalsaffron.com',
        website: json['website'] as String? ?? 'https://royalsaffron.anabhay.com',
        gstin: json['gstin'] as String? ?? '07AAAAA0000A1Z5',
        fssai: json['fssai'] as String? ?? '10019011006543',
        description: json['description'] as String? ?? '',
        openingTime: json['openingTime'] as String? ?? '11:00 AM',
        closingTime: json['closingTime'] as String? ?? '11:30 PM',
        weeklyClosingDay: json['weeklyClosingDay'] as String? ?? 'Open 7 Days',
      );
}

class TaxBillingConfig {
  final bool isGstEnabled;
  final double taxRatePercent; // 5.0 = 2.5% CGST + 2.5% SGST
  final bool isTaxInclusive;
  final double serviceChargePercent;
  final double defaultDiscountPercent;
  final String roundingPreference; // 'Nearest Rupee', 'Exact'

  const TaxBillingConfig({
    this.isGstEnabled = true,
    this.taxRatePercent = 5.0,
    this.isTaxInclusive = false,
    this.serviceChargePercent = 0.0,
    this.defaultDiscountPercent = 0.0,
    this.roundingPreference = 'Nearest Rupee',
  });

  double get cgstRate => isGstEnabled ? (taxRatePercent / 200.0) : 0.0;
  double get sgstRate => isGstEnabled ? (taxRatePercent / 200.0) : 0.0;

  TaxBillingConfig copyWith({
    bool? isGstEnabled,
    double? taxRatePercent,
    bool? isTaxInclusive,
    double? serviceChargePercent,
    double? defaultDiscountPercent,
    String? roundingPreference,
  }) {
    return TaxBillingConfig(
      isGstEnabled: isGstEnabled ?? this.isGstEnabled,
      taxRatePercent: taxRatePercent ?? this.taxRatePercent,
      isTaxInclusive: isTaxInclusive ?? this.isTaxInclusive,
      serviceChargePercent: serviceChargePercent ?? this.serviceChargePercent,
      defaultDiscountPercent: defaultDiscountPercent ?? this.defaultDiscountPercent,
      roundingPreference: roundingPreference ?? this.roundingPreference,
    );
  }

  Map<String, dynamic> toJson() => {
        'isGstEnabled': isGstEnabled,
        'taxRatePercent': taxRatePercent,
        'isTaxInclusive': isTaxInclusive,
        'serviceChargePercent': serviceChargePercent,
        'defaultDiscountPercent': defaultDiscountPercent,
        'roundingPreference': roundingPreference,
      };

  factory TaxBillingConfig.fromJson(Map<String, dynamic> json) => TaxBillingConfig(
        isGstEnabled: json['isGstEnabled'] as bool? ?? true,
        taxRatePercent: (json['taxRatePercent'] as num?)?.toDouble() ?? 5.0,
        isTaxInclusive: json['isTaxInclusive'] as bool? ?? false,
        serviceChargePercent: (json['serviceChargePercent'] as num?)?.toDouble() ?? 0.0,
        defaultDiscountPercent: (json['defaultDiscountPercent'] as num?)?.toDouble() ?? 0.0,
        roundingPreference: json['roundingPreference'] as String? ?? 'Nearest Rupee',
      );
}

class InvoiceReceiptConfig {
  final bool showLogo;
  final bool showRestaurantName;
  final bool showAddressContact;
  final bool showGstin;
  final bool showFssai;
  final String invoiceTitle;
  final String footerMessage;
  final String thankYouMessage;
  final bool showCustomerDetails;
  final bool showTaxBreakdown;
  final String invoicePrefix;
  final String defaultFormat; // '80mm', 'A4'

  const InvoiceReceiptConfig({
    this.showLogo = true,
    this.showRestaurantName = true,
    this.showAddressContact = true,
    this.showGstin = true,
    this.showFssai = true,
    this.invoiceTitle = 'TAX INVOICE',
    this.footerMessage = 'Prices inclusive of all applicable taxes unless specified.',
    this.thankYouMessage = 'Thank you for dining with The Royal Saffron. Visit again!',
    this.showCustomerDetails = true,
    this.showTaxBreakdown = true,
    this.invoicePrefix = 'INV-2026-',
    this.defaultFormat = '80mm',
  });

  InvoiceReceiptConfig copyWith({
    bool? showLogo,
    bool? showRestaurantName,
    bool? showAddressContact,
    bool? showGstin,
    bool? showFssai,
    String? invoiceTitle,
    String? footerMessage,
    String? thankYouMessage,
    bool? showCustomerDetails,
    bool? showTaxBreakdown,
    String? invoicePrefix,
    String? defaultFormat,
  }) {
    return InvoiceReceiptConfig(
      showLogo: showLogo ?? this.showLogo,
      showRestaurantName: showRestaurantName ?? this.showRestaurantName,
      showAddressContact: showAddressContact ?? this.showAddressContact,
      showGstin: showGstin ?? this.showGstin,
      showFssai: showFssai ?? this.showFssai,
      invoiceTitle: invoiceTitle ?? this.invoiceTitle,
      footerMessage: footerMessage ?? this.footerMessage,
      thankYouMessage: thankYouMessage ?? this.thankYouMessage,
      showCustomerDetails: showCustomerDetails ?? this.showCustomerDetails,
      showTaxBreakdown: showTaxBreakdown ?? this.showTaxBreakdown,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      defaultFormat: defaultFormat ?? this.defaultFormat,
    );
  }

  Map<String, dynamic> toJson() => {
        'showLogo': showLogo,
        'showRestaurantName': showRestaurantName,
        'showAddressContact': showAddressContact,
        'showGstin': showGstin,
        'showFssai': showFssai,
        'invoiceTitle': invoiceTitle,
        'footerMessage': footerMessage,
        'thankYouMessage': thankYouMessage,
        'showCustomerDetails': showCustomerDetails,
        'showTaxBreakdown': showTaxBreakdown,
        'invoicePrefix': invoicePrefix,
        'defaultFormat': defaultFormat,
      };

  factory InvoiceReceiptConfig.fromJson(Map<String, dynamic> json) => InvoiceReceiptConfig(
        showLogo: json['showLogo'] as bool? ?? true,
        showRestaurantName: json['showRestaurantName'] as bool? ?? true,
        showAddressContact: json['showAddressContact'] as bool? ?? true,
        showGstin: json['showGstin'] as bool? ?? true,
        showFssai: json['showFssai'] as bool? ?? true,
        invoiceTitle: json['invoiceTitle'] as String? ?? 'TAX INVOICE',
        footerMessage: json['footerMessage'] as String? ?? 'Prices inclusive of all applicable taxes.',
        thankYouMessage: json['thankYouMessage'] as String? ?? 'Thank you for dining with The Royal Saffron.',
        showCustomerDetails: json['showCustomerDetails'] as bool? ?? true,
        showTaxBreakdown: json['showTaxBreakdown'] as bool? ?? true,
        invoicePrefix: json['invoicePrefix'] as String? ?? 'INV-2026-',
        defaultFormat: json['defaultFormat'] as String? ?? '80mm',
      );
}

class OrderPosConfig {
  final OrderType defaultOrderType;
  final String defaultPaymentMethod;
  final String kotPrefix;
  final String orderPrefix;
  final bool isTakeawayEnabled;
  final bool isDineInEnabled;
  final bool isCustomerQrOrderingEnabled;

  const OrderPosConfig({
    this.defaultOrderType = OrderType.dineIn,
    this.defaultPaymentMethod = 'Demo Cash',
    this.kotPrefix = 'KOT-',
    this.orderPrefix = 'ORD-',
    this.isTakeawayEnabled = true,
    this.isDineInEnabled = true,
    this.isCustomerQrOrderingEnabled = true,
  });

  OrderPosConfig copyWith({
    OrderType? defaultOrderType,
    String? defaultPaymentMethod,
    String? kotPrefix,
    String? orderPrefix,
    bool? isTakeawayEnabled,
    bool? isDineInEnabled,
    bool? isCustomerQrOrderingEnabled,
  }) {
    return OrderPosConfig(
      defaultOrderType: defaultOrderType ?? this.defaultOrderType,
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
      kotPrefix: kotPrefix ?? this.kotPrefix,
      orderPrefix: orderPrefix ?? this.orderPrefix,
      isTakeawayEnabled: isTakeawayEnabled ?? this.isTakeawayEnabled,
      isDineInEnabled: isDineInEnabled ?? this.isDineInEnabled,
      isCustomerQrOrderingEnabled: isCustomerQrOrderingEnabled ?? this.isCustomerQrOrderingEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'defaultOrderType': defaultOrderType.name,
        'defaultPaymentMethod': defaultPaymentMethod,
        'kotPrefix': kotPrefix,
        'orderPrefix': orderPrefix,
        'isTakeawayEnabled': isTakeawayEnabled,
        'isDineInEnabled': isDineInEnabled,
        'isCustomerQrOrderingEnabled': isCustomerQrOrderingEnabled,
      };

  factory OrderPosConfig.fromJson(Map<String, dynamic> json) => OrderPosConfig(
        defaultOrderType: OrderType.fromString(json['defaultOrderType'] as String? ?? 'dineIn'),
        defaultPaymentMethod: json['defaultPaymentMethod'] as String? ?? 'Demo Cash',
        kotPrefix: json['kotPrefix'] as String? ?? 'KOT-',
        orderPrefix: json['orderPrefix'] as String? ?? 'ORD-',
        isTakeawayEnabled: json['isTakeawayEnabled'] as bool? ?? true,
        isDineInEnabled: json['isDineInEnabled'] as bool? ?? true,
        isCustomerQrOrderingEnabled: json['isCustomerQrOrderingEnabled'] as bool? ?? true,
      );
}

class TableQrConfig {
  final String tableNamingFormat; // 'Table {number}'
  final int defaultCapacity;
  final bool isQrMenuEnabled;

  const TableQrConfig({
    this.tableNamingFormat = 'Table {number}',
    this.defaultCapacity = 4,
    this.isQrMenuEnabled = true,
  });

  TableQrConfig copyWith({
    String? tableNamingFormat,
    int? defaultCapacity,
    bool? isQrMenuEnabled,
  }) {
    return TableQrConfig(
      tableNamingFormat: tableNamingFormat ?? this.tableNamingFormat,
      defaultCapacity: defaultCapacity ?? this.defaultCapacity,
      isQrMenuEnabled: isQrMenuEnabled ?? this.isQrMenuEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'tableNamingFormat': tableNamingFormat,
        'defaultCapacity': defaultCapacity,
        'isQrMenuEnabled': isQrMenuEnabled,
      };

  factory TableQrConfig.fromJson(Map<String, dynamic> json) => TableQrConfig(
        tableNamingFormat: json['tableNamingFormat'] as String? ?? 'Table {number}',
        defaultCapacity: json['defaultCapacity'] as int? ?? 4,
        isQrMenuEnabled: json['isQrMenuEnabled'] as bool? ?? true,
      );
}
