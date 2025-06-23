import 'package:flutter/material.dart';
import 'package:footwear/modules/screens/trader_finances.dart';
import 'package:footwear/modules/screens/trader_finances_logs.dart';
import '../../modules/screens/Invoices.dart';
import '../../modules/screens/monthly_sales.dart';
import '../../modules/screens/sales_report.dart';
import '../constants/app_constants.dart';
import '/modules/screens/manage_products.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    RouteConstants.manageProducts: (context) => const ManageProducts(),
    RouteConstants.invoices: (context) => const Invoices(),
    RouteConstants.traderFinances: (context) => TraderFinanceScreen(),
    RouteConstants.salesReport: (context) => const SalesReport(),
    RouteConstants.monthlySales: (context) => MonthlySalesScreen(),
    RouteConstants.traderFinancesLogs: (context) => TraderFinancesLogs()
  };
}
