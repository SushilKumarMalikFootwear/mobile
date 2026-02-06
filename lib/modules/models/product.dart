class Product {
  String footwear_id = '';
  late String brandName;
  late String article;
  late String mrp;
  late String sellingPrice;
  late String costPrice;
  late String category;
  late String color;
  String? URL1;
  String? URL2;
  String? rating;
  late String sizeRange;
  late String description;
  late String vendor;
  late List<String> label;
  List pairs_in_stock = [];
  bool outOfStock = false;
  bool updated = false;
  String sizeDescription = 'M';
  Product();
  Product.fromJSON(Map product) {
    sizeDescription = product['size_description'] ?? 'M';
    rating = product['rating'].toString();
    vendor = product['vendor'] ?? '';
    footwear_id = product['footwear_id'];
    brandName = product['brand'];
    article = product['article'];
    mrp = product['mrp'].toString();
    sellingPrice = product['selling_price'].toString();
    costPrice = product['cost_price'].toString();
    category = product['category'];
    URL1 = product['newImages'][0];
    URL2 = product['newImages'].length == 2 ? product['newImages'][1] : '';
    color = product['color'];
    sizeRange = product['size_range'];
    pairs_in_stock = product['pairs_in_stock'];
    description = product['description'];
    outOfStock = product['out_of_stock'];
    updated = product['updated'] ?? false;
    List temp = product['label'] ?? [];
    label = temp.map((e) => e.toString()).toList();
  }

  Map<String, dynamic> toJSON() {
    return {
      "vendor": vendor,
      "brand": brandName,
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
      "newImages": [URL1, URL2],
      'footwear_id': footwear_id,
      'out_of_stock': outOfStock,
      'label': label,
      'rating': rating,
      'updated': updated,
      'size_description': sizeDescription,
    };
  }
}
