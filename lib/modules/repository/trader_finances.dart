import '../../config/constants/app_constants.dart';
import '../../utils/services/api_client.dart';
import '../models/trader_finances.dart';

class TraderFinancesRepository {
  Future<List<TraderFinance>> getData() async {
    var response =
        await ApiClient.get("${ApiUrls.baseUrl}/get_trader_finances");
    List<dynamic> data = response;
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
          "${ApiUrls.baseUrl}/update_total_cost_price",
          {"traderName": traderName, "costPrice": amountToAdd});

      return response["status"];
    } catch (e) {
      print("Error updating trader total_cost_price: $e");
      return false;
    }
  }
}
