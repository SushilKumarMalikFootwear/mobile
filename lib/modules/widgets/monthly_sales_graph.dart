import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesData {
  final String month;
  final String place;
  final double totalSP;
  final double totalProfit;
  final int monthIndex; // Added to help with sorting

  SalesData({
    required this.month,
    required this.place,
    required this.totalSP,
    required this.totalProfit,
    required this.monthIndex,
  });

  factory SalesData.fromMap(
      Map<String, dynamic> map, String month, String place, int monthIndex) {
    return SalesData(
      month: month,
      place: place,
      totalSP: (map['totalSP'] ?? 0).toDouble(),
      totalProfit: (map['profit'] ?? 0).toDouble(),
      monthIndex: monthIndex,
    );
  }
}

class SalesChartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> salesData;

  const SalesChartScreen({super.key, required this.salesData});
  @override
  _SalesChartScreenState createState() => _SalesChartScreenState();
}

class _SalesChartScreenState extends State<SalesChartScreen> {
  String selectedPreviousFinancialYear = "";
  bool showComparison = false;
  bool showFilters = false;
  String filterType = 'Total Sales';
  String placeFilter = 'shop';
  String selectedMetric = 'totalSP';
  Map<String, List<Map<String, dynamic>>> processedData = {};
  DateTime now = DateTime.now();

  final ScrollController _scrollController = ScrollController();
  final double _chartWidth = 80.0;

  List<SalesData> currentYearData = [];
  List<SalesData> previousYearData = [];

  int selectedCurrentYear = DateTime.now().year;
  int selectedPreviousYear = DateTime.now().year - 1;

  String selectedFinancialYear = "";
  List<String> availableFinancialYears = [];

  @override
  void initState() {
    super.initState();
    int currentYear = now.year;
    int startYear = 2023;

    if (now.month >= 4) {
      selectedFinancialYear = "$currentYear-${(currentYear + 1) % 100}";
    } else {
      selectedFinancialYear = "${currentYear - 1}-${currentYear % 100}";
    }

    int lastYear = (now.month >= 4) ? currentYear : currentYear - 1;

    for (int year = startYear; year <= lastYear; year++) {
      String nextYearCode = (year + 1) % 100 < 10
          ? "0${(year + 1) % 100}"
          : "${(year + 1) % 100}";
      availableFinancialYears.add("$year-$nextYearCode");
    }

    if (availableFinancialYears.length > 1) {
      selectedPreviousFinancialYear =
          availableFinancialYears[availableFinancialYears.length - 2];
    }

    _processDataByFinancialYear();
    populateWithEmptyData();
    _processFinancialYearData();
  }

  void _processDataByFinancialYear() {
    processedData.clear();

    for (var map in widget.salesData) {
      // Extract month and year from the month field
      String monthStr = map['month'].toString();
      List<String> parts = monthStr.split(' ');
      if (parts.length < 2) continue; // Skip invalid data

      String monthName = parts[0]; // Month name
      int year = int.parse(parts[1]); // Year

      // Determine the financial year
      int fyStartYear, fyEndYear;
      int monthNum = _getMonthNumber(monthName);

      if (monthNum >= 4) {
        // April to March is a financial year
        fyStartYear = year;
        fyEndYear = year + 1;
      } else {
        fyStartYear = year - 1;
        fyEndYear = year;
      }

      String fyEndYearCode =
          (fyEndYear % 100 < 10) ? "0${fyEndYear % 100}" : "${fyEndYear % 100}";

      String financialYear = "$fyStartYear-$fyEndYearCode";

      // Group by financial year
      if (!processedData.containsKey(financialYear)) {
        processedData[financialYear] = [];
      }
      processedData[financialYear]!.add(map);
    }
  }

  populateWithEmptyData() {
    List<Map<String, dynamic>> currentData;
    // Define financial year range: April to March
    final DateTime now = DateTime.now();
    final int currentYear = now.month >= 4 ? now.year : now.year - 1;
    final financialYear =
        '${DateTime.now().month >= 4 ? DateTime.now().year : DateTime.now().year - 1}-${(DateTime.now().month >= 4 ? DateTime.now().year + 1 : DateTime.now().year).toString().substring(2)}';
    currentData = processedData[financialYear]!;
    // Create a set of months already present in the input data
    final Set<String> presentMonths =
        currentData.map((e) => e['month'] as String).toSet();

    // List of all months in financial year order
    final List<String> financialMonths = [
      'April $currentYear',
      'May $currentYear',
      'June $currentYear',
      'July $currentYear',
      'August $currentYear',
      'September $currentYear',
      'October $currentYear',
      'November $currentYear',
      'December $currentYear',
      'January ${currentYear + 1}',
      'February ${currentYear + 1}',
      'March ${currentYear + 1}',
    ];

    // Template for empty month data
    Map<String, dynamic> emptyMonthTemplate(String month) {
      return {
        'month': month,
        'totalSP': 0,
        'profit': 0,
        'home': {
          'totalSP': 0,
          'profit': 0,
          'totalInvoices': 0,
          'dailyAvgSales': 0,
          'avgInvoicesPerDay': 0,
          'returnedInvoices': 0,
        },
        'shop': {
          'totalSP': 0,
          'profit': 0,
          'totalInvoices': 0,
          'dailyAvgSales': 0,
          'avgInvoicesPerDay': 0,
          'returnedInvoices': 0,
        },
        'isExpanded': false,
      };
    }

    // Create a map for quick lookup from the input data
    final Map<String, Map<String, dynamic>> monthDataMap = {
      for (var item in currentData) item['month']: item
    };

    // Build final processed data with all months
    processedData[financialYear] = financialMonths.map((month) {
      return monthDataMap[month] ?? emptyMonthTemplate(month);
    }).toList();
  }

