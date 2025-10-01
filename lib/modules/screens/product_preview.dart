import 'package:flutter/material.dart';
import 'package:footwear/modules/widgets/add_product.dart';
import '../../config/constants/app_constants.dart';
import '../models/product.dart';

class ProductPreview extends StatefulWidget {
  final Product product;
  final String sizeAtHome;
  final String sizeAtShope;
  final Function refreshParent;

  const ProductPreview({
    super.key,
    required this.refreshParent,
    required this.product,
    required this.sizeAtHome,
    required this.sizeAtShope,
  });

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
                    value: Constants.edit,
                    child: const Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 5),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: Constants.delete,
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 5),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
                elevation: 8.0,
              ).then<void>((String? itemSelected) async {
                if (itemSelected == null) return;

                if (itemSelected == Constants.edit) {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return Scaffold(
                        appBar: AppBar(title: const Text('Manage Product')),
                        body: AddProduct(
                          () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            widget.refreshParent();
                          },
                          () {},
                          Constants.edit,
                          widget.product,
                        ),
                      );
                    },
                  ));
                }
              });
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //
            Image.network(widget.product.URL1!, fit: BoxFit.contain),
            if (widget.product.URL2 != null)
              Image.network(widget.product.URL2!, fit: BoxFit.contain),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 2,
                  children: [
                    GestureDetector(
                      onTap: () {
                        widget.product.sizeDescription='S';
                        setState(() {});
                      },
                      child: Chip(
                        label: Text('S'),
                        backgroundColor:
                            widget.product.sizeDescription=='S' ? Colors.blue[400] : Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.product.sizeDescription='M' ;
                        setState(() {});
                      },
                      child: Chip(
                        label: Text('M'),
                        backgroundColor:
                            widget.product.sizeDescription=='M'  ? Colors.blue[400] : Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.product.sizeDescription='L';
                        setState(() {});
                      },
                      child: Chip(
                        label: Text('L'),
                        backgroundColor:
                            widget.product.sizeDescription=='L'  ? Colors.blue[400] : Colors.white,
                      ),
                    )
                  ],
                ),
              ],
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Article name
                  Text(
                    widget.product.article,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Brand & Category
                  Text("Brand: ${widget.product.brandName}",
                      style: const TextStyle(fontSize: 16)),
                  Text("Category: ${widget.product.category}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),

                  // Price section
                  Row(
                    children: [
                      Text(
                        "₹${widget.product.sellingPrice}",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "₹${widget.product.mrp}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Color & Size Range
                  Text("Color: ${widget.product.color}",
                      style: const TextStyle(fontSize: 16)),
                  Text("Size Range: ${widget.product.sizeRange}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),

                  // Shop sizes
                  if (widget.sizeAtShope.isNotEmpty) ...[
                    const Text("Available at Shop:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 2,
                      children: widget.sizeAtShope
                          .split(',')
                          .map((s) => Chip(
                                label: Text(s),
                                backgroundColor: Colors.blue[50],
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 5),
                  ],

                  // Home sizes
                  if (widget.sizeAtHome.isNotEmpty) ...[
                    const Text("Available at Home:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 2,
                      children: widget.sizeAtHome
                          .split(',')
                          .map((s) => Chip(
                                label: Text(s),
                                backgroundColor: Colors.green[50],
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
