import 'package:flutter/material.dart';
import 'package:footwear/utils/widgets/custom_dropdown.dart';
import 'package:footwear/utils/widgets/searchable_dropdown.dart';
import '../../config/constants/app_constants.dart';

class TraderFinancesLogsFilter extends StatefulWidget {
  final Function(Map<String, dynamic>) applyFilter;
  final Map<String, dynamic> filterOptions;

  const TraderFinancesLogsFilter({
    super.key,
    required this.applyFilter,
    required this.filterOptions,
  });

  @override
  State<TraderFinancesLogsFilter> createState() => _TraderFinancesLogsFilterState();
}

class _TraderFinancesLogsFilterState extends State<TraderFinancesLogsFilter> {
  TextEditingController traderCtrl = TextEditingController();
  String? selectedType;
  DateTime? fromDate;
  DateTime? toDate;

  final List<String> typeList = ['PURCHASE', 'PAYMENT', 'CLAIM'];

  @override
  void initState() {
    super.initState();
    traderCtrl.text = widget.filterOptions['trader_name'] ?? '';
    selectedType = widget.filterOptions['type'];
    fromDate = widget.filterOptions['fromDate'];
    toDate = widget.filterOptions['toDate'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Trader Finances Logs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Trader Name
            SearchableDropdown(
              controller: traderCtrl,
              hintText: 'Select Trader',
              onSelect: (val) {},
              onChange: (input) {
                List<String> results = [];
                for (var trader in Constants.vendorList) {
                  if (trader.toLowerCase().contains(input.toLowerCase())) {
                    results.add(trader);
                  }
                }
                return results;
              },
            ),
            const SizedBox(height: 10),

            // Type Dropdown
            CustomDropDown(
              value: selectedType,
              hint: 'Select Type',
              items: typeList,
              onChange: (val) {
                setState(() {
                  selectedType = val;
                });
              },
            ),
            const SizedBox(height: 10),

            // From Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fromDate != null ? 'From: ${fromDate!.toString().split(' ')[0]}' : 'From Date',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined, color: Colors.blue),
                  onPressed: () async {
                    final picked = await selectDate(context, fromDate ?? DateTime.now());
                    if (picked != null) {
                      setState(() {
                        fromDate = picked;
                      });
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 10),

            // To Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  toDate != null ? 'To: ${toDate!.toString().split(' ')[0]}' : 'To Date',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined, color: Colors.blue),
                  onPressed: () async {
                    final picked = await selectDate(context, toDate ?? DateTime.now());
                    if (picked != null) {
                      setState(() {
                        toDate = picked;
                      });
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final Map<String, dynamic> filters = {
                      'trader_name': traderCtrl.text,
                      'type': selectedType,
                      'fromDate': fromDate,
                      'toDate': toDate,
                    }..removeWhere((key, value) => value == null || value == '');

                    widget.applyFilter(filters);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      traderCtrl.clear();
                      selectedType = null;
                      fromDate = null;
                      toDate = null;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<DateTime?> selectDate(BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    return picked;
  }
}
