import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '/modules/screens/manage_products.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    RouteConstants.manageProducts: (context) => const ManageProducts(),
  };
}
