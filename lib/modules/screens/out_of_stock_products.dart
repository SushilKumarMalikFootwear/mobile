import 'package:flutter/material.dart';
import 'package:footwear/modules/widgets/view_product.dart';

class OutOfStockProducts extends StatefulWidget {
  const OutOfStockProducts({super.key});

  @override
  State<OutOfStockProducts> createState() => _OutOfStockProductsState();
}

class _OutOfStockProductsState extends State<OutOfStockProducts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Out of Stock')),
      body: ViewProduct(outOfStock: true),
    );
  }
}
