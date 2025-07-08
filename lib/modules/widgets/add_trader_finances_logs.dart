import 'package:flutter/material.dart';
import 'package:footwear/modules/repository/trader_finances.dart';
import 'package:footwear/modules/repository/trader_finances_logs.dart';
import '../../config/constants/app_constants.dart';
import '../../utils/widgets/custom_checkbox.dart';

class AddTraderFinancesLogs extends StatefulWidget {
  final Function switchChild;
  const AddTraderFinancesLogs({super.key, required this.switchChild});

  @override
  State<AddTraderFinancesLogs> createState() => _AddTraderFinancesLogsState();
}

class _AddTraderFinancesLogsState extends State<AddTraderFinancesLogs> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, Map<String, Map>> billList;
  List<String> billNoList = [];
  List<String> selectedBillNoList = [];
  TraderFinancesLogs traderFinancesLogs = TraderFinancesLogs();
  TraderFinancesRepository traderFinancesRepository =
      TraderFinancesRepository();

  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMode = 'UPI';
  double remainingPaymentAmount = 0.0;
  String? _selectedTrader;
  String _selectedType = 'PURCHASE';
  String? _selectedBillId;
  List<Map> selectedBills = [];
  bool markAsPaid = false;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pendingPaymentController =
      TextEditingController();

  final List<String> _traders = Constants.vendorList;
  final List<String> _types = ['PURCHASE', 'PAYMENT', 'CLAIM'];

  @override
  void initState() {
    _selectedDate = Constants.invoiceDate;
    traderFinancesLogs.getPendingBills().then((value) {
      billList = value;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _pendingPaymentController.dispose();
    super.dispose();
  }

  calculateCurrentRemainingPaymentAmount() {
    for (var element in selectedBills) {
      var currentRemainingPaymentAmount =
          element['currentRemainingPaymentAmount'] != 'Completed'
              ? double.parse(
                  element['currentRemainingPaymentAmount'].toString())
              : 0.0;
      if (currentRemainingPaymentAmount <= remainingPaymentAmount) {
        element['currentRemainingPaymentAmount'] = 'Completed';
        remainingPaymentAmount -= currentRemainingPaymentAmount;
      }
    }
  }

  void _updatePendingPaymentIfNeeded() {
    if (_amountController.text.isNotEmpty) {
      final amount = double.tryParse(_amountController.text);
      if (_selectedType == 'PURCHASE' && amount != null && !markAsPaid) {
        _pendingPaymentController.text = amount.toStringAsFixed(2);
      } else {
        _pendingPaymentController.text = '0';
      }
      if (_selectedType == 'PAYMENT') {
        remainingPaymentAmount = double.parse(_amountController.text);
        setState(() {});
      }
    }
  }

  void handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      Constants.invoiceDate = _selectedDate;
      final Map<String, dynamic> log = {
        "id":
            '${DateTime.now().millisecondsSinceEpoch}_${_selectedTrader}_$_selectedType',
        "date": _selectedDate.toIso8601String(),
        "trader_name": _selectedTrader,
        "type": _selectedType,
        "amount": double.parse(_amountController.text),
        "description": _descriptionController.text.trim(),
      };
      if (_selectedType != 'CLAIM') {
        double runningPendingPayment = await traderFinancesLogs
            .getLastRunningPendingPayment(_selectedTrader!);
        if (_selectedType == 'PURCHASE') {
          runningPendingPayment += log['amount'];
        } else if (_selectedType == 'PAYMENT') {
          runningPendingPayment -= log['amount'];
        }
        log['running_pending_payment'] = runningPendingPayment;
      }
      if (_selectedType == 'PURCHASE') {
        log["pending_amount"] =
            double.tryParse(_pendingPaymentController.text) ?? 0;
        // final bool increaseTotalCost =
        //     await traderFinancesRepository.updateTraderTotalCostPrice(
        //         traderName: _selectedTrader!,
        //         amountToAdd: double.parse(_amountController.text));
        // if (increaseTotalCost) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Trader Total Cost Price Updated')),
        //   );
        // } else {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Unable to Update Trader Total Cost Price')),
        //   );
        // }
      } else if (_selectedType == 'PAYMENT') {
        log['bill_ids'] ={};
        log['date'] =
            _selectedDate.add(const Duration(seconds: 1)).toIso8601String();
        log['payment_mode'] = _selectedPaymentMode;
        for (int i = 0; i < selectedBills.length; i++) {
          log['bill_ids'].putIfAbsent(selectedBills[i]['id'],()=> selectedBills[i]
                          ['currentRemainingPaymentAmount'] ==
                      'Completed'
                  ? selectedBills[i]['pendingAmount']
                  : double.parse(selectedBills[i]
                          ['currentRemainingPaymentAmount']
                      .toString()));
          bool res = await traderFinancesLogs.decreasePendingAmountById(
              id: selectedBills[i]['id'],
              newPendingAmount: selectedBills[i]
                          ['currentRemainingPaymentAmount'] ==
                      'Completed'
                  ? 0
                  : double.parse(selectedBills[i]
                          ['currentRemainingPaymentAmount']
                      .toString()));
          if (res) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      '${selectedBills[i]['date'].toString().split(' ').first} bill updated Successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Unable to update ${selectedBills[i]['date'].toString().split(' ').first}')),
            );
          }
        }
      }
      final Map? doc = await traderFinancesLogs.saveTraderFinanceLog(log);

      if (doc != null) {
        Constants.invoiceDate = Constants.invoiceDate.add(const Duration(seconds: 1));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log saved successfully')),
        );
        if (markAsPaid) {
          log['description'] = '';
          log['type'] = 'PAYMENT';
          log['bill_ids'] = {log['id']:log['amount']};
          log['date'] =
              _selectedDate.add(const Duration(seconds: 1)).toIso8601String();
          log['id'] =
              '${DateTime.now().millisecondsSinceEpoch}_${_selectedTrader}_PAYMENT';
          log['payment_mode'] = 'UPI';
          log['running_pending_payment'] -= log['amount'];
          final Map? paymentDoc =
              await traderFinancesLogs.saveTraderFinanceLog(log);
          if (paymentDoc != null) {
            const SnackBar(content: Text('Payment saved successfully'));
          }
        }
        _formKey.currentState!.reset();
        setState(() {
          _selectedTrader = null;
          _selectedType = 'PURCHASE';
          _selectedDate = DateTime.now();
          _amountController.clear();
          _pendingPaymentController.clear();
          _descriptionController.clear();
        });
        widget.switchChild();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save log')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15.0, 15, 15, 0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Date', style: Theme.of(context).textTheme.labelLarge),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _selectedDate.toLocal().toString().split(' ')[0],
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Trader Name',
                border: OutlineInputBorder(),
              ),
              value: _selectedTrader,
              items: _traders
                  .map((trader) => DropdownMenuItem(
                        value: trader,
                        child: Text(trader),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTrader = value;
                  billNoList.clear();
                  _selectedBillId = null;
                  if (billList.containsKey(value)) {
                    billNoList.addAll(billList[value]!.keys.toList());
                  }
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a trader' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              value: _selectedType,
              items: _types
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _selectedBillId = null;
                  _updatePendingPaymentIfNeeded();
                });
              },
            ),
            const SizedBox(height: 10),

            if (_selectedType == 'PAYMENT')
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Payment Mode',
                  border: OutlineInputBorder(),
                ),
                value: _selectedPaymentMode,
                items: const [
                  DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                  DropdownMenuItem(value: 'CASH', child: Text('CASH'))
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMode = value!;
                  });
                },
              ),
            const SizedBox(height: 10),
            if (_selectedType == 'PAYMENT') const SizedBox(height: 10),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _updatePendingPaymentIfNeeded(),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter amount';
                if (double.tryParse(value) == null) {
                  return 'Enter valid number';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            // Dropdown for Bill ID when type is PAYMENT
            if (_selectedType == 'PAYMENT' &&
                _selectedTrader != null &&
                billNoList.isNotEmpty &&
                remainingPaymentAmount > 0)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Bill',
                  border: OutlineInputBorder(),
                ),
                value: _selectedBillId,
                items: billNoList
                    .map((billId) => DropdownMenuItem(
                          value: billId,
                          child: Text(
                            billId,
                            style: TextStyle(
                                color: selectedBillNoList.contains(billId)
                                    ? Colors.grey
                                    : Colors.black),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBillId = value;
                    if (!selectedBillNoList.contains(value)) {
                      Map<dynamic, dynamic> billData =
                          billList[_selectedTrader]![value]!;
                      billData['display'] = value;
                      _selectedBillId = null;
                      selectedBillNoList.add(value!);
                      remainingPaymentAmount -= billData['pending_amount'];
                      billData['currentRemainingPaymentAmount'] =
                          remainingPaymentAmount >= 0
                              ? 'Completed'
                              : remainingPaymentAmount * -1;
                      remainingPaymentAmount = remainingPaymentAmount < 0
                          ? 0
                          : remainingPaymentAmount;
                      selectedBills.add(billData);
                    }
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a bill' : null,
              ),
            if (_selectedType == 'PAYMENT')
              ...(selectedBills
                  .map((e) => Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e['display'] +
                                " (${e['currentRemainingPaymentAmount']})"),
                            GestureDetector(
                                onTap: () {
                                  selectedBills.remove(e);
                                  selectedBillNoList.remove(e['display']);
                                  remainingPaymentAmount += e['pending_amount'];
                                  calculateCurrentRemainingPaymentAmount();
                                  setState(() {});
                                },
                                child: const Text('X'))
                          ],
                        ),
                      ))
                  .toList()),
            const SizedBox(height: 10),

            // Pending Payment field (only for PURCHASE)
            if (_selectedType == 'PURCHASE')
              TextFormField(
                controller: _pendingPaymentController,
                decoration: const InputDecoration(
                  labelText: 'Pending Payment',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

            if (_selectedType == 'PURCHASE') const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            CustomCheckBox(
                isSelected: markAsPaid,
                label: 'Mark as Paid',
                onClicked: (val) {
                  markAsPaid = val;
                  if (markAsPaid) {
                    _pendingPaymentController.text = '0';
                  } else {
                    _pendingPaymentController.text = _amountController.text;
                  }
                }),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: handleSubmit,
              icon: const Icon(Icons.check),
              label: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
