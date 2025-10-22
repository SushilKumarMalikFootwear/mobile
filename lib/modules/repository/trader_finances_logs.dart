import '../../config/constants/app_constants.dart';
import '../../utils/services/api_client.dart';

class TraderFinancesLogs {
  Future<Map<String, Map<String, Map>>> getPendingBills() async {
    var response = await ApiClient.get(
      "${ApiUrls.baseUrl}/get_pending_bills",
    );

    List<dynamic> documents = response;
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
          () => data,
        );
      } else {
        result[traderName]![baseDate.split(' ').first] =
            Map<String, dynamic>.from(doc);
      }
    }

    return result;
  }

  Future<Map?> saveTraderFinanceLog(Map<String, dynamic> log) async {
    try {
      final response = await ApiClient.post("${ApiUrls.baseUrl}/save_log", log);
      return response;
    } catch (e) {
      print("Error saving trader finance log: $e");
      return null;
    }
  }

  Future<bool> decreasePendingAmountById({
    required String id,
    required double newPendingAmount,
  }) async {
    try {
      final response = await ApiClient.post(
        "${ApiUrls.baseUrl}/decrease_pending_payment",
        {
          "id": id,
          "newPendingAmount": newPendingAmount,
        },
      );

      return response["modifiedCount"] != null && response["modifiedCount"] > 0;
    } catch (e) {
      print("Error decreasing pending_amount: $e");
      return false;
    }
  }

  Future<double> getLastRunningPendingPayment(String traderName) async {
    try {
      final response = await ApiClient.get(
        "${ApiUrls.baseUrl}/last_pending_amount?trader_name=$traderName",
      );

      final data = response;
      return double.parse(data.toString());
    } catch (e) {
      print("Error in getLastRunningPendingPayment: $e");
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getFilteredTraderFinanceLogs(
      Map<String, dynamic> filterMap) async {
    try {
      final response = await ApiClient.post(
        "${ApiUrls.baseUrl}/filtered_logs",
        filterMap,
      );

      final List<dynamic> documents = response;
      return documents.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, int>> getTraderWisePendingPayments() async {
    try {
      final response = await ApiClient.get(
        "${ApiUrls.baseUrl}/trader_wise_pending_payment",
      );
      Map<String, int> res = {};
      response.forEach((key, value) {
        res.putIfAbsent(key, () => int.parse(value.toString()));
      });
      return res;
    } catch (e) {
      return {};
    }
  }
}
