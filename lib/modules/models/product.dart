class Product {
  String footwear_id = '';
  late String brandName;
  late String subBrandName;
  late String article;
  late String mrp;
  late String sellingPrice;
  late String costPrice;
  late String category;
  late String color;
  String? URL1;
  String? URL2;
  late String sizeRange;
  late String description;
  late String vendor;
  List pairs_in_stock = [];
  late bool outOfStock;
  Product();
  Product.fromJSON(Map product) {
    vendor = product['vendor'] ?? '';
    footwear_id = product['footwear_id'];
    brandName = product['brand'];
    subBrandName = product['sub_brand'];
    article = product['article'];
    mrp = product['mrp'].toString();
    sellingPrice = product['selling_price'].toString();
    costPrice = product['cost_price'].toString();
    category = product['category'];
    URL1 = product['images'][0];
    URL2 = product['images'].length == 2 ? product['images'][1] : '';
    color = product['color'];
    sizeRange = product['size_range'];
    pairs_in_stock = product['pairs_in_stock'];
    description = product['description'];
    outOfStock = product['out_of_stock'];
  }

  Map<String, dynamic> toJSON() {
    return {
      "vendor": vendor,
      "brand": brandName,
      "sub_brand": subBrandName,
      "article": article,
      "mrp": mrp,
      "selling_price": sellingPrice,
      "cost_price": costPrice,
      "category": category,
      "color": color,
      "pairs_in_stock": pairs_in_stock,
      "size_range": sizeRange,
      "description": description,
      "images": [URL1, URL2],
      'footwear_id': footwear_id,
      'out_of_stock':outOfStock
    };
  }
}
