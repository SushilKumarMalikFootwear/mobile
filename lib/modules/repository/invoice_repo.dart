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
    DateTime selectedDateRangeEndDate =
        filterMap['selectedDateRangeEndDate'] ?? DateTime.now().add(Duration(days:1));

    DateTime? parseDate(String dateStr) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }

    DateTime? dateFilter = date.isNotEmpty ? parseDate(date) : null;
    String formatToIso8601WithTimezone(DateTime dateTime) {
      DateTime adjustedDateTime = DateTime.utc(
        dateTime.year,
        dateTime.month,
        dateTime.day,
      );
      String isoString = adjustedDateTime.toIso8601String();
      return isoString;
    }

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
      if(dateFilter==null)
            {
        "\$match": {
          "invoice_date": {
            "\$gte": {
              "\$date": formatToIso8601WithTimezone(selectedDateRangeStartDate)
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
}
