import 'package:flutter/material.dart';
import 'package:footwear/config/constants/app_constants.dart';
import 'package:footwear/modules/repository/invoice_repo.dart';
import 'package:footwear/utils/widgets/custom_checkbox.dart';
import 'package:footwear/utils/widgets/custom_dropdown.dart';
import 'package:footwear/utils/widgets/custom_text.dart';
import 'package:footwear/utils/widgets/date_picker.dart';
import 'package:footwear/utils/widgets/searchable_dropdown.dart';

import '../models/Invoice.dart';
import '../models/product.dart';

class CreateInvoice extends StatefulWidget {
  final Invoice invoice;
  final String todo;
  final Function refreshChild;
  final Function switchChild;
  const CreateInvoice(
      {super.key,
      required this.invoice,
      required this.refreshChild,
      required this.switchChild,
      required this.todo});

  @override
  State<CreateInvoice> createState() => _CreateInvoiceState();
}

class _CreateInvoiceState extends State<CreateInvoice> {
  late Invoice invoice;
  TextEditingController costPriceCtrl = TextEditingController();
  TextEditingController sellingPriceCtrl = TextEditingController();
  TextEditingController profitCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();
  TextEditingController sizeCtrl = TextEditingController();
  TextEditingController articleCtrl = TextEditingController();
  TextEditingController mrpCtrl = TextEditingController();
  bool isOldInvoice = false;
  bool addInTotalCost = false;
  Product? product;

  InvoiceRepository invoiceRepo = InvoiceRepository();

  List<String> availableSizes = [];

  @override
  void initState() {
    super.initState();
    if (widget.todo == Constants.create) {
      invoice = Invoice();
      invoice.invoiceDate = DateTime.now();
      invoice.invoiceStatus = Constants.completed;
      invoice.paymentMode = Constants.cash;
      invoice.paymentStatus = Constants.paid;
      invoice.soldAt = Constants.home;
    } else {
      invoice = widget.invoice;
      articleCtrl.text = "${invoice.article} :${invoice.color}";
      product = Constants.articleWithColorToProduct[articleCtrl.text];
      if (product != null) {
        for (var e in product!.pairs_in_stock) {
          if (e['available_at'] == Constants.home) {
            availableSizes.add(e['size']);
          }
        }
      } else {
        availableSizes = [...Constants.allSizeList];
      }
      mrpCtrl.text = invoice.mrp.toString();
      costPriceCtrl.text = invoice.costPrice.toString();
      sellingPriceCtrl.text = invoice.sellingPrice.toString();
      profitCtrl.text = invoice.profit.toString();
      descriptionCtrl.text = invoice.description;
    }
  }

  saveInvoice() async {
    invoice.costPrice = double.parse(costPriceCtrl.text);
    invoice.sellingPrice = double.parse(sellingPriceCtrl.text);
    invoice.profit = double.parse(profitCtrl.text);
    invoice.mrp = double.parse(mrpCtrl.text);
    invoice.description = descriptionCtrl.text;
    if (widget.todo == Constants.create) {
      await invoiceRepo.saveInvoice(invoice, isOldInvoice);
      widget.switchChild();
    } else {
      await invoiceRepo.updateInvoice(invoice);
      Navigator.pop(context);
      widget.refreshChild();
    }
  }

