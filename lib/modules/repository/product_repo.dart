import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:footwear/utils/services/ApiClient.dart';
import '/config/constants/AppConstants.dart';


class ProductRepository {
  Future<Map<String, List<String>>> getConfigLists() async {
    Map<String, dynamic> temp = {};
    if (Constants.isBackendStarted) {
      temp = await ApiClient.get(ApiUrls.GET_CONFIG_LISTS);
    } else {
      temp = await ApiClient.post(ApiUrls.mongoDbApiUrl, {
        "collection": "config_lists",
        "database": "test",
        "dataSource": "SushilKumarMalikFootwear"
      });
      temp = temp['documents'][0];
    }
    List list = temp['sizeRangeList'];
    List<String> sizeRangeList = list.map((e) => e.toString()).toList();
    list = temp['categoryList'];
    List<String> categoryList = list.map((e) => e.toString()).toList();
    list = temp['vendorList'];
    List<String> vendorList = list.map((e) => e.toString()).toList();
    Map<String, List<String>> configLists = {
      'sizeRangeList': sizeRangeList,
      'categoryList': categoryList,
      'vendorList': vendorList
    };
    return configLists;
  }

  FirebaseFirestore db = FirebaseFirestore.instance;
  add(Map<String, dynamic> product) async {
    var response = await ApiClient.post(ApiUrls.ADD_FOOTWEAR, product);
    return response;
  }

  update(Map<String, dynamic> product) async {
    var response = await ApiClient.post(ApiUrls.UPDATE_FOOTWEAR, product);
    return response;
  }

  getAllProducts(bool outOfStock) async {
    var response = await ApiClient.post(
        "https://ap-south-1.aws.data.mongodb-api.com/app/data-rtgjs/endpoint/data/v1/action/find",
        {
          "collection": "footwears",
          "database": "test",
          "dataSource": "SushilKumarMalikFootwear",
          "filter":{"out_of_stock":outOfStock},
          "sort": {"createdAt": -1}
        },
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Request-Headers': '*',
          'api-key':
              'qNt2VxYXcnCBIL2txrJq1aTPoXlzCKG4kFCOBCdOvODzQxV0W106vBQNlf5trY3i',
          'Accept': 'application/json'
        });
    return response;
  }

  filterProducts(Map<String, String> filterMap, bool outOfStock) async {
    String brand = filterMap['brand']!;
    String category = filterMap['category']!;
    String article = filterMap['article']!;
    String size_range = filterMap['size_range']!;
    String color = filterMap['color']!;
    String vendor = filterMap['vendor']!;
    var headers = {
      'Content-Type': 'application/json',
      'Access-Control-Request-Headers': '*',
      'api-key':
          'qNt2VxYXcnCBIL2txrJq1aTPoXlzCKG4kFCOBCdOvODzQxV0W106vBQNlf5trY3i',
      'Accept': 'application/json'
    };
    var data = json.encode({
      "collection": "footwears",
      "database": "test",
      "dataSource": "SushilKumarMalikFootwear",
      "pipeline": [
        if (outOfStock)
          {
            "\$match": {"out_of_stock": true}
          },
        if (brand.isNotEmpty)
          {
            "\$match": {
              "brand": {"\$regex": brand, "\$options": "i"}
            }
          },
        if (category.isNotEmpty)
          {
            "\$match": {
              "category": {"\$regex": category, "\$options": "i"}
            }
          },
        if (article.isNotEmpty)
          {
            "\$match": {
              "article": {"\$regex": article, "\$options": "i"}
            }
          },
        if (size_range.isNotEmpty)
          {
            "\$match": {
              "size_range": {"\$regex": size_range, "\$options": "i"}
            }
          },
        if (color.isNotEmpty)
          {
            "\$match": {
              "color": {"\$regex": color, "\$options": "i"}
            }
          },
        if (vendor.isNotEmpty)
          {
            "\$match": {
              "vendor": {"\$regex": vendor, "\$options": "i"}
            }
          },
        if (!outOfStock)
          {
            "\$match": {"out_of_stock": false}
          },
        {
          "\$sort": {"createdAt": -1}
        }
      ]
    });
    var dio = Dio();
    var response = await dio.request(
      'https://ap-south-1.aws.data.mongodb-api.com/app/data-rtgjs/endpoint/data/v1/action/aggregate',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
    } else {
      print(response.statusMessage);
    }
    return response.data;
  }
}
