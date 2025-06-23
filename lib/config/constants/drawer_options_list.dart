import 'app_constants.dart';
import '../../modules/models/drawer_option.dart';

class DrawerOptionList {
  List<DrawerOption> drawerOptions = [
    DrawerOption(
        name: AppBarTitle.manageProducts,
        isActive: false,
        route: RouteConstants.manageProducts),
    DrawerOption(
        name: AppBarTitle.invoices,
        isActive: false,
        route: RouteConstants.invoices),
    DrawerOption(
        name: AppBarTitle.traderFinances,
        isActive: false,
        route: RouteConstants.traderFinances),
    DrawerOption(
        name: AppBarTitle.salesReport,
        isActive: false,
        route: RouteConstants.salesReport),
    DrawerOption(
        name: AppBarTitle.monthlySales,
        isActive: false,
        route: RouteConstants.monthlySales),
    DrawerOption(
        name: AppBarTitle.traderFinancesLogs,
        isActive: false,
        route: RouteConstants.traderFinancesLogs),
  ];
}
