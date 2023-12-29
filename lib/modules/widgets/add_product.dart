import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:footwear/config/constants/AppConstants.dart';
import 'package:footwear/modules/models/product.dart';
import 'package:footwear/modules/repository/product_repo.dart';
import 'package:footwear/utils/widgets/CustomDropdown.dart';
import 'package:image_picker/image_picker.dart';
import '/utils/services/upload.dart';
import '/utils/widgets/custom_text.dart';
import '/utils/widgets/toast.dart';

class AddPrduct extends StatefulWidget {
  Product product;
  String todo;
  Function refreshChild;
  Function switchChild;
  AddPrduct(this.refreshChild, this.switchChild, this.todo, this.product,
      {super.key});

  @override
  State<AddPrduct> createState() => _AddPrductState();
}

class _AddPrductState extends State<AddPrduct> {
  TextEditingController brandName = TextEditingController();
  TextEditingController subBrandName = TextEditingController();
  TextEditingController article = TextEditingController();
  TextEditingController mrp = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController costPrice = TextEditingController();
  String? vendor;
  List<String> vendorList = [];
  String? category;
  List<String> categoryList = [];
  TextEditingController color = TextEditingController();
  late String url1;
  String? url2;
  String? sizeRange;
  List<String> sizeRangeList = [];
  String? fileName1;
  String? fileName2;
  TextEditingController descCtrl = TextEditingController();
  ProductRepository productRepo = ProductRepository();
  Map<String, List<String>> configList = {};
  late Product product;
  setConfigList() async {
    configList = await productRepo.getConfigLists();
    categoryList = configList['categoryList']!;
    sizeRangeList = configList['sizeRangeList']!;
    vendorList = configList['vendorList']!;
    setState(() {});
  }

  @override
  initState() {
    setConfigList();
    super.initState();
    product = widget.product;
    if (widget.todo == Constants.EDIT) {
      vendor = product.vendor;
      brandName.text = product.brandName;
      subBrandName.text = product.subBrandName;
      category = product.category;
      article.text = product.article;
      sizeRange = product.sizeRange;
      descCtrl.text = product.description;
      mrp.text = product.mrp;
      sellingPrice.text = product.sellingPrice;
      costPrice.text = product.costPrice;
      color.text = product.color;
      url1 = product.URL1 ?? '';
      url2 = product.URL2;
      setState(() {});
    }
  }

  _addProduct() async {
    product.URL1 = url1;
    product.URL2 = url2;
    product.article = article.text;
    product.brandName = brandName.text;
    product.category = category!;
    product.color = color.text;
    product.costPrice = costPrice.text;
    product.sellingPrice = sellingPrice.text;
    product.mrp = mrp.text;
    product.subBrandName = subBrandName.text;
    product.sizeRange = sizeRange!;
    product.description = descCtrl.text;
    product.vendor = vendor.toString();
    widget.todo == Constants.CREATE
        ? await productRepo.add(product.toJSON())
        : await productRepo.update(product.toJSON());
    if (context.mounted) {
      createToast('Product Successfully Added', ctx);
    }
    Future.delayed(const Duration(seconds: 1), () {
      brandName.clear();
      descCtrl.clear();
      subBrandName.clear();
      article.clear();
      mrp.clear();
      sellingPrice.clear();
      costPrice.clear();
      fileName1 = null;
      fileName2 = null;
      if (widget.todo == Constants.CREATE) {
        widget.switchChild();
      } else {
        widget.refreshChild();
      }
      color.clear();
      category = '';
      sizeRange = '';
      fileName1 = '';
      fileName2 = '';
      url1 = '';
      url2 = '';
      product.pairs_in_stock = [];
    });
  }

  final ImagePicker _picker = ImagePicker();

  _uploadIt(String? fileName, int photoNumber) {
    UploadDownload obj = UploadDownload();
    UploadTask upload = obj.uploadImage(fileName!);
    upload.then((TaskSnapshot shot) async {
      photoNumber == 1
          ? url1 = await obj.ref.getDownloadURL()
          : url2 = await obj.ref.getDownloadURL();
    }).catchError((err) {});
    setState(() {});
  }

