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
  static Map<String, Product> articleWithColorToProduct = {};
  static List<String> allSizeList = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45'
  ];
  static bool isOldInvoice = false;
  static String soldAt = 'HOME';
  static DateTime invoiceDate = DateTime.now();
}

abstract class ApiUrls {
  static String baseUrl =
      'https://sushilkumarmalikfootwearbackend.onrender.com';
  static String getConfigList = '$baseUrl/get_config_lists';
  static String addFootwear = '$baseUrl/add_footwear';
  static String updateFootwear = '$baseUrl/update_product';
  static String saveInvoice = '$baseUrl/saveInvoice';
  static String updateInvoice = '$baseUrl/updateInvoice';
  static String mongoDbApiUrl =
      'https://ap-south-1.aws.data.mongodb-api.com/app/data-rtgjs/endpoint/data/v1/action';
}

abstract class RouteConstants {
  static String manageProducts = '/manage_products';
  static String invoices = '/invoices';
  static String traderFinances = '/trader_finances';
  static String salesReport = '/sales_report';
}

abstract class AppBarTitle {
  static String manageProducts = "Manage Products";
  static String invoices = "Invoices";
  static String traderFinances = "Trader Finances";
  static String salesReport = "Sales Report";
}
