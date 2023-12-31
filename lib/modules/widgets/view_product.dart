import 'package:flutter/material.dart';
import 'package:footwear/config/constants/AppConstants.dart';
import 'package:footwear/modules/screens/product_preview.dart';
import 'package:footwear/utils/widgets/custom_bottom_sheet.dart';
import 'package:footwear/utils/widgets/custom_checkbox.dart';
import '../../utils/widgets/CustomDropdown.dart';
import '/modules/repository/product_repo.dart';
import '../models/product.dart';

class ViewProduct extends StatefulWidget {
  final bool outOfStock;

  const ViewProduct({super.key, required this.outOfStock});
  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  ProductRepository productRepo = ProductRepository();
  bool showImages = false;
  List<String> categoryList = [];
  List<String> sizeRangeList = [];
  Map<String, List<String>> configList = {};
  Map<String, String> filterMap = {};
  List<String> vendorList = [];
  TextEditingController brandNameCtrl = TextEditingController();
  TextEditingController articleCtrl = TextEditingController();
  TextEditingController colorCtrl = TextEditingController();
  String selectedSizeRange = '';
  String selectedCategory = '';
  String selectedVendor = '';

  late Product product;

  late Future getProducts;
  setConfigList() async {
    configList = await productRepo.getConfigLists();
    categoryList = configList['categoryList']!;
    sizeRangeList = configList['sizeRangeList']!;
    vendorList = configList['vendorList']!;
    setState(() {});
  }

  @override
  void initState() {
    setConfigList();
    // TODO: implement initState
    super.initState();
    getProducts = productRepo.getAllProducts(widget.outOfStock);
  }

  refreshParent() {
    filterMap = {
      'brand': brandNameCtrl.text,
      'category': selectedCategory,
      'article': articleCtrl.text,
      'size_range': selectedSizeRange,
      'color': colorCtrl.text,
      'vendor': selectedVendor
    };
    getProducts = productRepo.filterProducts(filterMap, widget.outOfStock);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return FutureBuilder(
        future: getProducts,
        builder: ((BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
          ConnectionState state = snapshot.connectionState;
          if (state == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Some error in retrieving products'),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () {
                getProducts = productRepo.filterProducts(filterMap, widget.outOfStock);
                setState(() {});
                return Future(() => null);
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomCheckBox(
                          isSelected: showImages,
                          onClicked: (value) {
                            showImages = value;
                            setState(() {});
                          },
                          label: 'Images'),
                      IconButton(
                          onPressed: () {
                            brandNameCtrl.clear();
                            articleCtrl.clear();
                            colorCtrl.clear();
                            selectedSizeRange = '';
                            selectedCategory = '';
                            selectedVendor = '';
                            customBottomSheet(
                                context,
                                Scaffold(
                                  body: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Column(
                                      children: [
                                        const Text('Filters'),
                                        TextField(
                                          controller: brandNameCtrl,
                                          decoration: const InputDecoration(
                                              labelText: 'Brand Name'),
                                        ),
                                        CustomDropDown(
                                            value: selectedCategory.isEmpty
                                                ? null
                                                : selectedCategory,
                                            hint: 'Select a Categoy',
                                            onChange: (value) {
                                              selectedCategory = value;
                                            },
                                            items: categoryList),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        CustomDropDown(
                                            value: selectedVendor.isEmpty
                                                ? null
                                                : selectedVendor,
                                            hint: 'Select a Vendor',
                                            onChange: (value) {
                                              selectedVendor = value;
                                            },
                                            items: vendorList),
                                        TextField(
                                          controller: articleCtrl,
                                          decoration: const InputDecoration(
                                              labelText: 'Article'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          child: CustomDropDown(
                                              value: selectedSizeRange.isEmpty
                                                  ? null
                                                  : selectedSizeRange,
                                              hint: 'Select Size Range',
                                              onChange: (value) {
                                                selectedSizeRange = value;
                                              },
                                              items: sizeRangeList),
                                        ),
                                        TextField(
                                          controller: colorCtrl,
                                          decoration: const InputDecoration(
                                              labelText: 'Color'),
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              filterMap = {
                                                'brand': brandNameCtrl.text,
                                                'category': selectedCategory,
                                                'article': articleCtrl.text,
                                                'size_range': selectedSizeRange,
                                                'color': colorCtrl.text,
                                                'vendor': selectedVendor
                                              };
                                              getProducts =
                                                  productRepo.filterProducts(
                                                      filterMap, widget.outOfStock);
                                              Navigator.pop(context);
                                              setState(() {});
                                            },
                                            child: const Text('Apply')),
                                        ElevatedButton(
                                            onPressed: () {
                                              filterMap.clear();
                                            },
                                            child: const Text("Reset"))
                                      ],
                                    ),
                                  ),
                                ));
                          },
                          icon: const Icon(
                            Icons.filter_alt,
                            size: 30,
                          )),
                      SizedBox(
                        width: 150,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.arrow_back_ios)),
                            const Text(
                              '1 - 10',
                              style: TextStyle(fontSize: 18),
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.arrow_forward_ios)),
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            getProducts =
                                productRepo.filterProducts(filterMap, widget.outOfStock);
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh))
                    ],
                  ),
                  SizedBox(
                    height: deviceSize.height - (widget.outOfStock?145: 210),
                    child: ListView.builder(
                      itemBuilder: (BuildContext ctx, int index) {
                        product =
                            Product.fromJSON(snapshot.data['documents'][index]);
                        String sizeAtShop = '';
                        String sizeAtHome = '';
                        for (Map<String, dynamic> element
                            in product.pairs_in_stock) {
                          if (element['available_at'] == Constants.HOME &&
                              element['quantity'] > 0) {
                            sizeAtHome = '${sizeAtHome + element['size']},';
                          }
                          if (element['available_at'] == Constants.SHOP &&
                              element['quantity'] > 0) {
                            sizeAtShop = '$sizeAtShop${element['size']},';
                          }
                        }
                        if (sizeAtHome.isNotEmpty) {
                          sizeAtHome =
                              sizeAtHome.substring(0, sizeAtHome.length - 1);
                        }
                        if (sizeAtShop.isNotEmpty) {
                          sizeAtShop =
                              sizeAtShop.substring(0, sizeAtShop.length - 1);
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ProductPreview(
                                  refreshParent: refreshParent,
                                  product: Product.fromJSON(
                                      snapshot.data['documents'][index]),
                                  sizeAtHome: sizeAtHome,
                                  sizeAtShope: sizeAtShop,
                                );
                              },
                            ));
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  if (showImages)
                                    Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.blue),
                                            borderRadius:
                                                BorderRadius.circular(2)),
                                        child: Image.network(
                                          product.URL1!,
                                          height: 170,
                                          width: 150,
                                        )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.article,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text('Color : ${product.color}'),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text('Size Range : ${product.sizeRange}'),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text('Price : ₹${product.sellingPrice}'),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text('Shop : $sizeAtShop'),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text('Home : $sizeAtHome')
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: snapshot.data['documents'].length,
                    ),
                  ),
                ],
              ),
            );
          }
        }));
  }
}
