import 'package:flutter/material.dart';
import 'package:footwear/config/constants/app_constants.dart';
import 'package:footwear/modules/widgets/add_trader_finances_logs.dart';
import 'package:footwear/modules/widgets/view_trader_finances_logs.dart';

import '../../config/constants/drawer_options_list.dart';
import '../models/drawer_option.dart';
import '../widgets/drawer.dart';

class TraderFinancesLogs extends StatefulWidget {
  const TraderFinancesLogs({super.key});

  @override
  State<TraderFinancesLogs> createState() => _TraderFinancesLogsState();
}

class _TraderFinancesLogsState extends State<TraderFinancesLogs> {
  DrawerOptionList list = DrawerOptionList();
  int flag = 0;
  List<Map<String, dynamic>> _loadAllPages() {
    return [
      {
        'page': AddTraderFinancesLogs(switchChild: switchChild),
        'title': 'Add',
        'icon': Icons.add
      },
      {
        'page': const ViewTraderFinacesLogs(),
        'title': 'View',
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

  setConfigList() async {
    setState(() {});
  }

  int currentPage = 1;
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  late List<Map<String, dynamic>> _allPages;
  @override
  void initState() {
    super.initState();
    _allPages = _loadAllPages();
    setConfigList();
  }

  @override
  Widget build(BuildContext context) {
    List<DrawerOption> drawerOptionList = list.drawerOptions;
    drawerOptionList = drawerOptionList.map((drawerOption) {
      if (drawerOption.name == AppBarTitle.traderFinancesLogs) {
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
          title: Text(AppBarTitle.traderFinancesLogs),
          actions: [],
        ),
        drawer: Drawer(child: MyDrawer('Sushil', drawerOptionList)),
        body: SafeArea(
            child: Container(
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
