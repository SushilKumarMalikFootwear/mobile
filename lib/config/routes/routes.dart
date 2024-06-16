import 'package:flutter/material.dart';
import '../../modules/screens/Invoices.dart';
import '../constants/app_constants.dart';
import '/modules/screens/manage_products.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    RouteConstants.manageProducts: (context) => const ManageProducts(),
    RouteConstants.invoices : (context)=> const Invoices()
  };
}
