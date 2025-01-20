import 'package:flutter/material.dart';
import 'package:footwear/config/constants/app_constants.dart';

import '../../config/constants/drawer_options_list.dart';
import '../models/drawer_option.dart';
import '../widgets/drawer.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  DrawerOptionList list = DrawerOptionList();
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
              // Add filter action here
            },
          ),
        ],
      ),
      drawer: Drawer(child: MyDrawer('Sushil', drawerOptionList)),
    );
  }
}