  _showCameraOrGallery(Size deviceSize, int photoNumber) {
    return SizedBox(
      width: deviceSize.width / 1.5,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  iconSize: 50,
                  onPressed: () async {
                    await _showCamera(photoNumber);
                    // refreshChild();
                    _uploadIt(
                        photoNumber == 1 ? fileName1 : fileName2, photoNumber);
                  },
                  icon: const Icon(Icons.camera)),
              IconButton(
                  iconSize: 50,
                  onPressed: () async {
                    await _showGallery(photoNumber);
                    // refreshChild();
                    _uploadIt(
                        photoNumber == 1 ? fileName1 : fileName2, photoNumber);
                  },
                  icon: const Icon(Icons.folder)),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [Text("Camera   "), Text("Gallery ")],
          )
        ],
      ),
    );
  }

  _showCamera(int photoNumber) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    photoNumber == 1 ? fileName1 = photo?.path : fileName2 = photo?.path;
  }

  _showGallery(int photoNumber) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    photoNumber == 1 ? fileName1 = image?.path : fileName2 = image?.path;
  }

  late BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    ctx = context;
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(widget.todo == Constants.CREATE ? 'ADD PRODUCT' : 'EDIT PRODUCT',
              style: const TextStyle(fontSize: 40)),
          CustomText(
              label: 'Brand Name',
              tc: brandName,
              prefixIcon: Icons.text_snippet),
          CustomText(
              label: 'Sub Brand Name',
              tc: subBrandName,
              prefixIcon: Icons.text_snippet),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: CustomDropDown(
                value: vendor,
                hint: 'Select a Vendor',
                onChange: (value) {
                  vendor = value;
                },
                items: vendorList),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: CustomDropDown(
                value: category,
                hint: 'Select a Categoy',
                onChange: (value) {
                  category = value;
                },
                items: categoryList),
          ),
          CustomText(
              label: 'Article', tc: article, prefixIcon: Icons.text_snippet),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: CustomDropDown(
                value: sizeRange,
                hint: 'Select Size Range',
                onChange: (value) {
                  sizeRange = value;
                  product.pairs_in_stock.clear();
                  int startSize =
                      int.parse(sizeRange!.split(' ')[0].split('X')[0]);
                  int endSize =
                      int.parse(sizeRange!.split(' ')[0].split('X')[1]);
                  for (int i = startSize; i <= endSize; i++) {
                    product.pairs_in_stock.add({
                      'size': i,
                      'available_at': "HOME",
                      'quantity': 0,
                    });
                  }
                  for (int i = startSize; i <= endSize; i++) {
                    product.pairs_in_stock.add({
                      'size': i,
                      'available_at': "SHOP",
                      'quantity': 0,
                    });
                  }
                  setState(() {});
                },
                items: sizeRangeList),
          ),
          CustomText(
            label: 'Type Description Here',
            tc: descCtrl,
            isMultiLine: true,
            prefixIcon: Icons.text_snippet,
          ),
          CustomText(label: 'MRP', tc: mrp, prefixIcon: Icons.text_snippet),
          CustomText(
              label: 'Selling Price',
              tc: sellingPrice,
              prefixIcon: Icons.text_snippet),
          CustomText(
              label: 'Cost Price',
              tc: costPrice,
              prefixIcon: Icons.text_snippet),
          CustomText(label: 'Color', tc: color, prefixIcon: Icons.text_snippet),
          const SizedBox(
            height: 10,
          ),
          const Row(
            children: [
              SizedBox(
                width: 45,
              ),
              Text('Available At', style: TextStyle(fontSize: 16)),
              SizedBox(
                width: 45,
              ),
              Text('Size(Quantity)', style: TextStyle(fontSize: 16))
            ],
          ),
          SizedBox(
            height: product.pairs_in_stock.length * 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: product.pairs_in_stock.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          product.pairs_in_stock[index]['available_at'],
                          style: TextStyle(
                              fontSize: 16,
                              color: product.pairs_in_stock[index]
                                          ['available_at'] ==
                                      'HOME'
                                  ? Colors.blue
                                  : Colors.purple),
                        ),
                        ClipOval(
                          child: Material(
                            color: Colors.blue, // Button color
                            child: InkWell(
                              splashColor: Colors.red, // Splash color
                              onTap: () {
                                if (product.pairs_in_stock[index]['quantity'] >
                                    0) {
                                  product.pairs_in_stock[index]['quantity']--;
                                  setState(() {});
                                }
                              },
                              child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                        Text(
                          '${product.pairs_in_stock[index]['size']}(${product.pairs_in_stock[index]['quantity']})',
                          style: const TextStyle(fontSize: 16),
                        ),
                        ClipOval(
                          child: Material(
                            color: Colors.blue, // Button color
                            child: InkWell(
                              splashColor: Colors.red, // Splash color
                              onTap: () {
                                product.pairs_in_stock[index]['quantity']++;
                                setState(() {});
                              },
                              child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (widget.todo == Constants.EDIT && url1.isNotEmpty)
            Image.network(url1),
          _showCameraOrGallery(deviceSize, 1),
          const SizedBox(height: 15),
          fileName1 == null
              ? const Text("Choose First Image To Upload")
              : SizedBox(
                  width: 150, child: Image.file(File(fileName1.toString()))),
          const SizedBox(height: 15),
          if (widget.todo == Constants.EDIT && url2 != null
              ? (url2!.isNotEmpty)
              : false)
            Image.network(url2!),
          _showCameraOrGallery(deviceSize, 2),
          const SizedBox(height: 15),
          fileName2 == null
              ? const Text("Choose Second Image To Upload")
              : SizedBox(
                  width: 150, child: Image.file(File(fileName2.toString()))),
          const SizedBox(height: 15),
          ElevatedButton(
              onPressed: () {
                _addProduct();
              },
              child: const Text('ADD PRODUCT'))
        ],
      ),
    );
  }
}
