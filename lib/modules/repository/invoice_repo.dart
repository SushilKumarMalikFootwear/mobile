import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:footwear/modules/models/daily_invoices.dart';

import '../../config/constants/app_constants.dart';
import '../../utils/services/api_client.dart';
import '../models/Invoice.dart';

class InvoiceRepository {
  saveInvoice(Invoice invoice, bool isOldInvoice) async {
    var response = await ApiClient.post(
        '${ApiUrls.saveInvoice}?isOldInvoice=$isOldInvoice', invoice.toJson());
    return response;
  }

  updateInvoice(Invoice invoice) async {
    var response =
        await ApiClient.post(ApiUrls.updateInvoice, invoice.toJson());
    return response;
  }

  Future<Map<String, DailyInvoices>> filterInvoices(Map<String, String> filterMap) async {
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
    List list = response.data['documents'];
    Map<String, DailyInvoices> dailyInvoicesMap = {};
    for (Map invoiceMap in list) {
      String key =
          "${invoiceMap['invoice_date'].toString().split("T")[0]}:${invoiceMap['sold_at']}";
      Invoice invoice = Invoice.fromJson(invoiceMap);
      if (dailyInvoicesMap.containsKey(key)) {
        DailyInvoices dailyInvoices = dailyInvoicesMap[key]!;
        dailyInvoices.invoices.add(invoice);
        dailyInvoices.profit += invoice.profit;
        dailyInvoices.sellingPrice += invoice.sellingPrice;
      } else {
        DailyInvoices dailyInvoices = DailyInvoices(
            profit: invoice.profit,
            date: invoiceMap['invoice_date'].toString().split("T")[0],
            invoices: [invoice],
            sellingPrice: invoice.sellingPrice,
            soldAt: invoice.soldAt);
        dailyInvoicesMap[key] = dailyInvoices;
      }
    }
    return dailyInvoicesMap;
  }
}
