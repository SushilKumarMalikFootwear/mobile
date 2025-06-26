class TraderFinance {
  final String traderName;
  final double totalCostPriceBought;
  final double totalCostPriceSold;
  final double totalSellingPrice;
  final int pendingPayment;

  TraderFinance({
    required this.traderName,
    required this.totalCostPriceBought,
    required this.totalCostPriceSold,
    required this.totalSellingPrice,
    required this.pendingPayment
  });

  double get profit => totalSellingPrice - totalCostPriceSold;

  factory TraderFinance.fromJson(Map<String, dynamic> json) {
    return TraderFinance(
      pendingPayment: json['pending_payment'],
      traderName: json['trader_name'],
      totalCostPriceBought: json['total_cost_price'].toDouble(),
      totalCostPriceSold: json['cost_price_of_sold'].toDouble(),
      totalSellingPrice: json['selling_price_of_sold'].toDouble(),
    );
  }
}
