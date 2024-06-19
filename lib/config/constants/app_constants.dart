import 'package:footwear/modules/models/product.dart';

abstract class Constants {
  static String home = 'HOME';
  static String shop = 'SHOP';
  static String cash = 'CASH';
  static String upi = 'UPI';
  static String pending = 'PENDING';
  static String paid = 'PAID';
  static String edit = 'EDIT';
  static String completed = 'COMPLETED';
  static String returned = 'RETURNED';
  static String delete = 'DELETE';
  static String create = 'CREATE';
  static bool isBackendStarted = false;
  static Map<String, dynamic> basicHeaders = {'Accept': 'application/json'};
  static Map<String, String> mongoDbHeaders = {
    'Content-Type': 'application/json',
    'Access-Control-Request-Headers': '*',
    'api-key':
        'qNt2VxYXcnCBIL2txrJq1aTPoXlzCKG4kFCOBCdOvODzQxV0W106vBQNlf5trY3i',
    'Accept': 'application/json'
  };
  static List<String> articleList = [];
  static List<String> vendorList = [];
  static List<String> categoryList = [];
  static List<String> articleWithColorList = [];
  static Map<String,Product> articleWithColorToProduct= {};
}

abstract class ApiUrls {
  static String baseUrl =
      'https://sushilkumarmalikfootwearbackend.onrender.com';
  static String getConfigList = '$baseUrl/get_config_lists';
  static String addFootwear = '$baseUrl/add_footwear';
  static String updateFootwear = '$baseUrl/update_product';
  static String saveInvoice = '$baseUrl/saveInvoice';
  static String mongoDbApiUrl =
      'https://ap-south-1.aws.data.mongodb-api.com/app/data-rtgjs/endpoint/data/v1/action';
}

abstract class RouteConstants {
  static String manageProducts = '/manage_products';
  static String invoices = '/invoices';
}

abstract class AppBarTitle {
  static String manageProducts = "Manage Products";
  static String invoices = "Invoices";
}