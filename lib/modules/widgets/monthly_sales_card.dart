import 'package:flutter/material.dart';
import 'package:footwear/modules/repository/invoice_repo.dart';

class MonthlySalesCard extends StatefulWidget {
  final List<Map<String, dynamic>> salesData;

  const MonthlySalesCard({super.key, required this.salesData});

  @override
  State<MonthlySalesCard> createState() => _MonthlySalesCardState();
}

class _MonthlySalesCardState extends State<MonthlySalesCard> {
  late List<Map<String, dynamic>> salesData;
  late Future<Map<String, dynamic>> rollingCommparisonFuture;
  late Future<Map<String, dynamic>> currentMonthComparisonFuture;
  InvoiceRepository invoiceRepo = InvoiceRepository();

  @override
  void initState() {
    rollingCommparisonFuture = invoiceRepo.getRolling12MonthComparison();
    currentMonthComparisonFuture = invoiceRepo.getCurrentMonthMTDComparison();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    salesData = processMonthlyData(widget.salesData.reversed.toList());

    return Column(
      children: [
        FutureBuilder(
          future: rollingCommparisonFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return _buildRollingComparisonCard(snapshot.data!);
            }
          },
        ),

        FutureBuilder(
          future: currentMonthComparisonFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return _buildExpandableMonthCard(
                salesData[0],
                snapshot.data ?? {},
              );
            }
          },
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: salesData.length - 1,
            itemBuilder: (context, index) {
              return _buildExpandableMonthCard(salesData[index + 1], {});
            },
          ),
        ),
      ],
    );
  }

  // =====================================================
  // 🔥 DATA PROCESSING
  // =====================================================

  List<Map<String, dynamic>> processMonthlyData(
    List<Map<String, dynamic>> data,
  ) {
    Map<DateTime, Map<String, dynamic>> lookup = {};

    for (var item in data) {
      DateTime date = parseMonth(item['month']);
      lookup[date] = item;
    }

    for (var item in data) {
      DateTime currentDate = parseMonth(item['month']);

      DateTime prevMonth = DateTime(currentDate.year, currentDate.month - 1);

      DateTime lastYear = DateTime(currentDate.year - 1, currentDate.month);

      item['prevMonthSP'] = lookup[prevMonth]?['totalSP'] ?? 0;
      item['prevMonthProfit'] = lookup[prevMonth]?['profit'] ?? 0;

      item['lastYearSP'] = lookup[lastYear]?['totalSP'] ?? 0;
      item['lastYearProfit'] = lookup[lastYear]?['profit'] ?? 0;
    }

    return data;
  }

  DateTime parseMonth(String monthStr) {
    final parts = monthStr.split(" ");
    final monthName = parts[0];
    final year = int.parse(parts[1]);

    final monthNumber =
        {
          "January": 1,
          "February": 2,
          "March": 3,
          "April": 4,
          "May": 5,
          "June": 6,
          "July": 7,
          "August": 8,
          "September": 9,
          "October": 10,
          "November": 11,
          "December": 12,
        }[monthName]!;

    return DateTime(year, monthNumber);
  }

  double calculatePercentageChange(num current, num previous) {
    if (previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }

  // =====================================================
  // 🔥 TOP ROLLING 12 MONTH CARD
  // =====================================================

  Widget _buildRollingComparisonCard(Map<String, dynamic> comparison) {
    if (comparison.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(12),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Last 12 Months vs Previous 12 Months",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildYearComparisonRow(
                    title: "Sales",
                    current: comparison["currentSales"] ?? 0,
                    previous: comparison["previousSales"] ?? 0,
                  ),

                  _buildYearComparisonRow(
                    title: "Profit",
                    current: comparison["currentProfit"] ?? 0,
                    previous: comparison["previousProfit"] ?? 0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearComparisonRow({
    required String title,
    required num current,
    required num previous,
  }) {
    double change = calculatePercentageChange(current, previous);
    bool isPositive = change >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ₹${formatAmount(current)}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: isPositive ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              "${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 10),
            Text("₹ $previous"),
          ],
        ),
      ],
    );
  }

  // =====================================================
  // 🔥 MONTH CARD UI
  // =====================================================

  Widget _buildExpandableMonthCard(
    Map<String, dynamic> data,
    Map<String, dynamic> currentMonthComparisonData,
  ) {
    bool isCurrentMonth = currentMonthComparisonData.isNotEmpty;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Text(
                      data['month'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      data['isExpanded'] ?? false
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                    onPressed: () {
                      data['isExpanded'] = !(data['isExpanded'] ?? false);
                      setState(() {});
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricSection(
                      title: "Sales",
                      amount: data['totalSP'] ?? 0,
                      prevMonth:
                          isCurrentMonth
                              ? currentMonthComparisonData['prevMonthSales'] ??
                                  0
                              : data['prevMonthSP'] ?? 0,
                      lastYear:
                          isCurrentMonth
                              ? currentMonthComparisonData['lastYearSales'] ?? 0
                              : data['lastYearSP'] ?? 0,
                    ),
                    _buildMetricSection(
                      title: "Profit",
                      amount: data['profit'] ?? 0,
                      prevMonth:
                          isCurrentMonth
                              ? currentMonthComparisonData['prevMonthProfit'] ??
                                  0
                              : data['prevMonthProfit'] ?? 0,
                      lastYear:
                          isCurrentMonth
                              ? currentMonthComparisonData['lastYearProfit'] ??
                                  0
                              : data['lastYearProfit'] ?? 0,
                    ),
                  ],
                ),
              ),

              if (data['isExpanded'] ?? false) _buildChannelTabs(data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricSection({
    required String title,
    required num amount,
    required num prevMonth,
    required num lastYear,
  }) {
    double monthChange = calculatePercentageChange(amount, prevMonth);
    double yearChange = calculatePercentageChange(amount, lastYear);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ₹${formatAmount(amount)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        _buildPercentageText("Last Month", monthChange),
        _buildPercentageText("Last Year", yearChange),
      ],
    );
  }

  Widget _buildPercentageText(String label, double value) {
    bool isPositive = value >= 0;

    return Row(
      children: [
        Text("$label: ", style: const TextStyle(fontSize: 12)),
        Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          size: 12,
          color: isPositive ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 2),
        Text(
          "${isPositive ? '+' : ''}${value.toStringAsFixed(1)}%",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildChannelTabs(Map<String, dynamic> data) {
    return Column(
      children: [
        if (data['shop'] != null) _buildChannelDetails(data['shop'], 'Shop'),
        if (data['home'] != null) _buildChannelDetails(data['home'], 'Home'),
      ],
    );
  }

  Widget _buildChannelDetails(
    Map<String, dynamic> channelData,
    String channelName,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        color:
            channelName == "Home"
                ? const Color.fromRGBO(16, 58, 97, 1)
                : const Color.fromRGBO(52, 180, 255, 1),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channelName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildStatRow(
                'Total Sales Price',
                '₹${formatAmount(channelData['totalSP'])}',
              ),
              _buildStatRow(
                'Profit',
                '₹${formatAmount(channelData['profit'])}',
              ),
              _buildStatRow(
                'Daily Avg Sales',
                '₹${formatAmount(channelData['dailyAvgSales'])}',
              ),
              _buildStatRow(
                'Total Invoices',
                '${channelData['totalInvoices']}',
              ),
              _buildStatRow(
                'Avg Invoices/Day',
                '${channelData['avgInvoicesPerDay']}',
              ),
              _buildStatRow(
                'Returned Invoices',
                '${channelData['returnedInvoices']}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String formatAmount(num amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
