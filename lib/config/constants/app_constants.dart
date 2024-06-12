abstract class Constants {
  static String home = 'HOME';
  static String shop = 'SHOP';
  static String edit = 'EDIT';
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
}

abstract class ApiUrls {
  static String baseUrl =
      'https://sushilkumarmalikfootwearbackend.onrender.com';
  static String getConfigList = '$baseUrl/get_config_lists';
  static String addFootwear = '$baseUrl/add_footwear';
  static String updateFootwear = '$baseUrl/update_product';
  static String mongoDbApiUrl =
      'https://ap-south-1.aws.data.mongodb-api.com/app/data-rtgjs/endpoint/data/v1/action';
}

abstract class RouteConstants {
  static String manageProducts = '/manage_products';
  static String outOfProducts = '/out_of_stock';
}

abstract class AppBarTitle {
  static String manageProducts = "Manage Products";
  static String outOfProducts = "Out of Sock";
}
