import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:footwear/config/constants/AppConstants.dart';

abstract class ApiClient {
  static Dio _dio = Dio();
  static get(
    String url, {
    ResponseType responseType = ResponseType.json,
  }) async {
    try {
      _dio.options.headers = Constants.isBackendStarted
          ? Constants.basicHeaders
          : Constants.mongoDbApiHeaders;
      Response response = await _dio.get(url,
          options: Options(
              validateStatus: (status) {
                return true;
              },
              responseType: responseType));
      return response.data;
    } catch (err) {}
  }

  static post(String url, dynamic data,
      {ResponseType responseType = ResponseType.json,
      Map<String, dynamic>? headers}) async {
    try {
      if (headers != null) {
        _dio.options.headers = headers;
      } else {
        _dio.options.headers = Constants.isBackendStarted
            ? Constants.basicHeaders
            : Constants.mongoDbApiHeaders;
      }
      Response response = await _dio.post(url,
          data: jsonEncode(data),
          options: Options(
              responseType: responseType,
              validateStatus: (status) {
                return true;
              }));

      return response.data;
    } on DioError catch (err) {}
  }

  put(String url) async {
    try {
      _dio.options.headers = Constants.isBackendStarted
          ? Constants.basicHeaders
          : Constants.mongoDbApiHeaders;
      Response response =
          await _dio.put(url, options: Options(validateStatus: (status) {
        return true;
      }));
      return jsonDecode(response.toString());
    } on DioError catch (err) {}
  }

  delete(String url) async {
    try {
      _dio.options.headers = Constants.isBackendStarted
          ? Constants.basicHeaders
          : Constants.mongoDbApiHeaders;
      Response response =
          await _dio.delete(url, options: Options(validateStatus: (status) {
        return true;
      }));
      return jsonDecode(response.toString());
    } on DioError catch (err) {}
  }
}
