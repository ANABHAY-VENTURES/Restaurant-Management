// Anabhay Ventures — Application Multi-Language Localization System
// Phase 7: Complete Localization in English (en), Hindi (hi), and Bengali (bn)

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Restaurant Management',
      'dashboard': 'Dashboard',
      'posBilling': 'POS Billing',
      'kitchenKds': 'Orders & KOT',
      'tables': 'Tables',
      'tableQrs': 'Table QRs',
      'menu': 'Menu',
      'inventory': 'Inventory',
      'purchases': 'Purchases',
      'staff': 'Staff',
      'customers': 'Customers',
      'reports': 'Reports',
      'settings': 'Settings',
      // Actions
      'save': 'Save',
      'cancel': 'Cancel',
      'edit': 'Edit',
      'delete': 'Delete',
      'add': 'Add',
      'search': 'Search...',
      'print': 'Print',
      'export': 'Export',
      // Billing
      'subtotal': 'Subtotal',
      'grandTotal': 'Grand Total',
      'tax': 'Taxes (GST)',
      'discount': 'Discount',
      'cash': 'Cash',
      'upi': 'UPI Payment',
      'card': 'Card',
      // Settings
      'restaurantProfile': 'Restaurant Profile',
      'taxBilling': 'Tax & Billing',
      'invoiceReceipt': 'Invoice & Receipts',
      'orderPos': 'Order & POS',
      'tableQr': 'Tables & QR',
      'appearance': 'Appearance & Theme',
      'language': 'Language',
      'backupData': 'Backup & Data Management',
      'about': 'About Application',
    },
    'hi': {
      'appTitle': 'रेस्तरां प्रबंधन',
      'dashboard': 'डैशबोर्ड',
      'posBilling': 'पीओएस बिलिंग',
      'kitchenKds': 'रसोई केओटी',
      'tables': 'टेबल प्रबंधन',
      'tableQrs': 'टेबल क्यूआर',
      'menu': 'व्यंजन सूची (मेनू)',
      'inventory': 'इन्वेंटरी व स्टॉक',
      'purchases': 'खरीद (सप्लायर)',
      'staff': 'कर्मचारी प्रबंधन',
      'customers': 'ग्राहक व रॉयल्टी',
      'reports': 'वित्तीय रिपोर्ट',
      'settings': 'सेटिंग्स',
      // Actions
      'save': 'सहेजें (Save)',
      'cancel': 'रद्द करें',
      'edit': 'संपादित करें',
      'delete': 'हटाएं',
      'add': 'जोड़ें',
      'search': 'खोजें...',
      'print': 'प्रिंट करें',
      'export': 'निर्यात (Export)',
      // Billing
      'subtotal': 'उप-योग (Subtotal)',
      'grandTotal': 'कुल योग (Grand Total)',
      'tax': 'कर (जीएसटी)',
      'discount': 'छूट (Discount)',
      'cash': 'नकद (Cash)',
      'upi': 'यूपीआई भुगतान',
      'card': 'कार्ड भुगतान',
      // Settings
      'restaurantProfile': 'रेस्तरां प्रोफ़ाइल',
      'taxBilling': 'कर और बिलिंग',
      'invoiceReceipt': 'चालान और रसीदें',
      'orderPos': 'ऑर्डर और पीओएस',
      'tableQr': 'टेबल और क्यूआर',
      'appearance': 'थीम और दिखावट',
      'language': 'भाषा (Language)',
      'backupData': 'बैकअप और डेटा',
      'about': 'ऐप के बारे में',
    },
    'bn': {
      'appTitle': 'রেস্তোরাঁ ম্যানেজমেন্ট',
      'dashboard': 'ড্যাশবোর্ড',
      'posBilling': 'পিওএস বিলিং',
      'kitchenKds': 'কিচেন কেওটি',
      'tables': 'টেবিল ব্যবস্থাপনা',
      'tableQrs': 'টেবিল কিউআর',
      'menu': 'মেনু ও খাদ্যতালিকা',
      'inventory': 'ইনভেন্টরি ও কাঁচামাল',
      'purchases': 'ক্রয় ও সরবরাহকারী',
      'staff': 'কর্মচারী ব্যবস্থাপনা',
      'customers': 'গ্রাহক ও লয়্যালটি',
      'reports': 'আর্থিক রিপোর্ট',
      'settings': 'সেটিংস',
      // Actions
      'save': 'সংরক্ষণ করুন',
      'cancel': 'বাতিল করুন',
      'edit': 'সম্পাদনা করুন',
      'delete': 'মুছে ফেলুন',
      'add': 'যোগ করুন',
      'search': 'অনুসন্ধান করুন...',
      'print': 'প্রিন্ট করুন',
      'export': 'রপ্তানি করুন',
      // Billing
      'subtotal': 'সাবটোটাল',
      'grandTotal': 'সর্বমোট মূল্য',
      'tax': 'কর (জিএসটি)',
      'discount': 'ছাড় (Discount)',
      'cash': 'নগদ ক্যাশ',
      'upi': 'ইউপিআই পেমেন্ট',
      'card': 'কার্ড পেমেন্ট',
      // Settings
      'restaurantProfile': 'রেস্তোরাঁর প্রোফাইল',
      'taxBilling': 'ট্যাক্স ও বিলিং সেটিংস',
      'invoiceReceipt': 'চালান ও রসিদ কাস্টমাইজেশন',
      'orderPos': 'অর্ডার ও পিওএস কনফিগ',
      'tableQr': 'টেবিল ও কিউআর কোড',
      'appearance': 'থিম ও রূপরেখা',
      'language': 'ভাষা (Language)',
      'backupData': 'ব্যাকআপ ও তথ্য সংরক্ষণ',
      'about': 'অ্যাপ সম্পর্কিত তথ্য',
    },
  };

  String get(String key) {
    final lang = locale.languageCode;
    return _localizedValues[lang]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
