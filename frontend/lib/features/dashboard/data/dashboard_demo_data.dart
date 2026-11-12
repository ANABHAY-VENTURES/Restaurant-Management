// Anabhay Ventures — Dashboard Demo Data
// DEMO DATA: Labelled clearly. Will be replaced by real backend APIs.

class DashboardDemoData {
  DashboardDemoData._();

  static const String restaurantName = 'The Royal Saffron Fine Dining';
  static const String branchName = 'Park Street Flagship';

  static const Map<String, Map<String, dynamic>> metrics = {
    'today_sales': {
      'title': "Today's Sales",
      'value': '₹1,84,650',
      'change': '+18.4%',
      'trend': 'up',
      'description': 'vs. same day last week',
    },
    'total_orders': {
      'title': 'Total Orders',
      'value': '214',
      'change': '+12.2%',
      'trend': 'up',
      'description': 'Dine-in: 168 | Takeaway: 46',
    },
    'active_tables': {
      'title': 'Active Tables',
      'value': '22 / 28',
      'change': '78.5%',
      'trend': 'neutral',
      'description': 'Current occupancy',
    },
    'kitchen_queue': {
      'title': 'Kitchen Queue',
      'value': '8',
      'change': 'Avg 14 min',
      'trend': 'up',
      'description': '3 Preparing | 5 In Queue',
    },
    'avg_order': {
      'title': 'Avg Order Value',
      'value': '₹862',
      'change': '+6.5%',
      'trend': 'up',
      'description': 'Per table ticket',
    },
  };

  static const List<Map<String, dynamic>> hourlySales = [
    {'time': '11 AM', 'sales': 4200.0, 'orders': 6},
    {'time': '12 PM', 'sales': 14800.0, 'orders': 18},
    {'time': '1 PM', 'sales': 31200.0, 'orders': 36},
    {'time': '2 PM', 'sales': 28400.0, 'orders': 32},
    {'time': '3 PM', 'sales': 9600.0, 'orders': 12},
    {'time': '4 PM', 'sales': 6200.0, 'orders': 8},
    {'time': '5 PM', 'sales': 8400.0, 'orders': 11},
    {'time': '6 PM', 'sales': 18500.0, 'orders': 21},
    {'time': '7 PM', 'sales': 27600.0, 'orders': 31},
    {'time': '8 PM', 'sales': 35750.0, 'orders': 40},
  ];

  static const List<Map<String, dynamic>> bestSellers = [
    {'name': 'Saffron Dum Biryani', 'category': 'Main Course', 'qty': 48, 'revenue': 25920.0, 'inStock': true},
    {'name': 'Butter Garlic Naan', 'category': 'Breads', 'qty': 112, 'revenue': 12320.0, 'inStock': true},
    {'name': 'Murgh Malai Tikka', 'category': 'Starters', 'qty': 38, 'revenue': 17480.0, 'inStock': true},
    {'name': 'Dal Makhani Reserve', 'category': 'Main Course', 'qty': 42, 'revenue': 15960.0, 'inStock': true},
    {'name': 'Gulab Jamun Flambé', 'category': 'Desserts', 'qty': 35, 'revenue': 7700.0, 'inStock': false},
  ];

  static const List<Map<String, dynamic>> kitchenQueue = [
    {
      'kot': 'KOT-104', 'table': 'T-04', 'items': 3,
      'status': 'preparing', 'elapsed': 11,
      'itemList': ['2× Saffron Dum Biryani', '1× Burani Raita'],
    },
    {
      'kot': 'KOT-105', 'table': 'T-12', 'items': 4,
      'status': 'preparing', 'elapsed': 8,
      'itemList': ['1× Murgh Malai Tikka', '2× Butter Naan', '1× Paneer Tikka'],
    },
    {
      'kot': 'KOT-106', 'table': 'T-08', 'items': 2,
      'status': 'pending', 'elapsed': 4,
      'itemList': ['1× Dal Makhani Reserve', '2× Garlic Naan'],
    },
    {
      'kot': 'KOT-107', 'table': 'TW-03', 'items': 5,
      'status': 'pending', 'elapsed': 2,
      'itemList': ['3× Chicken Tikka Roll', '2× Fresh Lime Soda'],
    },
  ];

  static const List<Map<String, dynamic>> recentTransactions = [
    {'invoice': 'INV-2026-0891', 'table': 'T-03', 'amount': 2450.0, 'method': 'UPI', 'time': '10 mins ago'},
    {'invoice': 'INV-2026-0890', 'table': 'T-14', 'amount': 4180.0, 'method': 'Card', 'time': '24 mins ago'},
    {'invoice': 'INV-2026-0889', 'table': 'TW-02', 'amount': 890.0, 'method': 'UPI', 'time': '32 mins ago'},
    {'invoice': 'INV-2026-0888', 'table': 'T-07', 'amount': 3620.0, 'method': 'Cash', 'time': '45 mins ago'},
    {'invoice': 'INV-2026-0887', 'table': 'T-19', 'amount': 5240.0, 'method': 'Card', 'time': '1 hr ago'},
  ];
}

