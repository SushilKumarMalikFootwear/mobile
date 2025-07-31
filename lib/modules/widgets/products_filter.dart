import 'package:flutter/material.dart';
import 'package:footwear/utils/widgets/searchable_dropdown.dart';
import '../../config/constants/app_constants.dart';
import '../../utils/widgets/custom_checkbox.dart';
import '../../utils/widgets/custom_dropdown.dart';

class ProductsFilter extends StatefulWidget {
  final Function applyFilter;
  Map<String, String> filterOptions;
  ProductsFilter(
      {super.key, required this.applyFilter, required this.filterOptions});

  @override
  State<ProductsFilter> createState() => _ProductsFilterState();
}

class _ProductsFilterState extends State<ProductsFilter> {
  Map<String, String> filterMap = {};
  TextEditingController brandNameCtrl = TextEditingController();
  TextEditingController articleCtrl = TextEditingController();
  TextEditingController colorCtrl = TextEditingController();
  String selectedSizeRange = '';
  String selectedCategory = '';
  String selectedVendor = '';
  bool outOfStock = false;
  bool showUnrated = false;

  @override
  void initState() {
    super.initState();
    if (widget.filterOptions.isNotEmpty) {
      if (widget.filterOptions.containsKey('brand')) {
        brandNameCtrl.text = widget.filterOptions['brand']!;
      }
      if (widget.filterOptions.containsKey('category')) {
        selectedCategory = widget.filterOptions['category']!;
      }
      if (widget.filterOptions.containsKey('article')) {
        articleCtrl.text = widget.filterOptions['article']!;
      }
      if (widget.filterOptions.containsKey('vendor')) {
        selectedVendor = widget.filterOptions['vendor']!;
      }
      if (widget.filterOptions.containsKey('color')) {
        colorCtrl.text = widget.filterOptions['color']!;
      }
      if (widget.filterOptions.containsKey('out_of_stock')) {
        outOfStock =
            widget.filterOptions['out_of_stock']!.toLowerCase() == 'true';
      }
      if (widget.filterOptions.containsKey('show_unrated')) {
        showUnrated =
            widget.filterOptions['show_unrated']!.toLowerCase() == 'true';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            const Text('Filters'),
            TextField(
              controller: brandNameCtrl,
              decoration: const InputDecoration(labelText: 'Brand Name'),
            ),
            const SizedBox(
              height: 10,
            ),
            SearchableDropdown(
                onSelect: (String val) {},
                controller: articleCtrl,
                onChange: (String val) {
                  List<String> articleList = [];
                  for (int i = 0; i < Constants.articleList.length; i++) {
                    if (Constants.articleList[i]
                        .toUpperCase()
                        .contains(val.toUpperCase())) {
                      articleList.add(Constants.articleList[i]);
                    }
                  }
                  return articleList;
                },
                hintText: "Enter Article"),
            const SizedBox(
              height: 10,
            ),
            CustomDropDown(
                value: selectedCategory.isEmpty ? null : selectedCategory,
                hint: 'Select a Categoy',
                onChange: (value) {
                  selectedCategory = value;
                },
                items: Constants.categoryList),
            const SizedBox(
              height: 10,
            ),
            CustomDropDown(
                value: selectedVendor.isEmpty ? null : selectedVendor,
                hint: 'Select a Vendor',
                onChange: (value) {
                  selectedVendor = value;
                },
                items: Constants.vendorList),
            TextField(
              controller: colorCtrl,
              decoration: const InputDecoration(labelText: 'Color'),
            ),
            CustomCheckBox(
                isSelected: outOfStock,
                onClicked: (value) {
                  outOfStock = value;
                },
                label: "Out of Stock"),
            const SizedBox(
              height: 10,
            ),
            CustomCheckBox(
                isSelected: showUnrated,
                onClicked: (value) {
                  showUnrated = value;
                },
                label: "Show Unrated"),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      filterMap = {
                        'brand': brandNameCtrl.text,
                        'category': selectedCategory,
                        'article': articleCtrl.text,
                        'color': colorCtrl.text,
                        'vendor': selectedVendor,
                        'out_of_stock': outOfStock.toString(),
                        'show_unrated': showUnrated.toString()
                      };
                      widget.applyFilter(filterMap);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text('Apply')),
                ElevatedButton(
                    onPressed: () {
                      filterMap.clear();
                      setState(() {
                        brandNameCtrl.clear();
                        articleCtrl.clear();
                        colorCtrl.clear();
                        selectedCategory = '';
                        selectedVendor = '';
                        outOfStock = false;
                      });
                    },
                    child: const Text("Reset")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
