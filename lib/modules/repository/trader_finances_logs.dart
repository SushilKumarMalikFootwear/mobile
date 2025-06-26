import '../../config/constants/app_constants.dart';
import '../../utils/services/api_client.dart';

class TraderFinancesLogs {
  Future<Map<String, Map<String, Map>>> getPendingBills() async {
    var response = await ApiClient.post(
      "${ApiUrls.mongoDbApiUrl}/find",
      {
        "collection": "trader_finances_logs",
        "database": "test",
        "dataSource": "SushilKumarMalikFootwear",
        "filter": {
          "type": "PURCHASE",
          "pending_amount": {"\$ne": 0}
        }
      },
      headers: Constants.mongoDbHeaders,
    );

    List<dynamic> documents = response['documents'];

    Map<String, Map<String, Map>> result = {};

    for (var doc in documents) {
      String traderName = doc['trader_name'];
      String baseDate =
          DateTime.parse(doc['date']).toLocal().toString().split('.').first;

      result.putIfAbsent(traderName, () => {});
      if (result[traderName]!.containsKey(baseDate.split(' ').first)) {
        Map data = result[traderName]![baseDate.split(' ').first]!;
        result[traderName]!.remove(baseDate.split(' ').first);
        result[traderName]![baseDate] = doc;
        result[traderName]!.putIfAbsent(
            DateTime.parse(data['date']).toLocal().toString().split('.').first,
            () => data);
      } else {
        result[traderName]![baseDate.split(' ').first] =
            Map<String, dynamic>.from(doc);
      }
    }

    return result;
  }

  Future<bool> saveTraderFinanceLog(Map<String, dynamic> log) async {
    try {
      final response = await ApiClient.post(
        "${ApiUrls.mongoDbApiUrl}/insertOne",
        {
          "collection": "trader_finances_logs",
          "database": "test",
          "dataSource": "SushilKumarMalikFootwear",
          "document": log,
        },
        headers: Constants.mongoDbHeaders,
      );

      return response["insertedId"] != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> decreasePendingAmountById({
    required String id,
    required double newPendingAmount,
  }) async {
    try {
      final response = await ApiClient.post(
        "${ApiUrls.mongoDbApiUrl}/updateOne",
        {
          "collection": "trader_finances_logs",
          "database": "test",
          "dataSource": "SushilKumarMalikFootwear",
          "filter": {
            "id": id,
          },
          "update": {
            "\$set": {
              "pending_amount": newPendingAmount,
            }
          }
        },
        headers: Constants.mongoDbHeaders,
      );

      return response["modifiedCount"] > 0;
    } catch (e) {
      print("Error decreasing pending_amount: $e");
      return false;
    }
  }
Future<List<Map<String, dynamic>>> getFilteredTraderFinanceLogs(
    Map<String, dynamic> filterMap) async {
  try {
    final Map<String, dynamic> filter = {};

    final String? traderName = filterMap['trader_name'];
    final String? type = filterMap['type'];
    final DateTime? fromDate = filterMap['fromDate'];
    final DateTime? toDate = filterMap['toDate'];

    if (traderName != null && traderName.isNotEmpty) {
      filter["trader_name"] = traderName;
    }

    if (type != null && type.isNotEmpty) {
      filter["type"] = type;
    }

    if (fromDate != null || toDate != null) {
      filter["date"] = {};

      if (fromDate != null) {
        filter["date"]["\$gte"] = fromDate.toIso8601String();
      }

      if (toDate != null) {
        filter["date"]["\$lte"] = toDate.toIso8601String();
      }
    }

    final response = await ApiClient.post(
      "${ApiUrls.mongoDbApiUrl}/find",
      {
        "collection": "trader_finances_logs",
        "database": "test",
        "dataSource": "SushilKumarMalikFootwear",
        "filter": filter,
        "sort": {
          "date": -1 // 🔽 descending order by date
        }
      },
      headers: Constants.mongoDbHeaders,
    );

    final List<dynamic> documents = response["documents"];
    return documents.cast<Map<String, dynamic>>();
  } catch (e) {
    print("Error fetching filtered trader finance logs: $e");
    return [];
  }
}

  Future<Map<String, int>> getTraderWisePendingPayments() async {
    try {
      final response = await ApiClient.post(
        "${ApiUrls.mongoDbApiUrl}/aggregate",
        {
          "collection": "trader_finances_logs",
          "database": "test",
          "dataSource": "SushilKumarMalikFootwear",
          "pipeline": [
            {
              "\$match": {
                "type": "PURCHASE",
                "pending_amount": {"\$gt": 0}
              }
            },
            {
              "\$group": {
                "_id": "\$trader_name",
                "totalPending": {"\$sum": "\$pending_amount"}
              }
            }
          ]
        },
        headers: Constants.mongoDbHeaders,
      );

      final List<dynamic> docs = response["documents"];
      final Map<String, int> result = {};
      for (var doc in docs) {
        result[doc["_id"]] = (doc["totalPending"] as num).round();
      }
      return result;
    } catch (e) {
      print("Error fetching trader-wise pending payments: $e");
      return {};
    }
  }



}
