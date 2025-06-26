import '../../config/constants/app_constants.dart';
import '../../utils/services/api_client.dart';
import '../models/trader_finances.dart';

class TraderFinancesRepository {
  Future<List<TraderFinance>> getData() async {
    var response = await ApiClient.post(
        "${ApiUrls.mongoDbApiUrl}/find",
        {
          "collection": "trader_finances",
          "database": "test",
          "dataSource": "SushilKumarMalikFootwear",
        },
        headers: Constants.mongoDbHeaders);
    List<dynamic> data = response['documents'];
    Map<String, int> pendingPaymentMap = await getTraderWisePendingPayments();
    return data.map((json) {
      json['pending_payment'] = pendingPaymentMap[json['trader_name']];
      return TraderFinance.fromJson(json);
    }).toList();
  }

  Future<bool> updateTraderTotalCostPrice({
    required String traderName,
    required double amountToAdd,
  }) async {
    try {
      final response = await ApiClient.post(
        "${ApiUrls.mongoDbApiUrl}/updateOne",
        {
          "collection": "trader_finances",
          "database": "test",
          "dataSource": "SushilKumarMalikFootwear",
          "filter": {"trader_name": traderName},
          "update": {
            "\$inc": {"total_cost_price": amountToAdd}
          }
        },
        headers: Constants.mongoDbHeaders,
      );

      return (response["matchedCount"] ?? 0) > 0;
    } catch (e) {
      print("Error updating trader total_cost_price: $e");
      return false;
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
