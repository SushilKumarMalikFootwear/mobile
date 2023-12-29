import 'package:flutter/material.dart';
import 'package:footwear/modules/screens/out_of_stock_products.dart';
import '/config/constants/AppConstants.dart';
import '/modules/screens/manage_products.dart';

Map<String,WidgetBuilder>getRoutes() {
  return {
    RouteConstants.MANAGE_PRODUCTS:(context) => manageProducts(),
    RouteConstants.OUT_OF_STOCK:(context) => OutOfStockProducts()
  };
}