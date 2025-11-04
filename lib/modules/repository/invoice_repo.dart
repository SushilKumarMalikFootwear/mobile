import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:footwear/modules/models/daily_invoices.dart';

import '../../config/constants/app_constants.dart';
import '../../utils/services/api_client.dart';
import '../models/Invoice.dart';

class InvoiceRepository {
  saveInvoice(Invoice invoice) async {
    var response = await ApiClient.post(ApiUrls.saveInvoice, invoice.toJson());
    return response;
  }

  updateInvoice(Invoice invoice) async {
    var response =
        await ApiClient.post(ApiUrls.updateInvoice, invoice.toJson());
    return response;
  }

  String formatToIso8601WithTimezone(DateTime dateTime) {
    DateTime adjustedDateTime = DateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
    String isoString = adjustedDateTime.toIso8601String();
    return isoString;
  }

  Future<Map<String, DailyInvoices>> filterInvoices(
      Map<String, dynamic> filterMap) async {
    Map<String, dynamic> clone = {...filterMap};
    clone.updateAll((key, value) => value.toString());
    var response =
        await ApiClient.post("${ApiUrls.baseUrl}/fetchInvoices", clone);
    List list = response['doc'];
    Map<String, DailyInvoices> dailyInvoicesMap = {};
    for (Map invoiceMap in list) {
      String key =
          "${invoiceMap['invoice_date'].toString().split("T")[0]}:${invoiceMap['sold_at']}";
      Invoice invoice = Invoice.fromJson(invoiceMap);
      if (dailyInvoicesMap.containsKey(key)) {
        DailyInvoices dailyInvoices = dailyInvoicesMap[key]!;
        dailyInvoices.invoices.add(invoice);
        if (invoice.invoiceStatus != "RETURNED") {
          dailyInvoices.profit += invoice.profit;
          dailyInvoices.sellingPrice += invoice.sellingPrice;
        }
      } else {
        DailyInvoices dailyInvoices = DailyInvoices(
            profit: invoice.invoiceStatus != "RETURNED" ? invoice.profit : 0,
            date: invoiceMap['invoice_date'].toString().split("T")[0],
            invoices: [invoice],
            sellingPrice:
                invoice.invoiceStatus != "RETURNED" ? invoice.sellingPrice : 0,
            soldAt: invoice.soldAt);
        dailyInvoicesMap[key] = dailyInvoices;
      }
    }

    return dailyInvoicesMap;
  }

  Future<Map<String, dynamic>> fetchInvoicesForSizesSalesReport(
    String article,
    DateTime startDate,
    DateTime endDate,
    String label,
  ) async {
    try {
      final Map<String, dynamic> requestBody = {
        "article": article,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "label": label,
      };

      final response = await ApiClient.post(
        "${ApiUrls.baseUrl}/fetchSizesSalesReport",
        requestBody,
      );

      if (response != null && response.isNotEmpty) {
        Map<String, dynamic> res = Map<String, dynamic>.from(response);
        Map<String, dynamic> reportData =
            Map<String, dynamic>.from(res['report']);

        Map<String, Map> smallMap = {};
        Map<String, Map> otherMap = {};

        reportData.forEach((key, value) {
          if (value['sizeDescription'] == 'S') {
            smallMap[key] = value;
          } else {
            otherMap[key] = value;
          }
        });
        List<Map<String, int>> smallList = [];
        List<String> smallKeys = smallMap.keys.toList();

        smallKeys.sort((a, b) {
          int aNum = int.tryParse(a.replaceAll('K', '')) ?? 0;
          int bNum = int.tryParse(b.replaceAll('K', '')) ?? 0;
          return aNum.compareTo(bNum);
        });

        String? oneKey = smallKeys.firstWhere(
          (k) => k == '1K' || k == '1',
          orElse: () => '',
        );
        if (oneKey.isNotEmpty) {
          smallKeys.remove(oneKey);
          smallKeys.add('1');
        }
        if (smallMap.containsKey('1K')) {
          smallMap.putIfAbsent('1', () => smallMap['1K']!);
          smallMap.remove('1K');
        }
        for (var key in smallKeys) {
          final val = smallMap[key];
          if (val != null) {
            String finalKey = key == '1K' ? '1' : key;
            smallList.add({finalKey: val['count']});
          }
        }

        List<Map<String, int>> otherList = [];
        List<String> otherKeys = otherMap.keys.toList();

        otherKeys.sort((a, b) {
          int aNum = int.tryParse(a.replaceAll('K', '')) ?? 0;
          int bNum = int.tryParse(b.replaceAll('K', '')) ?? 0;
          return aNum.compareTo(bNum);
        });

        for (var key in otherKeys) {
          final val = otherMap[key];
          if (val != null) {
            otherList.add({key: val['count']});
          }
        }

        List<Map<String, int>> finalList = [...smallList, ...otherList];

        res['report'] = finalList;

        return res;
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> fetchMonthlySalesReport() async {
    try {
      final url = "${ApiUrls.baseUrl}/monthlySalesReport";

      final response = await ApiClient.get(
        url,
      );

      if (response['message'] != null && response['message'] == 'successful') {
        final data = response['doc'];

        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
