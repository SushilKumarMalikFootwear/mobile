import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:footwear/modules/repository/trader_finances_logs.dart';

class ViewTraderFinacesLogs extends StatefulWidget {
  const ViewTraderFinacesLogs({super.key});

  @override
  State<ViewTraderFinacesLogs> createState() => _ViewTraderFinacesLogsState();
}

class _ViewTraderFinacesLogsState extends State<ViewTraderFinacesLogs> {
  final TraderFinancesLogs traderFinancesLogs = TraderFinancesLogs();
  late Future<List<Map<String, dynamic>>> future;
  Map<String, dynamic> filterMap = {};

  @override
  void initState() {
    super.initState();
    getTraderFinancesLogs(filterMap);
  }

  void getTraderFinancesLogs(Map<String, dynamic> filterMap) {
    future = traderFinancesLogs.getFilteredTraderFinanceLogs(filterMap);
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
    return Container(
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

          if (logs.isEmpty) {
            return const Center(child: Text("No logs found."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final type = log['type'] ?? '';
              final amount = log['amount']?.toStringAsFixed(2) ?? '0.00';
              final date = log['date'] ?? '';
              final trader = log['trader_name'] ?? '';

              return Container(
                decoration: BoxDecoration(
                  color: getCardColor(log),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT SECTION
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
              );
            },
          );
        },
      ),
    );
  }
}
