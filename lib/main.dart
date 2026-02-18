import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/constants/app_constants.dart';
import '/config/routes/routes.dart';
import 'modules/models/product.dart';
import 'modules/repository/product_repo.dart';

void main() async { 
  await dotenv.load(fileName: ".env");
  Dio dio = Dio();
  dio.get(ApiUrls.getConfigList).then((value) {
    Constants.isBackendStarted = true;
  });
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ProductRepository productRepo = ProductRepository();
  Map<String, List<String>> configList = await productRepo.getConfigLists();
  Constants.categoryList = configList['categoryList']!;
  Constants.vendorList = configList['vendorList']!;
  Constants.articleList = await productRepo.getAllArticles();
  Future getAllProducts = productRepo.getAllProducts();
  getAllProducts.then((value) {
    List temp = value['footwears'];
    temp.map((e) {
      Product product = Product.fromJSON(e);
      String articleWithColor = "${product.article} : ${product.color}";
      Constants.articleWithColorList.add(articleWithColor);
      Constants.articleWithColorToProduct.putIfAbsent(
        articleWithColor,
        () => product,
      );
    }).toList();
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: RouteConstants.manageProducts,
      routes: getRoutes(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
              TextStyle(color: Colors.white),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}
