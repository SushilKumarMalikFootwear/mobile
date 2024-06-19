import 'dart:convert';

import 'package:dio/dio.dart';

import '../../config/constants/app_constants.dart';
import '../../utils/services/api_client.dart';
import '../models/Invoice.dart';

class InvoiceRepository {
  saveInvoice(Invoice invoice, bool isOldInvoice) async {
    var response = await ApiClient.post(
        '${ApiUrls.saveInvoice}?isOldInvoice=$isOldInvoice',
        invoice.toJson());
    return response;
  }

  filterInvoices(Map<String, String> filterMap) async {
    var data = json.encode({
      "collection": "invoices",
      "database": "test",
      "dataSource": "SushilKumarMalikFootwear",
      "pipeline": [
        {
          '\$sort': {"invoice_date": -1}
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
}
