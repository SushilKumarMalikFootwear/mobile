import 'package:flutter/material.dart';
import 'package:footwear/utils/widgets/custom_bottom_sheet.dart';
import 'package:intl/intl.dart';
import 'package:footwear/modules/repository/trader_finances_logs.dart';

import 'tarderFinancesLogsFilter.dart';

class ViewTraderFinacesLogs extends StatefulWidget {
  const ViewTraderFinacesLogs({super.key});

  @override
  State<ViewTraderFinacesLogs> createState() => _ViewTraderFinacesLogsState();
}

class _ViewTraderFinacesLogsState extends State<ViewTraderFinacesLogs> {
  final TraderFinancesLogs traderFinancesLogs = TraderFinancesLogs();
  late Future<List<Map<String, dynamic>>> future;
  Map<String, int>? traderWisePendingMap = {'R.S. Trading': 1000};
  Map<String, dynamic> filterMap = {'showPendingPayment': true};

  @override
  void initState() {
    super.initState();
    getTraderFinancesLogs(filterMap);
  }

  void getTraderFinancesLogs(Map<String, dynamic> filterMap) async {
    future = traderFinancesLogs.getFilteredTraderFinanceLogs(filterMap);
    this.filterMap = filterMap;

    if (filterMap['showPendingPayment'] == true) {
      traderWisePendingMap =
          await traderFinancesLogs.getTraderWisePendingPayments();
    } else {
      traderWisePendingMap = null;
    }

    setState(() {});
  }

  String formatDate(String isoDate) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(isoDate));
    } catch (_) {
      return isoDate;
    }
  }

  Color getCardColor(Map<String, dynamic> log) {
    final type = log['type'];
    final pending = log['pending_amount'];

    if (type == "PAYMENT") return Colors.blue.shade100;
    if (type == "CLAIM") return Colors.grey.shade300;
    if (type == "PURCHASE") {
      return (pending == 0 || pending == 0.0)
          ? Colors.green.shade100
          : Colors.yellow.shade100;
    }
    return Colors.white;
  }

  String getStatusText(Map<String, dynamic> log) {
    if (log['type'] == "PURCHASE" &&
        (log['pending_amount'] == 0 || log['pending_amount'] == 0.0)) {
      return "Bill Paid";
    }
    if (log['type'] == "PURCHASE") {
      return "Pending: ₹ ${log['pending_amount'].toStringAsFixed(2)}";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.filter_alt_outlined),
          onPressed: () {
            customBottomSheet(
              context,
              TraderFinancesLogsFilter(
                applyFilter: getTraderFinancesLogs,
                filterOptions: filterMap,
              ),
            );
          }),
      body: Container(
        color: Colors.grey.shade100,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final logs = snapshot.data ?? [];
            print(logs);

            if (logs.isEmpty) {
              return const Center(child: Text("No logs found."));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: logs.length +
                  (traderWisePendingMap != null &&
                          traderWisePendingMap!.isNotEmpty[{_id: 686585be41f62eba8f356de5, id: 1751483837555_R.S. Trading_PURCHASE, date: 2023-04-25T00:00:00.000, trader_name: R.S. Trading, type: PURCHASE, amount: 3463, description: , running_pending_payment: 3463, pending_amount: 3463}, {_id: 686585891962d757de1551c6, id: 1751483784668_Baba Footwear_PAYMENT, date: 2023-04-24T00:00:01.000, trader_name: Baba Footwear, type: PAYMENT, amount: 12229, description: UPI + 4500 cashback of previous scheme, running_pending_payment: 0, bill_ids: [1751483697050_Baba Footwear_PURCHASE], payment_mode: UPI}, {_id: 6865853dd678a9f20baa1bcf, id: 1751483697050_Baba Footwear_PURCHASE, date: 2023-04-24T00:00:00.000, trader_name: Baba Footwear, type: PURCHASE, amount: 12229, description: , running_pending_payment: 12229, pending_amount: 0}
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (traderWisePendingMap != null &&
                    index == 0 &&
                    (traderWisePendingMap?.isNotEmpty ?? false)) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pending Payments",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...traderWisePendingMap!.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "₹ ${entry.value.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }

                final log = logs[index -
                    (traderWisePendingMap != null &&
                            traderWisePendingMap!.isNotEmpty
                        ? 1
                        : 0)];
                final type = log['type'] ?? '';
                final amount = log['amount']?.toStringAsFixed(2) ?? '0.00';
                final date = log['date'] ?? '';
                final trader = log['trader_name'] ?? '';
                final runningPendingPayment = log['running_pending_payment'];
                return Container(
                  decoration: BoxDecoration(
                    color: getCardColor(log),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trader,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Amount: ₹ $amount",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (log["type"] == "PURCHASE")
                                  Text(
                                    getStatusText(log),
                                    style: TextStyle(
                                      color: (log["pending_amount"] == 0 ||
                                              log["pending_amount"] == 0.0)
                                          ? Colors.green.shade700
                                          : Colors.orange.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // RIGHT SECTION
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Text(
                                  type,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formatDate(date),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (type != 'CLAIM') const Divider(),
                      if (type != 'CLAIM')
                        Text('Running Pending Payment - $runningPendingPayment')
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
