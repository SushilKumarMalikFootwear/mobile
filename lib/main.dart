import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'config/constants/app_constants.dart';
import '/config/routes/routes.dart';

void main() async {
  Dio dio = Dio();
  dio.get(ApiUrls.getConfigList).then((value) {
    Constants.isBackendStarted = true;
  });
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: RouteConstants.manageProducts,
    routes: getRoutes(),
  ));
}
