import 'package:flutter/material.dart';
import 'package:footwear/modules/repository/trader_finances_logs.dart';
import 'package:intl/intl.dart';

import '../../utils/widgets/custom_bottom_sheet.dart';
import 'tarderFinancesLogsFilter.dart';

class ViewTraderFinacesLogs extends StatefulWidget {
  const ViewTraderFinacesLogs({super.key});

  @override
  State<ViewTraderFinacesLogs> createState() => _ViewTraderFinacesLogsState();
}

class _ViewTraderFinacesLogsState extends State<ViewTraderFinacesLogs> {
  late Future<List<Map<String, dynamic>>> future;
  TraderFinancesLogs traderFinancesLogs = TraderFinancesLogs();
  Map<String, int>? traderWisePendingMap = {};
  Map<String, dynamic> filterMap = {'showPendingPayment': true};

  // Colors for professional look
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color warningColor = Color(0xFFEF6C00);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color neutralColor = Color(0xFF424242);
  static const Color cardColor = Colors.white;
  static const Color backgroundColor = Color(0xFFF5F5F5);
  double totalPending = 0;

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
      traderWisePendingMap!.forEach((key, value) {
        totalPending += value;
      });
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

  String formatAmount(dynamic amount) {
    if (amount == null) return '₹0';
    return '₹${(amount as num).toStringAsFixed(0)}';
  }

  Color getStatusColor(Map<String, dynamic> log) {
    final type = log['type'];
    final pending = log['pending_amount'];

    switch (type) {
      case "PAYMENT":
        return primaryColor;
      case "CLAIM":
        return neutralColor;
      case "PURCHASE":
        return (pending == 0 || pending == 0.0) ? successColor : warningColor;
      default:
        return neutralColor;
    }
  }

  IconData getTypeIcon(String type) {
    switch (type) {
      case "PAYMENT":
        return Icons.payment;
      case "CLAIM":
        return Icons.receipt_long;
      case "PURCHASE":
        return Icons.shopping_bag;
      default:
        return Icons.description;
    }
  }

  String getStatusText(Map<String, dynamic> log) {
    if (log['type'] == "PURCHASE") {
      final pending = log['pending_amount'];
      if (pending == 0 || pending == 0.0) {
        return "Paid";
      } else {
        return "Pending: ${formatAmount(pending)}";
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
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
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: errorColor),
                    const SizedBox(height: 16),
                    Text(
                      "Error loading data",
                      style: TextStyle(
                        fontSize: 16,
                        color: errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${snapshot.error}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final logs = snapshot.data ?? [];

            if (logs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      "No transactions found",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length +
                  (traderWisePendingMap != null &&
                          traderWisePendingMap!.isNotEmpty
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (traderWisePendingMap != null &&
                    index == 0 &&
                    traderWisePendingMap!.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: warningColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: warningColor.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Pending Payments",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                formatAmount(totalPending),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children:
                                traderWisePendingMap!.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      formatAmount(entry.value),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: warningColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
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
                final amount = log['amount'] ?? 0;
                final date = log['date'] ?? '';
                final trader = log['trader_name'] ?? '';
                final runningPendingPayment =
                    log['running_pending_payment'] ?? 0;
                final statusColor = getStatusColor(log);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                getTypeIcon(type),
                                color: statusColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trader,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatAmount(amount),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (type == "PURCHASE") ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      getStatusText(log),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatDate(date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (type != 'CLAIM')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Running Balance',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                formatAmount(runningPendingPayment),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ));
  }
}
