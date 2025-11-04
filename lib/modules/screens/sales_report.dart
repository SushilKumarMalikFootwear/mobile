import 'package:flutter/material.dart';
import 'package:footwear/config/constants/app_constants.dart';
import 'package:footwear/modules/widgets/sales_report_filter.dart';
import 'package:footwear/utils/widgets/custom_bottom_sheet.dart';
import '../../config/constants/drawer_options_list.dart';
import '../models/drawer_option.dart';
import '../repository/invoice_repo.dart';
import '../widgets/drawer.dart';
import 'package:d_chart/d_chart.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  DrawerOptionList list = DrawerOptionList();
  InvoiceRepository invoiceRepo = InvoiceRepository();

  // multiple filter instances
  List<Map<String, dynamic>> filterList = [];
  List<Future<Map<String, dynamic>>> futureList = [];

  void applyFilter(Map<String, dynamic> filters, {int? index}) async {
    String label = filters['label'];
    DateTime startDate = filters['startDate'];
    DateTime endDate = filters['endDate'];
    String article = filters['article'];
    String type = filters['type'];

    var future;
    if (type == 'Sizes') {
      future = invoiceRepo.fetchInvoicesForSizesSalesReport(
          article, startDate, endDate, label);
    } else if (type == 'Daily Sales') {
    } else if (type == 'Label Only') {
    } else if (type == 'All labels') {}
    if (index != null) {
      // update existing
      filterList[index] = filters;
      futureList[index] = future;
    } else {
      // add new
      filterList.add(filters);
      futureList.add(future);
    }

    setState(() {});
  }

  void deleteFilter(int index) {
    filterList.removeAt(index);
    futureList.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<DrawerOption> drawerOptionList = list.drawerOptions;
    drawerOptionList = drawerOptionList.map((drawerOption) {
      drawerOption.isActive =
          drawerOption.name == AppBarTitle.salesReport ? true : false;
      return drawerOption;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppBarTitle.salesReport),
      ),
      drawer: Drawer(child: MyDrawer('Sushil', drawerOptionList)),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filterList.length + 1, // +1 for add card
        itemBuilder: (context, index) {
          if (index == filterList.length) {
            // Add card
            return GestureDetector(
              onTap: () {
                customBottomSheet(
                  context,
                  SalesReportFilter(
                    applyFilter: (filters) => applyFilter(filters),
                    filterOptions: {},
                  ),
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  height: 120,
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 40,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ),
            );
          }

          // Existing filter card
          Map<String, dynamic> filterMap = filterList[index];
          Future<Map<String, dynamic>> salesReportFuture = futureList[index];

          return FutureBuilder(
            future: salesReportFuture,
            builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Some Error has Occurred'),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No Data Available'),
                  ),
                );
              } else {
                Map<String, dynamic> dataMap = snapshot.data!;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Label - ${filterMap['label']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.filter_alt,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    customBottomSheet(
                                      context,
                                      SalesReportFilter(
                                        applyFilter: (filters) =>
                                            applyFilter(filters, index: index),
                                        filterOptions: filterMap,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  onPressed: () => deleteFilter(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatTile(
                                "Total", dataMap['total_count'].toString()),
                            _buildStatTile(
                                "S.P.",
                                double.parse(
                                        dataMap['selling_price'].toString())
                                    .toStringAsFixed(2)),
                            _buildStatTile(
                                "C.P.",
                                double.parse(dataMap['cost_price'].toString())
                                    .toStringAsFixed(2)),
                            _buildStatTile(
                                "Profit",
                                double.parse(dataMap['profit'].toString())
                                    .toStringAsFixed(2),
                                isProfit: true),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Chart
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            height: 350,
                            width: 500,
                            padding: const EdgeInsets.all(15.0),
                            child: DChartBarCustom(
                              showDomainLabel: true,
                              listData:
                                  (dataMap['report'] as List).map((entry) {
                                final String label = entry.keys.first;
                                final num value = entry.values.first;

                                return DChartBarDataCustom(
                                  valueStyle:
                                      const TextStyle(color: Colors.white),
                                  color: Colors.teal[300],
                                  value: value.toDouble(),
                                  label: label,
                                  showValue: true,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  // Helper widget for stats
  Widget _buildStatTile(String title, String value, {bool isProfit = false}) {
    Color valueColor = Colors.black;
    if (isProfit) {
      double profit = double.tryParse(value) ?? 0;
      valueColor = profit >= 0 ? Colors.green : Colors.red;
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
