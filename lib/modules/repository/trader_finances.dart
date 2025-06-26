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
    return data.map((json) {
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
}
