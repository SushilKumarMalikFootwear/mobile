import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '/config/constants/AppConstants.dart';
import '/config/routes/routes.dart';
import 'config/themes/Theme.dart';

void main() async {
  Dio _dio = Dio();
  _dio.get(ApiUrls.GET_CONFIG_LISTS).then((value) {
    Constants.isBackendStarted = true;
  });
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: getTheme(),
    // home: Login(), //once initial route defined no need to mention home
    initialRoute: RouteConstants.MANAGE_PRODUCTS, //inital or base route
    routes: getRoutes(), //all routes are loaded here
  ));
}