  void _processFinancialYearData() {
    // Clear previous data
    currentYearData = [];
    previousYearData = [];

    // Process current financial year data
    if (processedData.containsKey(selectedFinancialYear)) {
      currentYearData = _extractYearData(selectedFinancialYear, placeFilter);
    }

    // Process previous financial year data if comparison is enabled
    if (showComparison &&
        processedData.containsKey(selectedPreviousFinancialYear)) {
      previousYearData =
          _extractYearData(selectedPreviousFinancialYear, placeFilter);
    }

    // Ensure the chart is updated
    setState(() {});
  }

  List<SalesData> _extractYearData(String financialYear, String placeFilter) {
    List<SalesData> result = [];

    if (!processedData.containsKey(financialYear)) {
      return result;
    }

    // Extract year data
    for (var entry in processedData[financialYear]!) {
      String monthName = entry['month'].toString().split(' ')[0];
      int monthNum = _getMonthNumber(monthName);

      // Calculate financial year month index (April = 0, May = 1, ..., March = 11)
      int fyMonthIndex = (monthNum + 8) % 12; // Corrected indexing

      Map<String, dynamic> dataForPlace;
      if (placeFilter == 'both') {
        // Combine home and shop data
        Map<dynamic, dynamic> homeData = entry['home'] ?? {};
        Map<dynamic, dynamic> shopData = entry['shop'] ?? {};

        double totalSP = (homeData['totalSP'] ?? 0).toDouble() +
            (shopData['totalSP'] ?? 0).toDouble();
        double totalProfit = (homeData['profit'] ?? 0).toDouble() +
            (shopData['profit'] ?? 0).toDouble();

        dataForPlace = {
          'totalSP': totalSP,
          'profit': totalProfit,
        };
      } else if (placeFilter == 'home' || placeFilter == 'shop') {
        // Use specific place data
        if (entry[placeFilter] != null &&
            (entry[placeFilter] as Map).isNotEmpty) {
          dataForPlace = Map<String, dynamic>.from(entry[placeFilter]);
        } else if (placeFilter == 'shop' && entry['totalSP'] != null) {
          // Fallback for older data format
          dataForPlace = {
            'totalSP': entry['totalSP'],
            'profit': entry['profit'],
          };
        } else {
          // Skip if no data for this place
          continue;
        }
      } else {
        continue;
      }
      result.add(SalesData.fromMap(
          dataForPlace, monthName, placeFilter, fyMonthIndex));
    }

    // Ensure every month is represented in the result
    for (int i = 0; i < 12; i++) {
      if (result.indexWhere((data) => data.monthIndex == i) == -1) {
        String monthName = _getMonthName((i + 4) % 12);
        result.add(SalesData(
          month: monthName,
          place: placeFilter,
          totalSP: 0,
          totalProfit: 0,
          monthIndex: i,
        ));
      }
    }

    // Sort again after adding missing months
    result.sort((a, b) => a.monthIndex.compareTo(b.monthIndex));
    return result;
  }

  // Helper function to convert month index to name
  String _getMonthName(int monthIndex) {
    final months = [
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
      'January',
      'February',
      'March'
    ];
    return months[monthIndex];
  }

