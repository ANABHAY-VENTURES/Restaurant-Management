// Anabhay Ventures — Reports & Analytics Domain Models
// Phase 6: Financial Overview, Sales Trends, Product Performance, Payment & Tender Analytics

enum ReportDateRange {
  today('Today'),
  yesterday('Yesterday'),
  last7Days('Last 7 Days'),
  last30Days('Last 30 Days'),
  thisMonth('This Month'),
  custom('Custom Range');

  final String label;
  const ReportDateRange(this.label);
}

class SalesSummary {
  final double grossSales;
  final double totalDiscounts;
  final double cgstCollected;
  final double sgstCollected;
  final double netSales;
  final int paidOrdersCount;
  final int unpaidOrdersCount;
  final int cancelledOrdersCount;
  final double averageOrderValue;
  final double estimatedFoodCost;
  final double estimatedGrossProfit;

  const SalesSummary({
    required this.grossSales,
    required this.totalDiscounts,
    required this.cgstCollected,
    required this.sgstCollected,
    required this.netSales,
    required this.paidOrdersCount,
    required this.unpaidOrdersCount,
    required this.cancelledOrdersCount,
    required this.averageOrderValue,
    required this.estimatedFoodCost,
    required this.estimatedGrossProfit,
  });

  double get grossProfitMarginPercent => netSales > 0 ? (estimatedGrossProfit / netSales) * 100 : 0.0;
  double get foodCostPercent => netSales > 0 ? (estimatedFoodCost / netSales) * 100 : 0.0;
}

class ProductSalesMetric {
  final String menuItemId;
  final String itemName;
  final String category;
  final int quantitySold;
  final double totalRevenue;
  final double unitFoodCost;
  final double totalFoodCost;

  const ProductSalesMetric({
    required this.menuItemId,
    required this.itemName,
    required this.category,
    required this.quantitySold,
    required this.totalRevenue,
    this.unitFoodCost = 0.0,
    this.totalFoodCost = 0.0,
  });

  double get grossProfit => totalRevenue - totalFoodCost;
  double get profitMargin => totalRevenue > 0 ? (grossProfit / totalRevenue) * 100 : 0.0;
}

class PaymentBreakdown {
  final double cashTotal;
  final int cashCount;
  final double upiTotal;
  final int upiCount;
  final double cardTotal;
  final int cardCount;

  const PaymentBreakdown({
    this.cashTotal = 0.0,
    this.cashCount = 0,
    this.upiTotal = 0.0,
    this.upiCount = 0,
    this.cardTotal = 0.0,
    this.cardCount = 0,
  });

  double get totalCollected => cashTotal + upiTotal + cardTotal;
  int get totalTransactions => cashCount + upiCount + cardCount;
}
