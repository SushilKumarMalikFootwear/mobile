import 'package:flutter/material.dart';
import 'package:footwear/config/constants/app_constants.dart';
import 'package:footwear/modules/models/Invoice.dart';
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
                      itemBuilder: (BuildContext ctx, int index) {
                        Invoice invoice =
                            Invoice.fromJson(snapshot.data['documents'][index]);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return CreateInvoice(
                                    invoice: invoice,
                                    refreshChild: () {},
                                    switchChild: () {},
                                    todo: Constants.edit);
                              },
                            ));
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        invoice.invoiceDate
                                            .toString()
                                            .split(' ')[0],
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        invoice.article,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text('Color : ${invoice.color}'),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text('Size : ${invoice.size}'),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          'Selling : ₹ ${invoice.sellingPrice}'),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text('Cost : ₹ ${invoice.costPrice}'),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text('Profit : ₹ ${invoice.profit}'),
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
                      itemCount: snapshot.data['documents'].length,
                    ),
                  ),
                ],
              ),
            );
          }
        }));
  }
}
