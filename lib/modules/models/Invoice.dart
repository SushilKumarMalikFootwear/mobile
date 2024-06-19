class Invoice {
  late String invoiceNo;
  late DateTime invoiceDate;
  late String productId;
  late double costPrice;
  late double sellingPrice;
  late double profit;
  late String description;
  late String size;
  late String color;
  late String soldAt;
  late String paymentMode;
  late String paymentStatus;
  late String invoiceStatus;
  late String article;
  late String vendor;
  late double mrp;

  Invoice(
      {this.article = '',
      this.color = '',
      this.costPrice = 0,
      this.description = '',
      this.invoiceNo = '',
      this.invoiceStatus = '',
      this.paymentMode = '',
      this.paymentStatus = '',
      this.productId = '',
      this.profit = 0,
      this.sellingPrice = 0,
      this.size = '',
      this.soldAt = '',
      this.vendor = '',
      this.mrp = 0,
      DateTime? invoiceDate})
      : this.invoiceDate = invoiceDate ?? DateTime.now();
  Invoice.fromJson(Map invoice) {
    mrp = double.parse(invoice['mrp'].toString());
    vendor = invoice['vendor'] ?? '';
    color = invoice['color'];
    costPrice = double.parse(invoice['cost_price'].toString());
    invoiceNo = invoice['invoice_no'];
    invoiceDate = DateTime.parse(invoice['invoice_date']);
    productId = invoice['product_id'];
    sellingPrice = double.parse(invoice['selling_price'].toString());
    profit = double.parse(invoice['profit'].toString());
    description = invoice['dexcription'] ?? '';
    size = invoice['size'].toString();
    soldAt = invoice['sold_at'];
    paymentMode = invoice['payment_mode'];
    paymentStatus = invoice['payment_status'];
    invoiceStatus = invoice['invoice_status'];
    article = invoice['article'];
  }

  Map<String, dynamic> toJson() {
    return {
      "invoice_no": invoiceNo,
      "invoice_date": invoiceDate.toString(),
      "product_id": productId,
      "cost_price": costPrice,
      "selling_price": sellingPrice,
      "profit": profit,
      "description": description,
      "size": size,
      "color": color,
      "sold_at": soldAt,
      "payment_mode": paymentMode,
      "payment_status": paymentStatus,
      "invoice_status": invoiceStatus,
      'article': article,
      'vendor': vendor,
      'mrp':mrp
    };
  }
}
