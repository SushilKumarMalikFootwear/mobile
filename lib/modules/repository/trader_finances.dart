
import '../../config/constants/app_constants.dart';
import '../../utils/services/api_client.dart';
import '../models/trader_finances.dart';

class TraderFinancesRepository{
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
    return data.map((json) => TraderFinance.fromJson(json)).toList();
  }
}