import 'package:flutter/material.dart';
import 'package:footwear/modules/models/product.dart';
import '../repository/product_repo.dart';
import '/modules/widgets/drawer.dart';
import '../../config/constants/app_constants.dart';
import '../../config/constants/drawer_options_list.dart';
import '../models/drawer_option.dart';
import '../widgets/add_product.dart';
import '../widgets/view_product.dart';

class ManageProducts extends StatefulWidget {
  const ManageProducts({Key? key}) : super(key: key);

  @override
  State<ManageProducts> createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  ProductRepository productRepo = ProductRepository();
  DrawerOptionList list = DrawerOptionList();
  int flag = 0;
  List<Map<String, dynamic>> _loadAllPages() {
    return [
      {
        'page':
            AddProduct(refreshChild, switchChild, Constants.create, Product()),
        'title': 'Add Product',
        'icon': Icons.add
      },
      {'page': const ViewProduct(), 'title': 'View Product', 'icon': Icons.list}
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
      if (drawerOption.name == AppBarTitle.manageProducts) {
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
