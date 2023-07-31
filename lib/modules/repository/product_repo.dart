import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  getProducts(Map<String, dynamic> filterMap) async {
    var response = await ApiClient.post(ApiUrls.FILTER_FOOTWEARS, filterMap);
    return response;
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
