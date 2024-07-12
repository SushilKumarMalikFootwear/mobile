import 'package:flutter/material.dart';
import 'package:footwear/config/constants/app_constants.dart';
import 'package:footwear/modules/models/Invoice.dart';
import 'package:footwear/modules/models/daily_invoices.dart';
import 'package:footwear/modules/repository/invoice_repo.dart';
import 'package:footwear/modules/widgets/create_invoice.dart';

class ViewInvoices extends StatefulWidget {
  const ViewInvoices({super.key});

  @override
  State<ViewInvoices> createState() => _ViewInvoicesState();
}

class _ViewInvoicesState extends State<ViewInvoices> {
  InvoiceRepository invoiceRepo = InvoiceRepository();
  Map<String, String> filterMap = {};
  late Future getInvoioces;
  bool colorSwitch = true;

  @override
  void initState() {
    super.initState();
    getInvoioces = invoiceRepo.filterInvoices(filterMap);
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
            return RefreshIndicator(
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
                          onPressed: () {},
                          icon: const Icon(
                            Icons.filter_alt,
                            size: 30,
                          )),
                      const Spacer(),
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
                            DailyInvoices dailyInvoice = dailyInvoices[index];
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
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              dailyInvoice.soldAt,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
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
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "Profit : ₹ ${dailyInvoice.profit}",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: (88 * dailyInvoice.invoices.length)
                                      .toDouble(),
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (BuildContext ctx, int i) {
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
                                                    getInvoioces = invoiceRepo
                                                        .filterInvoices(
                                                            filterMap);
                                                    setState(() {});
                                                  },
                                                  switchChild: () {
                                                    Navigator.pop(context);
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
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      invoice.article,
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
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
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                        'Selling : ₹ ${invoice.sellingPrice}'),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),
                                                    Text(
                                                        'Cost : ₹ ${invoice.costPrice}'),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),
                                                    Text(
                                                        'Profit : ₹ ${invoice.profit}'),
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
                                    itemCount: dailyInvoice.invoices.length,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          })),
                ],
              ),
            );
          }
        }));
  }
}
