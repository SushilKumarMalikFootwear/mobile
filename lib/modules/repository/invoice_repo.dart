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
    // String article = filterMap['article'] ?? '';
    // String size = filterMap['size'] ?? '';
    // String color = filterMap['color'] ?? '';
    // String date = filterMap['date'] ?? '';
    // String soldAt = filterMap['soldAt'] ?? '';
    // bool paymentPending = filterMap['paymentPending'] == 'true';
    // bool returnedInvoice = filterMap['returnedInvoice'] == 'true';
    // DateTime selectedDateRangeStartDate =
    //     filterMap['selectedDateRangeStartDate'] ??
    //         DateTime.now().subtract(Duration(days: 30));
    // DateTime selectedDateRangeEndDate = filterMap['selectedDateRangeEndDate'] ??
    //     DateTime.now().add(Duration(days: 1));

    // DateTime? parseDate(String dateStr) {
    //   try {
    //     return DateTime.parse(dateStr);
    //   } catch (e) {
    //     return null;
    //   }
    // }

    // DateTime? dateFilter = date.isNotEmpty ? parseDate(date) : null;

    // List pipeline = [
    //   if (dateFilter != null)
    //     {
    //       "\$match": {
    //         "invoice_date": {
    //           "\$gte": {"\$date": formatToIso8601WithTimezone(dateFilter)},
    //           "\$lt": {
    //             "\$date": formatToIso8601WithTimezone(
    //                 dateFilter.add(Duration(days: 1)))
    //           }
    //         }
    //       }
    //     },
    //   if (dateFilter == null)
    //     {
    //       "\$match": {
    //         "invoice_date": {
    //           "\$gte": {
    //             "\$date":
    //                 formatToIso8601WithTimezone(selectedDateRangeStartDate)
    //           },
    //           "\$lt": {
    //             "\$date": formatToIso8601WithTimezone(selectedDateRangeEndDate)
    //           }
    //         }
    //       }
    //     },
    //   if (article.isNotEmpty)
    //     {
    //       "\$match": {
    //         "article": {"\$regex": article, "\$options": "i"}
    //       }
    //     },
    //   if (color.isNotEmpty)
    //     {
    //       "\$match": {
    //         "color": {"\$regex": color, "\$options": "i"}
    //       }
    //     },
    //   if (size.isNotEmpty)
    //     {
    //       "\$match": {"size": int.parse(size)}
    //     },
    //   if (soldAt.isNotEmpty)
    //     {
    //       "\$match": {"sold_at": soldAt}
    //     },
    //   if (paymentPending)
    //     {
    //       "\$match": {"payment_status": "PENDING"}
    //     },
    //   if (returnedInvoice)
    //     {
    //       "\$match": {"invoice_status": "RETURNED"}
    //     },
    //   {
    //     '\$sort': {"invoice_date": -1}
    //   }
    // ];

    // var data = json.encode({
    //   "collection": "invoices",
    //   "database": "test",
    //   "dataSource": "SushilKumarMalikFootwear",
    //   "pipeline": pipeline
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
    Map<String,dynamic> clone = {...filterMap};
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

  Future<Map<String, dynamic>> fetchInvoicesForSizesSalesReport(String article,
      DateTime startDate, DateTime endDate, String label) async {
    List pipeline = [
      if (label.isNotEmpty)
        {
          "\$match": {
            "article": {"\$regex": article, "\$options": "i"}
          }
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

      if (list.isEmpty) {
        return {};
      }

      // Collect footwear IDs for invoice query
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

      response = await dio.request(
        "${ApiUrls.mongoDbApiUrl}/aggregate",
        options: Options(
          method: 'POST',
          headers: Constants.mongoDbHeaders,
        ),
        data: data,
      );

      List invoices = response.data['documents'];
      if (invoices.isEmpty) {
        return {};
      }

      Map<String, int> report = {};
      Map<String, Map> productMap = {};
      Map<String, dynamic> dataMap = {
        'report': report,
        'total_count': invoices.length,
        'cost_price': 0,
        'selling_price': 0,
        'profit': 0
      };
      // Function to expand size ranges
      void extractSizes(String range, String sizeDescription) {
        var sizeGroups = range.split('-');
        for (String group in sizeGroups) {
          var parts = group.split('X').map(int.parse).toList();
          for (int i = parts[0]; i <= parts[1]; i++) {
            if (sizeDescription == "S") {
              report["${i}K"] = 0;
            } else {
              report["$i"] = 0;
            }
          }
        }
      }

      // Initialize report keys using size ranges and descriptions
      for (var product in list) {
        productMap[product['footwear_id']] = product;
        String range = product['size_range'];
        String sizeDescription = product['size_description'] ?? "";
        extractSizes(range, sizeDescription);
      }

      // Fill counts from invoices
      for (Map invoice in invoices) {
        String sizeKey = invoice['size'].toString();
        String sizeDescription =
            productMap[invoice['product_id']]!['size_description'].toString();

        if (sizeDescription == "S") {
          sizeKey = "${sizeKey}K";
        }

        report[sizeKey] = (report[sizeKey] ?? 0) + 1;
        dataMap['cost_price'] += invoice['cost_price'];
        dataMap['selling_price'] += invoice['selling_price'];
        dataMap['profit'] += invoice['profit'];
      }
      return dataMap;
    } else {
      throw Exception("Failed to fetch invoices");
    }
  }

  Future<List> fetchMonthlySalesReport() async {
    List<Map<String, dynamic>> pipeline = [
      {
        '\$match': {
          'invoice_status': {
            '\$in': ["COMPLETED", "RETURNED"]
          },
        },
      },
      {
        '\$group': {
          '_id': {
            'month': {
              '\$dateToString': {'format': "%Y-%m", 'date': "\$invoice_date"}
            },
            'place': "\$sold_at",
            'day': {
              '\$dateToString': {'format': "%Y-%m-%d", 'date': "\$invoice_date"}
            },
          },
          'totalSP': {'\$sum': "\$selling_price"},
          'totalProfit': {'\$sum': "\$profit"},
          'totalInvoices': {'\$sum': 1},
          'returnedInvoices': {
            '\$sum': {
              '\$cond': [
                {
                  '\$eq': ["\$invoice_status", "RETURNED"]
                }, // Condition
                1, // If true, add 1
                0 // Else, add 0
              ]
            }
          },
        },
      },
      {
        '\$group': {
          '_id': {'month': "\$_id.month", 'place': "\$_id.place"},
          'totalSP': {'\$sum': "\$totalSP"},
          'totalProfit': {'\$sum': "\$totalProfit"},
          'totalInvoices': {'\$sum': "\$totalInvoices"},
          'returnedInvoices': {'\$sum': "\$returnedInvoices"},
          'uniqueDays': {'\$addToSet': "\$_id.day"},
        },
      },
      {
        '\$addFields': {
          'numDays': {'\$size': "\$uniqueDays"},
          'dailyAvgSales': {
            '\$round': [
              {
                '\$cond': [
                  {
                    '\$gt': [
                      {'\$size': "\$uniqueDays"},
                      0
                    ]
                  }, // If numDays > 0
                  {
                    '\$divide': [
                      "\$totalSP",
                      {'\$size': "\$uniqueDays"}
                    ]
                  }, // Compute avg sales
                  0 // Else return 0
                ]
              },
              0 // Round to 0 decimal places
            ],
          },
          'dailyAvgInvoices': {
            '\$round': [
              {
                '\$cond': [
                  {
                    '\$gt': [
                      {'\$size': "\$uniqueDays"},
                      0
                    ]
                  },
                  {
                    '\$divide': [
                      "\$totalInvoices",
                      {'\$size': "\$uniqueDays"}
                    ]
                  },
                  0
                ]
              },
              0
            ],
          },
        },
      },
      {
        '\$group': {
          '_id': "\$_id.month",
          'sales': {
            '\$push': {
              'place': "\$_id.place",
              'totalSP': "\$totalSP",
              'totalProfit': "\$totalProfit",
              'totalInvoices': "\$totalInvoices",
              'returnedInvoices': "\$returnedInvoices",
              'numDays': "\$numDays",
              'dailyAvgSales': "\$dailyAvgSales",
              'dailyAvgInvoices': "\$dailyAvgInvoices",
            },
          },
        },
      },
      {
        '\$sort': {'_id': 1},
      },
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
    return response.data['documents'];
  }
}
