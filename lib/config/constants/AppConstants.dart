abstract class Constants {
  static String LOGIN_IMAGE =
      'https://media.mktg.workday.com/is/image/workday/illustration-people-login?fmt=png-alpha&wid=1000';
  static String REGISTRATION_IMAGE =
      'https://www.allen.ac.in/apps2223/assets/images/reset-password.jpg';
  static String appId = 'A111';
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
  static String DASHBOARD = "Dashboard";
  static String ORDERS = "Orders";
  static String MANAGE_PRODUCTS = "Manage Products";
  static String OUT_OF_STOCK = "Out of Sock";
  static String REGISTER_DELIVERY_BOY = "Register Delivery Boy";
}

abstract class Messages {
  static String ERROR = "Some error has occured...";
}

abstract class Collections {
  static String PRODUCTS = 'products';
  static String USERS = 'users';
}

abstract class OrderStatus {
  static String ALL = "ALL";
  static String PENDING = "PENDING";
  static String CANCELLED = "CANCELLED";
  static String DELIVERED = "DELIVERED";
}
