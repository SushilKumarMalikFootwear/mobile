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
  Map<String, List<String>> configList = {};
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
    configList = await productRepo.getConfigLists();
    Constants.categoryList = configList['categoryList']!;
    Constants.vendorList = configList['vendorList']!;
    Constants.articleList = await productRepo.getAllArticles();
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

  openBottomDialog() {
    scaffoldkey.currentState?.showBottomSheet((context) {
      return Container(
        height: 200,
        color: Colors.lightBlueAccent,
        child: const Column(children: [
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone Calls'),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone Calls'),
          )
        ]),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DrawerOption> drawerOptionList = list.drawerOptions;
    drawerOptionList = drawerOptionList.map((drawerOption) {
      if (drawerOption.name == AppBarTitle.manageProducts) {
        drawerOption.isActive = true;
        return drawerOption;
      } else {
        return drawerOption;
      }
    }).toList();
    // Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    // String userid = arguments['userid'];
    // String arguments = ModalRoute.of(context)!.settings.arguments as String; // we can also use any other data type but map is standard form of sending data becuas ewe just have to call the key we don't have to remember the index of data member
    // String userid = arguments;
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
