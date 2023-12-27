import 'package:flutter/material.dart';
import '/config/constants/AppConstants.dart';
import '/modules/screens/manage_products.dart';

Map<String,WidgetBuilder>getRoutes() {
  return {
    RouteConstants.MANAGE_PRODUCTS:(context) => manageProducts(),
  };
}