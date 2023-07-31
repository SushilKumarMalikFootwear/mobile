//all application routes are placed here
//Routes - Navigation
import 'package:flutter/material.dart';
import '/config/constants/AppConstants.dart';
import '/modules/screens/dashboard.dart';
import '/modules/screens/manage_products.dart';
import '/modules/screens/orders.dart';
import '/modules/screens/register_delivery_boy.dart';

import '../../core/auth/screens/login.dart';
import '../../core/auth/screens/register.dart';

Map<String,WidgetBuilder>getRoutes() {
  return {
    RouteConstants.LOGIN:(context) => const Login(),
    RouteConstants.REGISTER:(context) => const Register(),
    RouteConstants.DASHBOARD:(context) =>  Dashboard(),
    RouteConstants.MANAGE_PRODUCTS:(context) => manageProducts(),
    RouteConstants.ORDERS:(context) => Orders(),
    RouteConstants.REGISTER_DELIVERY_BOY:(context) => RegisterDeliveryBoy()
  };
}