  calculateProfit(val) {
    double? sp = double.tryParse(sellingPriceCtrl.text);
    double? cp = double.tryParse(costPriceCtrl.text);
    if (sp != null && cp != null) {
      profitCtrl.text = (sp - cp).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      invoice.invoiceDate.toString().split(' ')[0],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  IconButton(
                      padding: const EdgeInsets.only(right: 20),
                      onPressed: () async {
                        invoice.invoiceDate =
                            await selectDate(context, invoice.invoiceDate);
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.blue,
                        size: 30,
                      ))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: SearchableDropdown(
                  onSelect: (val) {
                    product = Constants.articleWithColorToProduct[val];
                    invoice.article = val.toString().split(" : ")[0];
                    invoice.color = val.toString().split(" : ")[1];
                    if (product != null) {
                      invoice.vendor = product!.vendor;
                      sellingPriceCtrl.text = product!.sellingPrice;
                      costPriceCtrl.text = product!.costPrice;
                      profitCtrl.text = (double.parse(product!.sellingPrice) -
                              double.parse(product!.costPrice))
                          .toString();
                      mrpCtrl.text = product!.mrp;
                      invoice.productId = product!.footwear_id;
                      availableSizes.clear();
                      for (var e in product!.pairs_in_stock) {
                        if (e['available_at'] == Constants.home) {
                          availableSizes.add(e['size']);
                        }
                      }
                    }
                    setState(() {});
                  },
                  controller: articleCtrl,
                  onChange: (String val) {
                    List<String> articleList = [];
                    for (int i = 0;
                        i < Constants.articleWithColorList.length;
                        i++) {
                      if (Constants.articleWithColorList[i]
                          .toUpperCase()
                          .contains(val.toUpperCase())) {
                        articleList.add(Constants.articleWithColorList[i]);
                      }
                    }
                    if (articleList.isEmpty) {
                      invoice.article = val.toString().split(" : ")[0];
                      invoice.color = val.toString().split(" : ")[1];
                      availableSizes = [...Constants.allSizeList];
                      setState(() {});
                    }
                    return articleList;
                  },
                  hintText: 'Select Product'),
            ),
            CustomDropDown(
                value: invoice.vendor.isEmpty ? null : invoice.vendor,
                hint: 'Select a Vendor',
                onChange: (value) {
                  invoice.vendor = value;
                },
                items: Constants.vendorList),
            const SizedBox(height: 5),
            CustomDropDown(
                value: invoice.size.isEmpty ? null : invoice.size,
                hint: 'Select Size',
                onChange: (val) {
                  invoice.size = val;
                },
                items: availableSizes),
            const SizedBox(height: 5),
            CustomText(label: 'MRP', tc: mrpCtrl),
            const SizedBox(height: 5),
            CustomText(
                label: 'Selling Price',
                onChange: calculateProfit,
                tc: sellingPriceCtrl),
            const SizedBox(height: 5),
            CustomText(
                label: 'Cost Price',
                onChange: calculateProfit,
                tc: costPriceCtrl),
            const SizedBox(height: 5),
            CustomText(label: 'Profit', tc: profitCtrl),
            CustomDropDown(
                value: invoice.soldAt,
                hint: 'Sold At',
                onChange: (val) {
                  invoice.soldAt = val;
                },
                items: [Constants.shop, Constants.home]),
            CustomText(
                label: 'Description', tc: descriptionCtrl, isMultiLine: true),
            CustomDropDown(
                value: invoice.paymentMode,
                hint: 'Payment Mode',
                onChange: (val) {
                  invoice.paymentMode = val;
                },
                items: [Constants.cash, Constants.upi]),
            CustomDropDown(
                value: invoice.paymentStatus,
                hint: 'Payment Status',
                onChange: (val) {
                  invoice.paymentStatus = val;
                },
                items: [Constants.paid, Constants.pending]),
            CustomDropDown(
                value: invoice.invoiceStatus,
                hint: 'Invoice Status',
                onChange: (val) {
                  invoice.invoiceStatus = val;
                },
                items: [Constants.completed, Constants.returned]),
            CustomCheckBox(
                isSelected: isOldInvoice,
                onClicked: (val) {
                  isOldInvoice = val;
                },
                label: 'Old Invoice?'),
            CustomCheckBox(
                isSelected: invoice.addInTotalCost,
                onClicked: (val) {
                  invoice.addInTotalCost = val;
                },
                label: 'Add in Total Cost'),
            ElevatedButton(onPressed: saveInvoice, child: const Text('Save'))
          ]),
        ),
      ),
    );
  }
}
