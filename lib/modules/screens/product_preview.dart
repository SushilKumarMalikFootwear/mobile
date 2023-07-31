import 'package:flutter/material.dart';
import 'package:footwear/modules/widgets/add_product.dart';

import '../../config/constants/AppConstants.dart';
import '../models/product.dart';

class ProductPreview extends StatefulWidget {
  Product product;
  String sizeAtHome;
  String sizeAtShope;
  ProductPreview(
      {super.key,
      required this.product,
      required this.sizeAtHome,
      required this.sizeAtShope});

  @override
  State<ProductPreview> createState() => _ProductPreviewState();
}

class _ProductPreviewState extends State<ProductPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Footwear'),
        actions: [
          IconButton(
              onPressed: () {
                showMenu<String>(
                  context: context,
                  position: const RelativeRect.fromLTRB(25.0, 25.0, 0.0, 0.0),
                  items: [
                    PopupMenuItem<String>(
                        value: Constants.EDIT,
                        child: Row(
                          children: const [
                            Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Edit'),
                          ],
                        )),
                    PopupMenuItem<String>(
                        value: Constants.DELETE,
                        child: Row(
                          children: const [
                            Icon(
                              Icons.delete,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Delete'),
                          ],
                        )),
                  ],
                  elevation: 8.0,
                ).then<void>((String? itemSelected) async {
                  if (itemSelected == null) {
                    return;
                  } else if (itemSelected == Constants.EDIT) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return Scaffold(
                          appBar: AppBar(
                            title: Text('Manage Product'),
                          ),
                          body: AddPrduct(() {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }, () {}, Constants.EDIT, widget.product),
                        );
                      },
                    ));
                  }
                });
              },
              icon: const Icon(Icons.more_vert))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              widget.product.URL1!,
              height: 320,
            ),
            const SizedBox(
              height: 15,
            ),
            if (widget.product.URL2 != null) ...[
              Image.network(
                widget.product.URL2!,
                height: 320,
              ),
              const SizedBox(
                height: 15,
              ),
            ],
            Text(
              'Article : ${widget.product.article}',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Brand : ${widget.product.subBrandName}, ${widget.product.brandName}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Category : ${widget.product.category}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Color : ${widget.product.color}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Price : ${widget.product.sellingPrice}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'MRP : ${widget.product.mrp}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Size Range : ${widget.product.sizeRange}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Shop : ${widget.sizeAtShope}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Home : ${widget.sizeAtHome}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
