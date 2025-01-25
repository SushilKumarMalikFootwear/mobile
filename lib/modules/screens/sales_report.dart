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
  Map<String, dynamic> filterMap = {};
  Future<Map<String, int>> salesReportFuture = Future.value({});

  applyFilter(Map<String, dynamic> filters) async {
    filterMap = filters;
    String label = filters['label'];
    DateTime startDate = filters['startDate'];
    DateTime endDate = filters['endDate'];
    String article = filters['article'];
    salesReportFuture = invoiceRepo.fetchInvoicesForSalesReport(
        article, startDate, endDate, label);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<DrawerOption> drawerOptionList = list.drawerOptions;
    drawerOptionList = drawerOptionList.map((drawerOption) {
      if (drawerOption.name == AppBarTitle.salesReport) {
        drawerOption.isActive = true;
        return drawerOption;
      } else {
        drawerOption.isActive = false;
        return drawerOption;
      }
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppBarTitle.salesReport),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              customBottomSheet(
                  context,
                  SalesReportFilter(
                      applyFilter: applyFilter, filterOptions: filterMap));
            },
          ),
        ],
      ),
      drawer: Drawer(child: MyDrawer('Sushil', drawerOptionList)),
      body: FutureBuilder(
          future: salesReportFuture,
          builder: (context, AsyncSnapshot<Map<String, int>> snapshot) {
            if (snapshot.hasError) {
              print(snapshot);
              return Center(
                child: Text('Some Error hass Occcurred'),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Center(
                child: Text('No Data Available'),
              );
            } else {
              return Column(
                children: [
                  Text('Label - ${filterMap['label']}'),
                  Container(
              height: 350,
              padding: const EdgeInsets.all(10.0),
                    child: DChartBarCustom(
                      showDomainLabel: true,
                      listData: snapshot.data!.entries.map((entry) {
                        return DChartBarDataCustom(
                          valueStyle: TextStyle(color: Colors.white),
                          color: Colors.teal[300],
                          value: entry.value.toDouble(),
                          label: entry.key.toString(),
                          showValue: true,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}
