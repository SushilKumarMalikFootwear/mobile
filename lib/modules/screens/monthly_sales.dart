import 'package:flutter/material.dart';
import 'package:footwear/modules/repository/invoice_repo.dart';

import '../../config/constants/app_constants.dart';
import '../../config/constants/drawer_options_list.dart';
import '../models/drawer_option.dart';
import '../widgets/drawer.dart';
import '../widgets/monthly_sales_card.dart';
import '../widgets/monthly_sales_graph.dart';

class MonthlySalesScreen extends StatefulWidget {
  @override
  _MonthlySalesScreenState createState() => _MonthlySalesScreenState();
}

class _MonthlySalesScreenState extends State<MonthlySalesScreen> {
  InvoiceRepository invoiceRepo = InvoiceRepository();
  bool showCard = true;
  List<Map<String, dynamic>> salesData = [];

  Map<String, dynamic> transformData(Map<String, dynamic> mongoData) {
    String monthId = mongoData['_id'] as String; // Ensure `_id` is a String

    // Convert "2025-02" to "February 2025"
    List<String> monthNames = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    List<String> parts = monthId.split("-");
    String formattedMonth = "${monthNames[int.parse(parts[1])]} ${parts[0]}";

    // Initialize final structured result
    Map<String, dynamic> result = {
      'month': formattedMonth,
      'totalSP': 0,
      'profit': 0,
      'home': <String, dynamic>{}, // Ensure proper typing
      'shop': <String, dynamic>{}, // Ensure proper typing
    };

    // Process sales data
    for (var entry in (mongoData['sales'] as List<dynamic>)) {
      Map<String, dynamic> entryMap =
          entry as Map<String, dynamic>; // Explicit cast

      String place =
          (entryMap['place'] as String).toLowerCase(); // Normalize to lowercase
      int totalSP = (entryMap['totalSP'] as num).toInt();
      int totalProfit = (entryMap['totalProfit'] as num).toInt();
      int totalInvoices = (entryMap['totalInvoices'] as num).toInt();
      int returnedInvoices = (entryMap['returnedInvoices'] as num).toInt();
      int dailyAvgSales = (entryMap['dailyAvgSales'] as num).toInt();
      int avgInvoicesPerDay = (entryMap['dailyAvgInvoices'] as num).toInt();

      // Ensure place is correctly stored in the result map
      result[place] = <String, dynamic>{
        'totalSP': totalSP,
        'profit': totalProfit,
        'totalInvoices': totalInvoices,
        'dailyAvgSales': dailyAvgSales,
        'avgInvoicesPerDay': avgInvoicesPerDay,
        'returnedInvoices': returnedInvoices,
      };

      // Update overall totals
      result['totalSP'] += totalSP;
      result['profit'] += totalProfit;
      result['isExpanded'] = false;
    }

    return result;
  }

  DrawerOptionList list = DrawerOptionList();

  @override
  void initState() {
    super.initState();
    invoiceRepo.fetchMonthlySalesReport().then((val) {
      for (int i = 0; i < val.length; i++) {
        salesData.add(transformData(val[i]));
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DrawerOption> drawerOptionList = list.drawerOptions;
    drawerOptionList = drawerOptionList.map((drawerOption) {
      if (drawerOption.name == AppBarTitle.monthlySales) {
        drawerOption.isActive = true;
        return drawerOption;
      } else {
        drawerOption.isActive = false;
        return drawerOption;
      }
    }).toList();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          AppBarTitle.monthlySales,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF34B4FF),
        elevation: 1,
      ),
      drawer: Drawer(child: MyDrawer('Sushil', drawerOptionList)),
      body: showCard
          ? MonthlySalesCard(
            key: GlobalKey(),
              salesData: salesData,
            )
          : SalesChartScreen(salesData: salesData,),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCard = !showCard;
          setState(() {});
        },
        child: Icon(
          showCard ? Icons.bar_chart : Icons.list,
          color: Colors.white,
        ),
      ),
    );
  }
}
