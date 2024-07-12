import 'Invoice.dart';

class DailyInvoices {
  String date;
  String soldAt;
  double sellingPrice;
  double profit;
  List<Invoice> invoices;

  DailyInvoices(
      {required this.profit,
      required this.date,
      required this.invoices,
      required this.sellingPrice,
      required this.soldAt});
}
