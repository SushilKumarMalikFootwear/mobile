import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:footwear/utils/services/api_client.dart';
import '../../config/constants/app_constants.dart';
import '../models/product.dart';

class ProductRepository {
  Future<Map<String, List<String>>> getConfigLists() async {
    Map<String, dynamic> temp = {};
    temp = await ApiClient.get(ApiUrls.getConfigList);
    List list = temp['categoryList'];
    List<String> categoryList = list.map((e) => e.toString()).toList();
    list = temp['vendorList'];
    List<String> vendorList = list.map((e) => e.toString()).toList();
    Map<String, List<String>> configLists = {
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
    var response = await ApiClient.get("${ApiUrls.baseUrl}/view_all_footwears");
    return response;
  }

  filterProducts(Map<String, String> filterMap) async {
    var response  = await ApiClient.post("${ApiUrls.baseUrl}/filter_footwears", filterMap);
    // String brand = filterMap['brand'] ?? '';
    // String category = filterMap['category'] ?? '';
    // String article = filterMap['article'] ?? '';
    // String sizeRange = filterMap['size_range'] ?? '';
    // String color = filterMap['color'] ?? '';
    // String vendor = filterMap['vendor'] ?? '';
    // String label = filterMap['label'] ?? '';
    // bool outOfStock = filterMap['out_of_stock'] != null
    //     ? filterMap['out_of_stock'] == 'true'
    //     : false;
    // bool notUpdated = filterMap['notUpdated'] != null
    //     ? filterMap['notUpdated'] == 'true'
    //     : false;
    // double? ratingMoreThan = filterMap['rating_more_than'] != null
    //     ? double.tryParse(filterMap['rating_more_than']!)
    //     : null;
    // double? ratingLessThan = filterMap['rating_less_than'] != null
    //     ? double.tryParse(filterMap['rating_less_than']!)
    //     : null;

    // var data = json.encode({
    //   "collection": "footwears",
    //   "database": "test",
    //   "dataSource": "SushilKumarMalikFootwear",
    //   "pipeline": [
    //     if (brand.isNotEmpty)
    //       {
    //         "\$match": {
    //           "brand": {"\$regex": brand, "\$options": "i"}
    //         }
    //       },
    //     if (label.isNotEmpty)
    //       {
    //         "\$match": {"label": label}
    //       },
    //     if (category.isNotEmpty)
    //       {
    //         "\$match": {
    //           "category": {"\$regex": category, "\$options": "i"}
    //         }
    //       },
    //     if (article.isNotEmpty)
    //       {
    //         "\$match": {
    //           "article": {"\$regex": article, "\$options": "i"}
    //         }
    //       },
    //     if (sizeRange.isNotEmpty)
    //       {
    //         "\$match": {
    //           "size_range": {"\$regex": sizeRange, "\$options": "i"}
    //         }
    //       },
    //     if (color.isNotEmpty)
    //       {
    //         "\$match": {
    //           "color": {"\$regex": color, "\$options": "i"}
    //         }
    //       },
    //     if (vendor.isNotEmpty)
    //       {
    //         "\$match": {
    //           "vendor": {"\$regex": vendor, "\$options": "i"}
    //         }
    //       },
    //     {
    //       "\$match": {"out_of_stock": outOfStock}
    //     },
    //     if (notUpdated)
    //       {
    //         "\$match": {"updated": !notUpdated}
    //       },
    //     if (ratingMoreThan != null)
    //       {
    //         "\$match": {
    //           "rating": {"\$gte": ratingMoreThan}
    //         }
    //       },
    //     if (ratingLessThan != null)
    //       {
    //         "\$match": {
    //           "rating": {"\$lte": ratingLessThan}
    //         }
    //       },
    //     {
    //       "\$sort": {"createdAt": -1}
    //     }
    //   ]
    // });
    // var dio = Dio();
    // var response = await dio.request(
    //   "${ApiUrls.mongoDbApiUrl}/aggregate",
    //   options: Options(
    //     method: 'POST',
    //     headers: Constants.mongoDbHeaders,
    //   ),
    //   data: data,
    // );
    return response['footwears'];
  }

  Future<Product?> getProductById(String footwearId) async {
    var dio = Dio();
    var response = await dio
        .get("${ApiUrls.baseUrl}/view_by_footwear_id?footwear_id=$footwearId");
    if (response.data['footwear'] != null) {
      return Product.fromJSON(response.data['footwear'][0]);
    } else {
      return null;
    }
  }

  Future<List<String>> getAllArticles() async {
    var dio = Dio();
    var response = await dio.get("${ApiUrls.baseUrl}/get_all_articles");
    List temp = response.data['articles'][0]['uniqueArticles'];
    List<String> articleList = temp.map((e) => e.toString()).toList();
    return articleList;
  }

  Future<List<String>> getAllLables() async {
    var dio = Dio();
    var response = await dio.get("${ApiUrls.baseUrl}/get_all_labels");
    List temp = response.data['labels'][0]['uniqueLables'];
    Set<String> labelList = {};
    for (List item in temp) {
      for (String e in item) {
        labelList.add(e.toString());
      }
    }
    return labelList.toList();
  }
}
