import '../../config/constants/AppConstants.dart';
import '../models/drawer_option.dart';

class DrawerOptionList{
    List<DrawerOption> drawer_options = [
    DrawerOption(
        name: AppBarTitle.MANAGE_PRODUCTS,
        isActive: false,
        route: RouteConstants.MANAGE_PRODUCTS),
        DrawerOption(
        name: AppBarTitle.OUT_OF_STOCK,
        isActive: false,
        route: RouteConstants.OUT_OF_STOCK),
  ];
}