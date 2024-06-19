import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:footwear/utils/services/api_client.dart';
import '../../config/constants/app_constants.dart';

class ProductRepository {
  Future<Map<String, List<String>>> getConfigLists() async {
    Map<String, dynamic> temp = {};
    if (Constants.isBackendStarted) {
      temp = await ApiClient.get(ApiUrls.getConfigList);
    } else {
      temp = await ApiClient.post("${ApiUrls.mongoDbApiUrl}/find", {
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
    var response = await ApiClient.post(ApiUrls.addFootwear, product);
    return response;
  }

  update(Map<String, dynamic> product) async {
    var response = await ApiClient.post(ApiUrls.updateFootwear, product);
    return response;
  }

  getAllProducts() async {
    var response = await ApiClient.post(
        "${ApiUrls.mongoDbApiUrl}/find",
        {
          "collection": "footwears",
          "database": "test",
          "dataSource": "SushilKumarMalikFootwear",
          "sort": {"createdAt": -1}
        },
        headers: Constants.mongoDbHeaders);
    return response;
  }

  filterProducts(Map<String, String> filterMap) async {
    String brand = filterMap['brand'] ?? '';
    String category = filterMap['category'] ?? '';
    String article = filterMap['article'] ?? '';
    String sizeRange = filterMap['size_range'] ?? '';
    String color = filterMap['color'] ?? '';
    String vendor = filterMap['vendor'] ?? '';
    bool outOfStock = filterMap['out_of_stock'] != null
        ? filterMap['out_of_stock'] == 'true'
        : false;
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
        if (sizeRange.isNotEmpty)
          {
            "\$match": {
              "size_range": {"\$regex": sizeRange, "\$options": "i"}
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
        {
          "\$match": {"out_of_stock": outOfStock}
        },
        {
          "\$sort": {"createdAt": -1}
        }
      ]
    });
    var dio = Dio();
    var response = await dio.request(
      "${ApiUrls.mongoDbApiUrl}/aggregate",
      options: Options(
        method: 'POST',
        headers: Constants.mongoDbHeaders,
      ),
      data: data,
    );
    return response.data;
  }

  getAllArticles() async {
    var data = json.encode({
      "collection": "footwears",
      "database": "test",
      "dataSource": "SushilKumarMalikFootwear",
      "pipeline": [
        {
          "\$group": {
            "_id": null,
            "uniqueArticles": {"\$addToSet": "\$article"}
          }
        },
        {
          "\$project": {"_id": 0, "uniqueArticles": 1}
        }
      ]
    });

    var dio = Dio();
    var response = await dio.request(
      "${ApiUrls.mongoDbApiUrl}/aggregate",
      options: Options(
        method: 'POST',
        headers: Constants.mongoDbHeaders,
      ),
      data: data,
    );
    List temp = response.data['documents'][0]['uniqueArticles'];
    List<String> articleList = temp.map((e) => e.toString()).toList();
    return articleList;
  }

}
