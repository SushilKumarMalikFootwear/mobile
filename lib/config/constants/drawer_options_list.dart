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
  ];
}
