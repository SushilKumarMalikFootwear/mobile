import 'app_constants.dart';
import '../../modules/models/drawer_option.dart';

class DrawerOptionList {
  List<DrawerOption> drawerOptions = [
    DrawerOption(
        name: AppBarTitle.manageProducts,
        isActive: false,
        route: RouteConstants.manageProducts),
  ];
}
