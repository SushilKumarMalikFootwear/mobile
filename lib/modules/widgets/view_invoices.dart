import 'package:flutter/material.dart';
import 'package:footwear/config/constants/app_constants.dart';
import 'package:footwear/modules/models/Invoice.dart';
import 'package:footwear/modules/models/daily_invoices.dart';
import 'package:footwear/modules/repository/invoice_repo.dart';
import 'package:footwear/modules/repository/product_repo.dart';
import 'package:footwear/modules/widgets/add_product.dart';
import 'package:footwear/modules/widgets/create_invoice.dart';

import '../../utils/widgets/custom_bottom_sheet.dart';
import '../../utils/widgets/toast.dart';
import '../models/product.dart';
import 'invoice_filter.dart';

class ViewInvoices extends StatefulWidget {
  const ViewInvoices({super.key});

  @override
  State<ViewInvoices> createState() => _ViewInvoicesState();
}

class _ViewInvoicesState extends State<ViewInvoices> {
  InvoiceRepository invoiceRepo = InvoiceRepository();
  ProductRepository productRepo = ProductRepository();
  Map<String, dynamic> filterMap = {};
  late Future getInvoioces;
  bool colorSwitch = true;
  bool isReversed = false;
  bool hideProfitAndCp = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getInvoioces = invoiceRepo.filterInvoices(filterMap);
  }

  applyFilter(Map<String, dynamic>? filterMap) {
    if (filterMap != null) {
      this.filterMap = filterMap;
      hideProfitAndCp = filterMap['hideProfitAndCp'];
    }
    getInvoioces = invoiceRepo.filterInvoices(this.filterMap);
    setState(() {});
  }

  double calculateTotalSelling(Map<String, DailyInvoices> dailyInvoicesMap) {
    double totalSelling = 0;
    dailyInvoicesMap.forEach((key, dailyInvoices) {
      dailyInvoices.invoices.forEach((invoice) {
        totalSelling += invoice.pendingAmount;
      });
    });
    return totalSelling;
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return FutureBuilder(
        future: getInvoioces,
        builder: ((BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
          ConnectionState state = snapshot.connectionState;
          if (state == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Some error in retrieving invoices'),
            );
          } else {
            Map<String, DailyInvoices> dailyInvoicesMap = snapshot.data;
            List<DailyInvoices> dailyInvoices =
                dailyInvoicesMap.entries.map((entry) => entry.value).toList();
            double totalSelling = calculateTotalSelling(dailyInvoicesMap);
            if (isReversed) {
              dailyInvoices = dailyInvoices.reversed.toList();
            }
            return Stack(
              children: [
                Opacity(
                  opacity: isLoading ? 0.7 : 1,
                  child: RefreshIndicator(
                    onRefresh: () {
                      getInvoioces = invoiceRepo.filterInvoices(filterMap);
                      setState(() {});
                      return Future(() => null);
                    },
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  customBottomSheet(
                                      context,
                                      InvoicesFilter(
                                        applyFilter: applyFilter,
                                        flterOptions: filterMap,
                                      ));
                                },
                                icon: const Icon(
                                  Icons.filter_alt,
                                  size: 30,
                                )),
                            if (filterMap['paymentPending'] == 'true')
                              Text(
                                'Total Selling: ₹$totalSelling',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  isReversed = !isReversed;
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.swap_vert,
                                  color:
                                      isReversed ? Colors.blue : Colors.black,
                                )),
                            IconButton(
                                onPressed: () {
                                  getInvoioces =
                                      invoiceRepo.filterInvoices(filterMap);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.refresh))
                          ],
                        ),
                        SizedBox(
                            height: deviceSize.height - 210,
                            child: ListView.builder(
                                itemCount: dailyInvoices.length,
                                itemBuilder: (BuildContext ctx, int index) {
                                  DailyInvoices dailyInvoice =
                                      dailyInvoices[index];
                                  Color cardColor = colorSwitch
                                      ? const Color(0xFFE3F2FD)
                                      : const Color(0xFFE8F5E9);
                                  colorSwitch = !colorSwitch;
                                  return Column(
                                    children: [
                                      Card(
                                        color: HSLColor.fromColor(cardColor)
                                            .withLightness(0.7)
                                            .toColor(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    dailyInvoice.date,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    dailyInvoice.soldAt,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "Selling : ₹ ${dailyInvoice.sellingPrice}",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  if (!hideProfitAndCp)
                                                    Text(
                                                      "Profit : ₹ ${dailyInvoice.profit.toStringAsFixed(2)}",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            (101 * dailyInvoice.invoices.length)
                                                .toDouble(),
                                        child: ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder:
                                              (BuildContext ctx, int i) {
                                            Invoice invoice =
                                                dailyInvoice.invoices[i];
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                  builder: (context) {
                                                    return CreateInvoice(
                                                        invoice: invoice,
                                                        refreshChild: () {
                                                          getInvoioces =
                                                              invoiceRepo
                                                                  .filterInvoices(
                                                                      filterMap);
                                                          setState(() {});
                                                        },
                                                        switchChild: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        todo: Constants.edit);
                                                  },
                                                ));
                                              },
                                              child: Card(
                                                color: invoice.invoiceStatus ==
                                                        'RETURNED'
                                                    ? const Color.fromARGB(
                                                        255, 255, 204, 204)
                                                    : invoice.paymentStatus ==
                                                            'PENDING'
                                                        ? const Color.fromARGB(
                                                            255, 255, 255, 204)
                                                        : cardColor,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () async {
                                                              if (invoice
                                                                  .productId
                                                                  .isNotEmpty) {
                                                                isLoading =
                                                                    true;
                                                                setState(() {});
                                                                Product?
                                                                    product =
                                                                    await productRepo
                                                                        .getProductById(
                                                                            invoice.productId);
                                                                isLoading =
                                                                    false;
                                                                setState(() {});
                                                                if (product !=
                                                                    null) {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => Scaffold(
                                                                              appBar: AppBar(
                                                                                title: Text('Edit Product'),
                                                                              ),
                                                                              body: AddProduct(
                                                                                () {},
                                                                                () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                Constants.edit,
                                                                                product,
                                                                                scroll: true,
                                                                              ))));
                                                                } else {
                                                                  createToast(
                                                                      'Footwear Not Found',
                                                                      ctx);
                                                                }
                                                              } else {
                                                                createToast(
                                                                    'Footwear Not Found',
                                                                    ctx);
                                                              }
                                                            },
                                                            child: Text(
                                                              invoice.article,
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                              'Color : ${invoice.color}'),
                                                          const SizedBox(
                                                            height: 3,
                                                          ),
                                                          Text(
                                                              'Size : ${invoice.size}'),
                                                          const SizedBox(
                                                            height: 3,
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                              'Selling : ₹ ${invoice.sellingPrice.toStringAsFixed(2)}'),
                                                          const SizedBox(
                                                            height: 3,
                                                          ),
                                                          if (!hideProfitAndCp)
                                                            Text(
                                                                'Cost : ₹ ${invoice.costPrice.toStringAsFixed(2)}'),
                                                          const SizedBox(
                                                            height: 3,
                                                          ),
                                                          if (!hideProfitAndCp)
                                                            Text(
                                                                'Profit : ₹ ${invoice.profit.toStringAsFixed(2)}'),
                                                          const SizedBox(
                                                            height: 3,
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          itemCount:
                                              dailyInvoice.invoices.length,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  );
                                })),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  )
              ],
            );
          }
        }));
  }
}
