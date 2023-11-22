import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:footwear/utils/services/ApiClient.dart';
import '/config/constants/AppConstants.dart';

import '../models/product.dart';

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
    Map<String, List<String>> configLists = {
      'sizeRangeList': sizeRangeList,
      'categoryList': categoryList
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

  getAllProducts() async {
    var response = await ApiClient.post(
        "https://ap-south-1.aws.data.mongodb-api.com/app/data-rtgjs/endpoint/data/v1/action/find",
        {
          "collection": "footwears",
          "database": "test",
          "dataSource": "SushilKumarMalikFootwear",
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

  filterProducts(Map<String, String> filterMap) async {
    String brand = filterMap['brand']!;
    String category = filterMap['category']!;
    String article = filterMap['article']!;
    String size_range = filterMap['size_range']!;
    String color = filterMap['color']!;
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
        if(color.isNotEmpty)
        {
          "\$match": {
            "color": {"\$regex": color, "\$options": "i"}
          }
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
      print(json.encode(response.data));
    } else {
      print(response.statusMessage);
    }
    // List pipeline = [];
    // if (filterMap['brand']!.isNotEmpty) {
    //   pipeline.add({
    //     '\$match': {
    //       'brand': {'\$regex': filterMap['brand'], "\$options": "i"}
    //     },
    //   });
    // }
    // if (filterMap['category']!.isNotEmpty) {
    //   pipeline.add({
    //     "\$match": {
    //       "category": {"\$regex": filterMap['category'], "\$options": "i"}
    //     }
    //   });
    // }
    // if (filterMap['article']!.isNotEmpty) {
    //   pipeline.add({
    //     "\$match": {
    //       "article": {"\$regex": filterMap['article'], "\$options": "i"}
    //     }
    //   });
    // }
    // if (filterMap['size_range']!.isNotEmpty) {
    //   pipeline.add({
    //     "\$match": {
    //       "size_range": {"\$regex": filterMap['size_range'], "\$options": "i"}
    //     }
    //   });
    // }
    // if (filterMap['color']!.isNotEmpty) {
    //   pipeline.add({
    //     "\$match": {
    //       "color": {"\$regex": filterMap['color'], "\$options": "i"}
    //     }
    //   });
    // }
    // pipeline.add({
    //   "\$sort": {"createdAt": -1}
    // });
    // var response = await ApiClient.post(
    //     "https://ap-south-1.aws.data.mongodb-api.com/app/data-rtgjs/endpoint/data/v1/action/find",
    //     {
    //       "collection": "footwears",
    //       "database": "test",
    //       "dataSource": "SushilKumarMalikFootwear",
    //       "pipeline": pipeline,
    //     },
    //     headers: {
    //       'Content-Type': 'application/json',
    //       'Access-Control-Request-Headers': '*',
    //       'api-key':
    //           'qNt2VxYXcnCBIL2txrJq1aTPoXlzCKG4kFCOBCdOvODzQxV0W106vBQNlf5trY3i',
    //       'Accept': 'application/json'
    //     });
    return response.data;
  }

  // read(Function getProducts, Function getError) {
  //   //get products from database
  //   // QuerySnapshot<Map<String, dynamic>> products =
  //   Future<dynamic> future = db.collection(Collections.PRODUCTS).get();
  //   future.then((products) {
  //     List<dynamic> Products = products.docs
  //         .map((element) => Product.fromJSON(element.data()))
  //         .toList();
  //     // print(Products);
  //     getProducts(Products);
  //   }).catchError((err) => {getError(err)});
  // }

  // Future<List<Product>> read() async {
  // QuerySnapshot querySnapshot =
  //     await db.collection(Collections.PRODUCTS).get(); //read all the products
  // List<QueryDocumentSnapshot> list = querySnapshot.docs;
  // List<Product> products =
  //     list.map((QueryDocumentSnapshot doc) => Product.fromJSON(doc)).toList();
  // return products;
  // }

  Stream<QuerySnapshot> readRealTime() {
    Stream<QuerySnapshot> stream =
        db.collection(Collections.PRODUCTS).snapshots();
    return stream;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getSingleProduct(
      String product_id) {
    Future<DocumentSnapshot<Map<String, dynamic>>> querysnapshot =
        db.collection(Collections.PRODUCTS).doc(product_id).get();
    print(querysnapshot);
    // querysnapshot.then((value) => print(value.data()));
    return querysnapshot;
  }
  // Future<dynamic> readByAwait() async {
  //   try {
  //     QuerySnapshot<Map<String, dynamic>> products =
  //         await db.collection(Collections.PRODUCTS).get();
  //     print(products.docs[1].data());
  //     List<Product> Products = products.docs
  //         .map((element) => Product.fromJSON(element.data()))
  //         .toList();
  //     return Products;
  //   } catch (err) {
  //     return err;
  //   }
  // }

  // Future<dynamic> update(Product product) async {
  //   try {
  //     await db.doc(product.id).update(product.toJSON());
  //   } catch (err) {
  //     return err;
  //   }
  // }

  Future<dynamic> delete(Product product) async {
    // try {
    //   await db.collection(Collections.PRODUCTS).doc(product.).delete();
    // } catch (err) {
    //   return err;
    // }
  }
}
