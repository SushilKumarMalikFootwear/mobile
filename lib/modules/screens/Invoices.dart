import 'package:flutter/material.dart';
import 'package:footwear/modules/widgets/view_invoices.dart';

import '../../config/constants/app_constants.dart';
import '../../config/constants/drawer_options_list.dart';
import '../models/Invoice.dart';
import '../models/drawer_option.dart';
import '../widgets/create_invoice.dart';
import '../widgets/drawer.dart';

class Invoices extends StatefulWidget {
  const Invoices({super.key});

  @override
  State<Invoices> createState() => _InvoicesState();
}

class _InvoicesState extends State<Invoices> {
  DrawerOptionList list = DrawerOptionList();
  int flag = 0;
  Map<String, List<String>> configList = {};
  List<Map<String, dynamic>> _loadAllPages() {
    return [
      {
        'page': CreateInvoice(
            invoice: Invoice(),
            refreshChild: refreshChild,
            switchChild: switchChild,
            todo: Constants.create),
        'title': 'Create Invoice',
        'icon': Icons.add
      },
      {
        'page': const ViewInvoices(),
        'title': 'View Invoices',
        'icon': Icons.list
      }
    ];
  }

  switchChild() {
    currentPage = currentPage == 0 ? 1 : 0;
    setState(() {});
  }

  refreshChild() {
    flag++;
    setState(() {});
  }

  int currentPage = 0;
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  late List<Map<String, dynamic>> _allPages;
  @override
  void initState() {
    super.initState();
    _allPages = _loadAllPages();
  }

  @override
  Widget build(BuildContext context) {
    List<DrawerOption> drawerOptionList = list.drawerOptions;
    drawerOptionList = drawerOptionList.map((drawerOption) {
      if (drawerOption.name == AppBarTitle.invoices) {
        drawerOption.isActive = true;
        return drawerOption;
      } else {
        drawerOption.isActive = false;
        return drawerOption;
      }
    }).toList();
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        key: scaffoldkey,
        appBar: AppBar(
          title: Text(AppBarTitle.manageProducts),
          actions: [],
        ),
        drawer: Drawer(child: MyDrawer('Sushil', drawerOptionList)),
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.only(top: 10),
                child: _loadAllPages()[currentPage]['page'])),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentPage,
            onTap: (int currentPageIndex) {
              currentPage = currentPageIndex;
              setState(() {});
            },
            items: _allPages
                .map((element) => BottomNavigationBarItem(
                    icon: Icon(element['icon']), label: element['title']))
                .toList()
            // ]
            ),
      ),
    );
  }
}