  Widget _buildFinancialYearFilter() {
    return Row(
      children: [
        const Text(
          'From:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedFinancialYear,
            underline: Container(
              height: 1,
              color: Colors.blue.shade300,
            ),
            items: availableFinancialYears.map((String fy) {
              return DropdownMenuItem<String>(
                value: fy,
                child: Text("FY $fy"),
              );
            }).toList(),
            onChanged: (val) {
              if (val == null) return;

              setState(() {
                selectedFinancialYear = val;

                // Calculate the comparison financial year (previous year)
                if (showComparison) {
                  // Extract the years from the selected financial year (format: "2023-24")
                  List<String> yearParts = selectedFinancialYear.split('-');
                  if (yearParts.length == 2) {
                    int startYear = int.parse(yearParts[0]);
                    // Create the previous financial year string
                    int prevStartYear = startYear - 1;
                    String prevEndYearCode = (prevStartYear + 1) % 100 < 10
                        ? "0${(prevStartYear + 1) % 100}"
                        : "${(prevStartYear + 1) % 100}";

                    String prevFinancialYear =
                        "$prevStartYear-$prevEndYearCode";

                    // Check if this financial year exists in our available years
                    if (availableFinancialYears.contains(prevFinancialYear)) {
                      selectedPreviousFinancialYear = prevFinancialYear;
                    }
                  }
                }
                _processFinancialYearData();
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        if (showComparison) ...[
          const Text(
            'to:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedPreviousFinancialYear,
              underline: Container(
                height: 1,
                color: Colors.orange.shade300,
              ),
              items: availableFinancialYears.map((String fy) {
                return DropdownMenuItem<String>(
                  value: fy,
                  child: Text("FY $fy"),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;

                setState(() {
                  selectedPreviousFinancialYear = val;
                  _processFinancialYearData();
                });
              },
            ),
          ),
        ],
      ],
    );
  }

  // Helper function to convert month name to number
  int _getMonthNumber(String monthName) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return months.indexOf(monthName) + 1;
  }

  // Update selected metric based on filter type
  void _updateSelectedMetric(String filter) {
    switch (filter) {
      case 'Total Sales':
        selectedMetric = 'totalSP';
        break;
      case 'Profit':
        selectedMetric = 'totalProfit';
        break;
      default:
        selectedMetric = 'totalSP';
    }
  }

  List<FlSpot> _getChartData(List<SalesData> data) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      double value = 0;

      switch (selectedMetric) {
        case 'totalSP':
          value = data[i].totalSP;
          break;
        case 'totalProfit':
          value = data[i].totalProfit;
          break;
        default:
          value = data[i].totalSP;
      }

      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total width needed for the chart
    final double totalWidth = max(
        (currentYearData.isEmpty ? 0 : currentYearData.length) * _chartWidth,
        400.0);
    final double screenWidth =
        MediaQuery.of(context).size.width - 64; // Subtracting padding
    final bool needsScrolling = totalWidth > screenWidth;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.blue.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  showFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: Colors.blue.shade800,
                ),
                onPressed: () {
                  setState(() {
                    showFilters = !showFilters;
                  });
                },
              ),
              Text(
                filterType,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Row(
                children: [
                  Switch(
                    value: showComparison,
                    activeColor: Colors.blue.shade700,
                    onChanged: (val) {
                      setState(() {
                        showComparison = val;
                        if (val && availableFinancialYears.length > 1) {
                          // Get the previous financial year for comparison
                          List<String> yearParts =
                              selectedFinancialYear.split('-');
                          if (yearParts.length == 2) {
                            int startYear = int.parse(yearParts[0]);
                            int prevStartYear = startYear - 1;
                            String prevEndYearCode =
                                (prevStartYear + 1) % 100 < 10
                                    ? "0${(prevStartYear + 1) % 100}"
                                    : "${(prevStartYear + 1) % 100}";

                            String prevFinancialYear =
                                "$prevStartYear-$prevEndYearCode";

                            // Check if this financial year exists in our available years
                            if (availableFinancialYears
                                .contains(prevFinancialYear)) {
                              selectedPreviousFinancialYear = prevFinancialYear;
                            }
                          }
                        }
                        _processFinancialYearData();
                      });
                    },
                  ),
                  Text(
                    "Compare with \nprevious year",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Filters (collapsible)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: showFilters ? 200 : 0, // Fixed height
          color: Colors.blue.shade100,
          clipBehavior: Clip.antiAlias, // Prevents rendering issues
          child: showFilters
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Metric selection row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Metric:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ToggleButtons(
                              borderRadius: BorderRadius.circular(8),
                              borderColor: Colors.blue.shade300,
                              borderWidth: 1,
                              selectedBorderColor: Colors.blue.shade300,
                              selectedColor: Colors.white,
                              fillColor: Colors.blue.shade300,
                              isSelected: [
                                filterType == 'Total Sales',
                                filterType == 'Profit'
                              ],
                              onPressed: (int index) {
                                setState(() {
                                  filterType =
                                      index == 0 ? 'Total Sales' : 'Profit';
                                  _updateSelectedMetric(filterType);
                                  _processFinancialYearData();
                                });
                              },
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Total Sales'),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('Profit'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Year selection row
                        _buildFinancialYearFilter(),
                        // Location selection row
                        Row(
                          children: [
                            const Text(
                              'Location:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: placeFilter,
                                underline: Container(
                                  height: 1,
                                  color: Colors.blue.shade300,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: "shop", child: Text("SHOP")),
                                  DropdownMenuItem(
                                      value: "home", child: Text("HOME")),
                                  DropdownMenuItem(
                                      value: "both", child: Text("BOTH")),
                                ],
                                onChanged: (val) {
                                  if (val == null) return;

                                  setState(() {
                                    placeFilter = val;
                                    _processFinancialYearData();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        ),

        // Chart section with horizontal scrolling
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (needsScrolling)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swipe,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            "Swipe to see all months",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Financial year info
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("FY: $selectedFinancialYear",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800)),
                        Text("Months: ${currentYearData.length}",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),

                  // Scrollable chart
                  Expanded(
                    child: currentYearData.isEmpty
                        ? Center(
                            child: Text(
                                "No data available for selected filters",
                                style: TextStyle(color: Colors.grey.shade600)))
                        : SingleChildScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Container(
                              width: max(totalWidth, screenWidth),
                              padding: const EdgeInsets.only(
                                  top: 150.0,
                                  left: 20.0,
                                  right: 60.0,
                                  bottom: 20),
                              child: LineChart(
                                LineChartData(
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipItems:
                                          (List<LineBarSpot> touchedBarSpots) {
                                        return touchedBarSpots.map((barSpot) {
                                          final index = barSpot.x.toInt();
                                          final value = barSpot.y;
                                          final isCurrentYear =
                                              barSpot.barIndex == 0;

                                          String monthName = "";
                                          if (isCurrentYear &&
                                              index >= 0 &&
                                              index < currentYearData.length) {
                                            monthName =
                                                currentYearData[index].month;
                                          } else if (!isCurrentYear &&
                                              index >= 0 &&
                                              index < previousYearData.length) {
                                            monthName =
                                                previousYearData[index].month;
                                          }

                                          String label =
                                              _formatTooltipValue(value);

                                          String yearInfo = isCurrentYear
                                              ? "FY $selectedFinancialYear"
                                              : "FY $selectedPreviousFinancialYear";

                                          return LineTooltipItem(
                                            '$monthName ($yearInfo)\n$label',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: true,
                                    horizontalInterval: _getYAxisInterval(),
                                    verticalInterval: 1,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.shade200,
                                        strokeWidth: 1,
                                      );
                                    },
                                    getDrawingVerticalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.shade200,
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: 1,
                                        getTitlesWidget: (value, _) {
                                          int index = value.toInt();
                                          if (index >= 0) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                currentYearData[index].month,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          }

                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 50,
                                        getTitlesWidget: (value, meta) {
                                          String text =
                                              _formatYAxisLabel(value);
                                          return Text(
                                            text,
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 10,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX: (currentYearData.length - 1).toDouble(),
                                  minY: 0,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _getChartData(currentYearData),
                                      isCurved: true,
                                      barWidth: 4,
                                      color: Colors.blue.shade600,
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.blue.withOpacity(0.1),
                                      ),
                                      dotData: FlDotData(show: true),
                                    ),
                                    if (showComparison &&
                                        previousYearData.isNotEmpty)
                                      LineChartBarData(
                                        spots: _getChartData(previousYearData),
                                        isCurved: true,
                                        barWidth: 3,
                                        color: Colors.orange,
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.orange.withOpacity(0.1),
                                        ),
                                        dotData: FlDotData(show: true),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Legend for comparison
        if (showComparison)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                    "FY $selectedFinancialYear", Colors.blue.shade600),
                const SizedBox(width: 24),
                _buildLegendItem(
                    "FY $selectedPreviousFinancialYear", Colors.orange),
              ],
            ),
          ),
      ],
    );
  }

  double max(double a, double b) {
    return a > b ? a : b;
  }

  double _getYAxisInterval() {
    // Determine appropriate interval based on data range
    double maxValue = 0;

    for (var data in currentYearData) {
      double value =
          selectedMetric == 'totalSP' ? data.totalSP : data.totalProfit;
      if (value > maxValue) maxValue = value;
    }

    if (showComparison) {
      for (var data in previousYearData) {
        double value =
            selectedMetric == 'totalSP' ? data.totalSP : data.totalProfit;
        if (value > maxValue) maxValue = value;
      }
    }

    if (maxValue <= 10000) return 1000;
    if (maxValue <= 50000) return 5000;
    if (maxValue <= 100000) return 10000;
    if (maxValue <= 150000) return 15000;
    return 20000;
  }

  String _formatYAxisLabel(double value) {
    // Format y-axis labels
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }

  String _formatTooltipValue(double value) {
    // Format tooltip values based on selected metric
    return '₹${value.toStringAsFixed(0)}';
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
