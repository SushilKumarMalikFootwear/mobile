import 'package:flutter/material.dart';
import 'package:footwear/utils/widgets/custom_dropdown.dart';
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
  Map<String, dynamic> filterMap = {};
  TextEditingController articleCtrl = TextEditingController();
  TextEditingController colorCtrl = TextEditingController();
  TextEditingController sizeCtrl = TextEditingController();
  DateTime? selectedDate;
  bool shopChecked = false;
  bool homeChecked = false;
  bool paymentPending = false;
  bool returnedInvoice = false;
  List<String> dateRangeList = [
    'Last 30 Days',
    'Last Month',
    'Last 6 Months',
    '2024',
    '2023',
    'All'
  ];
  String selectedDateRangeOption = 'Last 30 Days';
  DateTime selectedDateRangeStartDate =
      DateTime.now().subtract(Duration(days: 30));
  DateTime selectedDateRangeEndDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            const Text('Filters'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    selectedDate != null
                        ? selectedDate.toString().split(' ')[0]
                        : 'Invoice Date',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                    padding: const EdgeInsets.only(right: 10),
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
            CustomDropDown(
                value: selectedDateRangeOption,
                hint: 'Select Date Range',
                onChange: (val) {
                  DateTime now = DateTime.now();
                  if (val == dateRangeList[0]) {
                    selectedDateRangeStartDate =
                        now.subtract(Duration(days: 30));
                    selectedDateRangeEndDate = now;
                  } else if (val == dateRangeList[1]) {
                    selectedDateRangeStartDate =
                        DateTime(now.year, now.month - 1, 1);
                    selectedDateRangeEndDate = DateTime(now.year, now.month, 0);
                  } else if (val == dateRangeList[2]) {
                    selectedDateRangeStartDate =
                        DateTime(now.year, now.month - 6, 1);
                    selectedDateRangeEndDate = DateTime(now.year, now.month, 0);
                  } else if (val == dateRangeList[3]) {
                    selectedDateRangeStartDate = DateTime(2024, 1, 1);
                    selectedDateRangeEndDate =
                        DateTime(2024, 12, 31, 23, 59, 59, 999);
                  } else if (val == dateRangeList[4]) {
                    selectedDateRangeStartDate = DateTime(2023, 1, 1);
                    selectedDateRangeEndDate =
                        DateTime(2023, 12, 31, 23, 59, 59, 999);
                  } else if (val == dateRangeList[5]) {
                    selectedDateRangeStartDate = DateTime(2023, 1, 1);
                    selectedDateRangeEndDate = now;
                  }
                },
                items: dateRangeList),
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
                        'selectedDateRangeStartDate':
                            selectedDateRangeStartDate,
                        'selectedDateRangeEndDate': selectedDateRangeEndDate
                      };
                      widget.applyFilter(filterMap);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text(
                      'Apply',
                      style: TextStyle(color: Colors.blue),
                    )),
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
                    child: const Text("Reset",
                        style: TextStyle(color: Colors.blue))),
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
