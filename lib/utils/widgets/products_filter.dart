import 'package:flutter/material.dart';
import 'package:footwear/utils/widgets/searchable_dropdown.dart';
import '../../config/constants/app_constants.dart';
import 'custom_checkbox.dart';
import 'custom_dropdown.dart';

class ProductsFilter extends StatefulWidget {
  final Function applyFilter;
  const ProductsFilter({super.key, required this.applyFilter});

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
            ElevatedButton(
                onPressed: () {
                  filterMap = {
                    'brand': brandNameCtrl.text,
                    'category': selectedCategory,
                    'article': articleCtrl.text,
                    'size_range': selectedSizeRange,
                    'color': colorCtrl.text,
                    'vendor': selectedVendor,
                    'out_of_stock': outOfStock.toString()
                  };
                  widget.applyFilter(filterMap);
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
    );
  }
}
