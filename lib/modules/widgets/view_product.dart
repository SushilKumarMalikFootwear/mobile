import 'package:flutter/material.dart';
import 'package:footwear/config/constants/app_constants.dart';
import 'package:footwear/modules/screens/product_preview.dart';
import 'package:footwear/utils/widgets/custom_bottom_sheet.dart';
import 'package:footwear/utils/widgets/custom_checkbox.dart';
import '../../utils/widgets/products_filter.dart';
import '/modules/repository/product_repo.dart';
import '../models/product.dart';

class ViewProduct extends StatefulWidget {
  const ViewProduct({super.key});
  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  ProductRepository productRepo = ProductRepository();
  bool showImages = false;
  Map<String, String> filterMap = {};

  late Product product;

  late Future getProducts;

  @override
  void initState() {
    super.initState();
    getProducts = productRepo.getAllProducts();
  }

  applyFilter(Map<String, String>? filterMap) {
    if (filterMap != null) {
      this.filterMap = filterMap;
    }
    getProducts = productRepo.filterProducts(this.filterMap);
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
                getProducts = productRepo.filterProducts(filterMap);
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
                      const SizedBox(width: 15),
                      IconButton(
                          onPressed: () {
                            customBottomSheet(context,
                                ProductsFilter(applyFilter: applyFilter));
                          },
                          icon: const Icon(
                            Icons.filter_alt,
                            size: 30,
                          )),
                      const Spacer(),
                      IconButton(
                          onPressed: () {
                            getProducts = productRepo.filterProducts(filterMap);
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh))
                    ],
                  ),
                  SizedBox(
                    height: deviceSize.height - 210,
                    child: ListView.builder(
                      itemBuilder: (BuildContext ctx, int index) {
                        product =
                            Product.fromJSON(snapshot.data['documents'][index]);
                        String sizeAtShop = '';
                        String sizeAtHome = '';
                        for (Map<String, dynamic> element
                            in product.pairs_in_stock) {
                          if (element['available_at'] == Constants.home &&
                              element['quantity'] > 0) {
                            sizeAtHome = '${sizeAtHome + element['size']},';
                          }
                          if (element['available_at'] == Constants.shop &&
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
                                  refreshParent: () {
                                    applyFilter(filterMap);
                                  },
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
