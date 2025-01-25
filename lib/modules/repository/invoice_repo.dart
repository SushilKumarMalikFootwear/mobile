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
    String article = filterMap['article'] ?? '';
    String size = filterMap['size'] ?? '';
    String color = filterMap['color'] ?? '';
    String date = filterMap['date'] ?? '';
    String soldAt = filterMap['soldAt'] ?? '';
    bool paymentPending = filterMap['paymentPending'] == 'true';
    bool returnedInvoice = filterMap['returnedInvoice'] == 'true';
    DateTime selectedDateRangeStartDate =
        filterMap['selectedDateRangeStartDate'] ??
            DateTime.now().subtract(Duration(days: 30));
    DateTime selectedDateRangeEndDate = filterMap['selectedDateRangeEndDate'] ??
        DateTime.now().add(Duration(days: 1));

    DateTime? parseDate(String dateStr) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }

    DateTime? dateFilter = date.isNotEmpty ? parseDate(date) : null;

    List pipeline = [
      if (dateFilter != null)
        {
          "\$match": {
            "invoice_date": {
              "\$gte": {"\$date": formatToIso8601WithTimezone(dateFilter)},
              "\$lt": {
                "\$date": formatToIso8601WithTimezone(
                    dateFilter.add(Duration(days: 1)))
              }
            }
          }
        },
      if (dateFilter == null)
        {
          "\$match": {
            "invoice_date": {
              "\$gte": {
                "\$date":
                    formatToIso8601WithTimezone(selectedDateRangeStartDate)
              },
              "\$lt": {
                "\$date": formatToIso8601WithTimezone(selectedDateRangeEndDate)
              }
            }
          }
        },
      if (article.isNotEmpty)
        {
          "\$match": {
            "article": {"\$regex": article, "\$options": "i"}
          }
        },
      if (color.isNotEmpty)
        {
          "\$match": {
            "color": {"\$regex": color, "\$options": "i"}
          }
        },
      if (size.isNotEmpty)
        {
          "\$match": {"size": int.parse(size)}
        },
      if (soldAt.isNotEmpty)
        {
          "\$match": {"sold_at": soldAt}
        },
      if (paymentPending)
        {
          "\$match": {"payment_status": "PENDING"}
        },
      if (returnedInvoice)
        {
          "\$match": {"invoice_status": "RETURNED"}
        },
      {
        '\$sort': {"invoice_date": -1}
      }
    ];

    var data = json.encode({
      "collection": "invoices",
      "database": "test",
      "dataSource": "SushilKumarMalikFootwear",
      "pipeline": pipeline
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

  Future<Map<String, int>> fetchInvoicesForSalesReport(String article,
      DateTime startDate, DateTime endDate, String label) async {
    List pipeline = [
      if (label.isNotEmpty)
        {
          "\$match": {"label": label}
        },
      if (article.isNotEmpty)
        {
          "\$match": {"article": article}
        }
    ];

    var data = json.encode({
      "collection": "footwears",
      "database": "test",
      "dataSource": "SushilKumarMalikFootwear",
      "pipeline": pipeline
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
    if (response.statusCode == 200) {
      List<String> sizeSet = [];
      List list = response.data['documents'];
      int sum = list.fold(0, (val, inv) {
        return val + int.parse(inv['cost_price'].toString());
      });
      int avg = sum ~/ list.length;
      List<String> footwearIds = list.map((e) {
        sizeSet.add(e['size_range']);
        return e['footwear_id'].toString();
      }).toList();
      pipeline = [
        {
          "\$match": {
            "product_id": {"\$in": footwearIds},
            "invoice_date": {
              "\$gte": {"\$date": formatToIso8601WithTimezone(startDate)},
              "\$lt": {"\$date": formatToIso8601WithTimezone(endDate)}
            },
            "invoice_status": "COMPLETED"
          }
        }
      ];
      data = json.encode({
        "collection": "invoices",
        "database": "test",
        "dataSource": "SushilKumarMalikFootwear",
        "pipeline": pipeline
      });

      dio = Dio();
      response = await dio.request(
        "${ApiUrls.mongoDbApiUrl}/aggregate",
        options: Options(
          method: 'POST',
          headers: Constants.mongoDbHeaders,
        ),
        data: data,
      );
      list = response.data['documents'];
      if (list.isEmpty) {
        return {};
      }
      print(sizeSet);

      Map<String, int> report = {};
      List<String> sortedSizes = [];
      bool smallSizesProcessed = false;

      void extractSizes(String range) {
        var parts = range.split('X').map(int.parse).toList();
        List<int> sizes = [for (int i = parts[0]; i <= parts[1]; i++) i];

        // If sizes are within the "kids range" and not processed yet, mark them with 'k'
        if (sizes.first <= 10 && !smallSizesProcessed) {
          sortedSizes.addAll(sizes.map((size) => '${size}k'));
          smallSizesProcessed = true;
        } else {
          sortedSizes.addAll(sizes.map((size) => size.toString()));
        }
      }

      for (String range in sizeSet) {
        if (range.contains('-')) {
          var splitRanges = range.split('-');
          for (String subRange in splitRanges) {
            extractSizes(subRange);
          }
        } else {
          extractSizes(range);
        }
      }

      // Remove duplicates and retain order
      sortedSizes = sortedSizes.toSet().toList();

      for (String size in sortedSizes) {
        report[size] = 0;
      }

      for (int i = 0; i < list.length; i++) {
        Map invoice = list[i];
        if (!([6, 7, 8, 9, 10].contains(invoice['size'])) &&
            report.containsKey(invoice['size'].toString())) {
          report[invoice['size'].toString()] =
              report[invoice['size'].toString()]! + 1;
        } else if (([6, 7, 8, 9, 10].contains(invoice['size']))) {
          if (invoice['cost_price'] > avg) {
            report[invoice['size'].toString()] =
                report[invoice['size'].toString()]! + 1;
          } else {
            report[invoice['size'].toString() + 'k'] =
                report[invoice['size'].toString() + 'k']! + 1;
          }
        } else {
          report[invoice['size'].toString()] = 1;
        }
      }

      print(report);
      return report;
    } else {
      throw Exception("Failed to fetch invoices");
    }
  }
}
