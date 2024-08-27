import 'package:flutter/material.dart';
import 'package:footwear/utils/widgets/searchable_dropdown.dart';
import '../../config/constants/app_constants.dart';
import '../../utils/widgets/custom_checkbox.dart';

class InvoicesFilter extends StatefulWidget {
  final Function applyFilter;
  const InvoicesFilter({super.key, required this.applyFilter});

  @override
  State<InvoicesFilter> createState() => _InvoicesFilterState();
}

class _InvoicesFilterState extends State<InvoicesFilter> {
  Map<String, String> filterMap = {};
  TextEditingController articleCtrl = TextEditingController();
  TextEditingController colorCtrl = TextEditingController();
  TextEditingController sizeCtrl = TextEditingController();
  DateTime? selectedDate;
  bool shopChecked = false;
  bool homeChecked = false;
  bool paymentPending = false;
  bool returnedInvoice = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            const Text('Filters'),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      selectedDate != null
                          ? selectedDate.toString().split(' ')[0]
                          : 'Invoice Date',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  IconButton(
                      padding: const EdgeInsets.only(right: 20),
                      onPressed: () async {
                        selectedDate = await selectDate(
                            context, selectedDate ?? DateTime.now());
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.blue,
                        size: 30,
                      )),
                ],
              ),
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
            TextField(
              controller: colorCtrl,
              decoration: const InputDecoration(labelText: 'Color'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: sizeCtrl,
              decoration: const InputDecoration(labelText: 'Size'),
            ),
            const SizedBox(
              height: 10,
            ),
            CustomCheckBox(
                isSelected: paymentPending,
                onClicked: (value) {
                  setState(() {
                    paymentPending = value;
                  });
                },
                label: "Pending Payment"),
            CustomCheckBox(
                isSelected: returnedInvoice,
                onClicked: (value) {
                  setState(() {
                    returnedInvoice = value;
                  });
                },
                label: "Returned Invoices"),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomCheckBox(
                    isSelected: shopChecked,
                    onClicked: (value) {
                      setState(() {
                        shopChecked = value;
                        if (shopChecked) homeChecked = false;
                      });
                    },
                    label: "Shop"),
                CustomCheckBox(
                    isSelected: homeChecked,
                    onClicked: (value) {
                      setState(() {
                        homeChecked = value;
                        if (homeChecked) shopChecked = false;
                      });
                    },
                    label: "Home"),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      filterMap = {
                        'article': articleCtrl.text,
                        'color': colorCtrl.text,
                        'size': sizeCtrl.text,
                        if (selectedDate != null)
                          'date': selectedDate.toString().split(' ')[0],
                        'soldAt': shopChecked
                            ? 'SHOP'
                            : homeChecked
                                ? 'HOME'
                                : '',
                        'paymentPending': paymentPending.toString(),
                        'returnedInvoice': returnedInvoice.toString(),
                      };
                      widget.applyFilter(filterMap);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text('Apply',style: TextStyle(color:Colors.blue),)),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        articleCtrl.clear();
                        colorCtrl.clear();
                        sizeCtrl.clear();
                        selectedDate = null;
                        shopChecked = false;
                        homeChecked = false;
                        paymentPending = true;
                        returnedInvoice = true;
                        filterMap.clear();
                      });
                    },
                    child: const Text("Reset",style: TextStyle(color:Colors.blue))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> selectDate(
      BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    return picked;
  }
}
