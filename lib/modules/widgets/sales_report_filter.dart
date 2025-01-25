import 'package:flutter/material.dart';
import 'package:footwear/modules/repository/product_repo.dart';
import 'package:footwear/utils/widgets/custom_dropdown.dart';
import 'package:footwear/utils/widgets/searchable_dropdown.dart';

class SalesReportFilter extends StatefulWidget {
  final Function applyFilter;
  final Map<String, dynamic> filterOptions;

  SalesReportFilter({
    super.key,
    required this.applyFilter,
    required this.filterOptions,
  });

  @override
  State<SalesReportFilter> createState() => _SalesReportFilterState();
}

class _SalesReportFilterState extends State<SalesReportFilter> {
  TextEditingController labelCtrl = TextEditingController();
  TextEditingController articleCtrl = TextEditingController();
  ProductRepository productRepo = ProductRepository();
  List<String> labelList = [];
  List<String> articleList = [];
  DateTime now = DateTime.now().add(Duration(days: 1));
  DateTime startDate =
      DateTime.now().add(Duration(days: 1)).subtract(Duration(days: 30));
  DateTime endDate = DateTime.now().add(Duration(days: 1));
  List<String> dateRangeList = [
    'Last 30 Days',
    'Last Month',
    'Last 6 Months',
    '2024',
    '2023',
    'All',
  ];
  String selectedDateRangeOption = 'Last 30 Days';

  @override
  void initState() {
    super.initState();
    labelCtrl.text = widget.filterOptions['label'] ?? '';
    articleCtrl.text = widget.filterOptions['article'] ?? '';
    startDate = widget.filterOptions['startDate'] ?? startDate;
    endDate = widget.filterOptions['endDate'] ?? endDate;
    selectedDateRangeOption =
        widget.filterOptions['dateRange'] ?? 'Last 30 Days';
    productRepo.getAllLables().then((val) {
      labelList = [...val];
    });
    productRepo.getAllArticles().then((val) {
      articleList = [...val];
    });
  }

  void updateDateRange(String option) {
    if (option == 'Last 30 Days') {
      startDate = now.subtract(Duration(days: 30));
      endDate = now;
    } else if (option == 'Last Month') {
      startDate = DateTime(now.year, now.month - 1, 1);
      endDate = DateTime(now.year, now.month, 0);
    } else if (option == 'Last 6 Months') {
      startDate = DateTime(now.year, now.month - 6, 1);
      endDate = DateTime(now.year, now.month, now.day);
    } else if (option == '2024') {
      startDate = DateTime(2024, 1, 1);
      endDate = DateTime(2024, 12, 31, 23, 59, 59, 999);
    } else if (option == '2023') {
      startDate = DateTime(2023, 1, 1);
      endDate = DateTime(2023, 12, 31, 23, 59, 59, 999);
    } else if (option == 'All') {
      startDate = DateTime(2000, 1, 1);
      endDate = now;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report Filters'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            SearchableDropdown(
              onSelect: (String val) {},
              controller: labelCtrl,
              onChange: (String val) async {
                return labelList
                    .where((label) =>
                        label.toUpperCase().contains(val.toUpperCase()))
                    .toList();
              },
              hintText: "Enter Label",
            ),
            const SizedBox(height: 10),
            SearchableDropdown(
              onSelect: (String val) {},
              controller: articleCtrl,
              onChange: (String val) async {
                return articleList
                    .where((article) =>
                        article.toUpperCase().contains(val.toUpperCase()))
                    .toList();
              },
              hintText: "Enter Article",
            ),
            const SizedBox(height: 10),
            CustomDropDown(
              value: selectedDateRangeOption,
              hint: 'Select Date Range',
              onChange: (val) {
                setState(() {
                  selectedDateRangeOption = val;
                  updateDateRange(val);
                });
              },
              items: dateRangeList,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        startDate.toString().split(' ')[0],
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      padding: const EdgeInsets.only(right: 10),
                      onPressed: () async {
                        startDate = await selectDate(context, startDate);
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        endDate.toString().split(' ')[0],
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      padding: const EdgeInsets.only(right: 10),
                      onPressed: () async {
                        endDate = await selectDate(context, endDate);
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.applyFilter({
                  'label': labelCtrl.text,
                  'article':articleCtrl.text,
                  'startDate': startDate,
                  'endDate': endDate,
                  'dateRange': selectedDateRangeOption
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime> selectDate(
      BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    return picked ?? initialDate;
  }
}
