abstract class Constants {
  static int SUCCESS = 1;
  static int FAIL = 2;
  static String HOME = 'HOME';
  static String SHOP = 'SHOP';
  static String EDIT = 'EDIT';
  static String DELETE = 'DELETE';
  static String CREATE = 'CREATE';
  static bool isBackendStarted = false;
  static Map<String, dynamic> basicHeaders = {'Accept': 'application/json'};
  static Map<String, dynamic> mongoDbApiHeaders = {
    'Content-Type': 'application/json',
    'Access-Control-Request-Headers': '*',
    'api-key':
        'MEjxZdBaiBExSkD02TwhrEAkF8UV4neSShPra0CL1QHAIXOQJWgibgkAnbhJAb7i',
  };
}

abstract class ApiUrls {
  static String BASE_URL =
      'https://sushilkumarmalikfootwearbackend.onrender.com';
  static String GET_CONFIG_LISTS = '$BASE_URL/get_config_lists';
  static String ADD_FOOTWEAR = '$BASE_URL/add_footwear';
  static String UPDATE_FOOTWEAR = '$BASE_URL/update_product';
  static String GET_ALL_FOOTWEARS = '$BASE_URL/view_all_footwears';
  static String FILTER_FOOTWEARS = '$BASE_URL/filter_footwears';
  static String mongoDbApiUrl =
      'https://ap-south-1.aws.data.mongodb-api.com/app/data-rtgjs/endpoint/data/v1/action/find';
}

abstract class RouteConstants {
  static String MANAGE_PRODUCTS = '/manage_products';
  static String OUT_OF_STOCK = '/out_of_stock';

}

abstract class AppBarTitle {
  static String MANAGE_PRODUCTS = "Manage Products";
  static String OUT_OF_STOCK = "Out of Sock";
}