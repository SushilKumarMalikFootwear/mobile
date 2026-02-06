import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:footwear/modules/widgets/select_label.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/constants/app_constants.dart';
import '../../utils/services/upload.dart';
import '../../utils/widgets/custom_checkbox.dart';
import '../../utils/widgets/custom_dropdown.dart';
import '../../utils/widgets/custom_text.dart';
import '../../utils/widgets/toast.dart';
import '../models/product.dart';
import '../repository/product_repo.dart';

class AddProduct extends StatefulWidget {
  final bool scroll; //scroll upto sizes
  final Product product;
  final String todo;
  final Function refreshChild;
  final Function switchChild;
  const AddProduct(this.refreshChild, this.switchChild, this.todo, this.product,
      {this.scroll = false});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  List<String> selectedLabels = [];
  List<String> labelOptions = [];
  ScrollController controller = ScrollController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  TextEditingController brandName = TextEditingController();
  TextEditingController rating = TextEditingController();
  TextEditingController article = TextEditingController();
  TextEditingController mrp = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController costPrice = TextEditingController();
  TextEditingController sizeRange = TextEditingController();
  TextEditingController firstPhotoUrl = TextEditingController();
  TextEditingController secondPhotoUrl = TextEditingController();
  String? vendor;
  List<String> vendorList = [];
  String? category;
  List<String> categoryList = [];
  TextEditingController color = TextEditingController();
  TextEditingController descCtrl = TextEditingController();
  ProductRepository productRepo = ProductRepository();
  Map<String, List<String>> configList = {};
  late Product product;
  final ImagePicker _picker = ImagePicker();
  late BuildContext ctx;
  XFile? image;
  bool uploadingFirstImage = false;
  bool uploadingSecondImage = false;
  bool showVendorError = false;
  bool showCategoryError = false;

  File? _pickedImage;

  @override
  initState() {
    setConfigList();
    super.initState();
    if (widget.scroll) {
      Future.delayed(const Duration(milliseconds: 250), () {
        controller.animateTo(
          controller.offset + 850, // Scroll 50 pixels down
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }

    product = widget.product;
    if (widget.todo == Constants.edit) {
      vendor = product.vendor;
      brandName.text = product.brandName;
      category = product.category;
      article.text = product.article;
      sizeRange.text = product.sizeRange;
      descCtrl.text = product.description;
      mrp.text = product.mrp;
      sellingPrice.text = product.sellingPrice;
      costPrice.text = product.costPrice;
      color.text = product.color;
      firstPhotoUrl.text = product.URL1 ?? '';
      secondPhotoUrl.text = product.URL2 ?? '';
      selectedLabels = product.label;
      rating.text = product.rating!;
      setState(() {});
    } else {
      rating.text = '7';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  setConfigList() async {
    configList = await productRepo.getConfigLists();
    categoryList = configList['categoryList']!;
    vendorList = configList['vendorList']!;
    labelOptions = await productRepo.getAllLables();
    setState(() {});
  }

  _addProduct() async {
    product.URL1 = firstPhotoUrl.text;
    if (firstPhotoUrl.text.isEmpty) {
      createToast('Image is not Uploaded yet!!', ctx);
      return;
    }
    product.URL2 = secondPhotoUrl.text.isEmpty ? null : secondPhotoUrl.text;
    product.label = selectedLabels;
    product.article = article.text;
    product.brandName = brandName.text;
    product.category = category!;
    product.color = color.text;
    product.costPrice = costPrice.text;
    product.sellingPrice = sellingPrice.text;
    product.mrp = mrp.text;
    product.sizeRange = sizeRange.text.toUpperCase();
    product.description = descCtrl.text;
    product.vendor = vendor.toString();
    product.rating = rating.text;
    widget.todo == Constants.create
        ? await productRepo.add(product.toJSON())
        : await productRepo.update(product.toJSON());
    if (widget.todo == Constants.create && context.mounted) {
      createToast('Product Successfully Added', ctx);
    } else {
      createToast('Product Updated Added', ctx);
    }
    Future.delayed(const Duration(seconds: 1), () {
      firstPhotoUrl.clear();
      secondPhotoUrl.clear();
      brandName.clear();
      descCtrl.clear();
      article.clear();
      mrp.clear();
      sellingPrice.clear();
      costPrice.clear();
      selectedLabels.clear();
      if (widget.todo == Constants.create) {
        widget.switchChild();
      } else {
        widget.refreshChild();
      }
      color.clear();
      category = '';
      sizeRange.clear();
      // firstPhotoUrl.text = '';
      // secondPhotoUrl.text = '';
      product.pairs_in_stock = [];
    });
  }

  _onChangeSizeRange(String sizeRange) {
    //EXAMPLE : 6X13-1X10
    // 6 to 13 & 1 to 10
    if (RegExp(r'^(\d+[Xx]\d+)(-\d+[Xx]\d+)*$').hasMatch(sizeRange)) {
      sizeRange = sizeRange.toUpperCase();
      product.pairs_in_stock.clear();
      for (String sizeSet in sizeRange.split('-')) {
        int startSize = int.parse(sizeSet.split('X')[0]);
        int endSize = int.parse(sizeSet.split('X')[1]);
        for (int i = startSize; i <= endSize; i++) {
          product.pairs_in_stock.add({
            'size': i,
            'available_at': Constants.home,
            'quantity': 0,
          });
        }
      }
      for (String sizeSet in sizeRange.split('-')) {
        int startSize = int.parse(sizeSet.split('X')[0]);
        int endSize = int.parse(sizeSet.split('X')[1]);
        for (int i = startSize; i <= endSize; i++) {
          product.pairs_in_stock.add({
            'size': i,
            'available_at': Constants.shop,
            'quantity': 0,
          });
        }
      }
      setState(() {});
    }
  }

  _uploadIt(int photoNumber) async {
    if (!(uploadingFirstImage || uploadingSecondImage)) {
      photoNumber == 1
          ? uploadingFirstImage = true
          : uploadingSecondImage = true;
      setState(() {});
      image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        //upload.dart
        // UploadDownload obj = UploadDownload();
        //   UploadTask upload = obj.uploadImage(image!.path);
        //   upload.then((TaskSnapshot shot) async {
        //     photoNumber == 1
        //         ? firstPhotoUrl.text = await obj.ref.getDownloadURL()
        //         : secondPhotoUrl.text = await obj.ref.getDownloadURL();
        //     photoNumber == 1
        //         ? uploadingFirstImage = false
        //         : uploadingSecondImage = false;
        //     setState(() {});
            //upload2.dart
        final File file = File(image!.path);
        Future<String?> upload = UploadDownload.uploadImage(file);
        upload.then((String? shot) async {
          photoNumber == 1
              ? firstPhotoUrl.text = shot ?? ''
              : secondPhotoUrl.text = shot ?? '';
          photoNumber == 1
              ? uploadingFirstImage = false
              : uploadingSecondImage = false;
          setState(() {});
        }).catchError((err) {});
      } else {
        photoNumber == 1
            ? uploadingFirstImage = false
            : uploadingSecondImage = false;
        setState(() {});
      }
    }
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
                  onPressed: () {
                    _uploadIt(photoNumber);
                  },
                  icon: const Icon(Icons.folder)),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [Text("Gallery ")],
          )
        ],
      ),
    );
  }

  _onChangePhotoURLs() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    ctx = context;
    return SingleChildScrollView(
      controller: controller,
      child: Form(
        key: _form,
        child: Column(
          children: [
            const SizedBox(height: 10),
            CustomText(label: 'Brand Name', tc: brandName, required: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: CustomDropDown(
                  value: vendor,
                  hint: 'Select a Vendor',
                  onChange: (value) {
                    vendor = value;
                    showVendorError = false;
                    setState(() {});
                  },
                  items: vendorList),
            ),
            if (showVendorError)
              const Row(
                children: [
                  Text('     Please Select Vendor',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: CustomDropDown(
                  value: category,
                  hint: 'Select a Categoy',
                  onChange: (value) {
                    category = value;
                    showCategoryError = false;
                    setState(() {});
                  },
                  items: categoryList),
            ),
            if (showCategoryError)
              const Row(
                children: [
                  Text('     Please Select Categroy',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            CustomText(label: 'Article', tc: article, required: true),
            const Padding(
              padding:
                  EdgeInsets.only(left: 12.0, right: 10, top: 5, bottom: 5),
              child: Row(
                children: [
                  Text('Labels', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
              child: GestureDetector(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue, width: 1),
                  ),
                  child: selectedLabels.isNotEmpty
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedLabels.map((label) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      : const Text('Tap to Select Labels'),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectLabel(
                            options: labelOptions,
                            selectedValues: selectedLabels,
                            onSelectionChanged: (List<String> list) {
                              selectedLabels = list;
                              setState(() {});
                            }),
                      ));
                },
              ),
            ),
            CustomText(label: 'Color', tc: color, required: true),
            CustomText(
                label: 'Size Range',
                tc: sizeRange,
                onChange: _onChangeSizeRange,
                required: true),
            CustomText(label: 'MRP', tc: mrp),
            CustomText(
                label: 'Selling Price', tc: sellingPrice, required: true),
            CustomText(label: 'Cost Price', tc: costPrice, required: true),
            CustomText(label: 'Rating', tc: rating, required: true),
            CustomText(
              label: 'Type Description Here',
              tc: descCtrl,
              isMultiLine: true,
            ),
            const SizedBox(
              height: 10,
            ),
            if (product.pairs_in_stock.isNotEmpty)
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
                                        Constants.home
                                    ? Colors.blue
                                    : Colors.purple),
                          ),
                          ClipOval(
                            child: Material(
                              color: Colors.blue, // Button color
                              child: InkWell(
                                splashColor: Colors.red, // Splash color
                                onTap: () {
                                  if (product.pairs_in_stock[index]
                                          ['quantity'] >
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
            if (uploadingFirstImage) const CircularProgressIndicator(),
            if (firstPhotoUrl.text.isNotEmpty)
              Image.network(firstPhotoUrl.text),
            _showCameraOrGallery(deviceSize, 1),
            const SizedBox(height: 15),
            if (firstPhotoUrl.text.isEmpty)
              const Text("Choose First Image To Upload"),
            const SizedBox(height: 15),
            CustomText(
                onChange: (String value) {
                  _onChangePhotoURLs();
                },
                label: 'First Photo URL',
                tc: firstPhotoUrl),
            if (uploadingSecondImage) const CircularProgressIndicator(),
            if (secondPhotoUrl.text.isNotEmpty)
              Image.network(secondPhotoUrl.text),
            _showCameraOrGallery(deviceSize, 2),
            const SizedBox(height: 15),
            CustomText(
                onChange: (String value) {
                  _onChangePhotoURLs();
                },
                label: 'Second Photo URL',
                tc: secondPhotoUrl),
            if (secondPhotoUrl.text.isEmpty)
              const Text("Choose Second Image To Upload"),
            const SizedBox(height: 15),
            CustomCheckBox(
                isSelected: product.outOfStock,
                onClicked: (bool value) {
                  product.outOfStock = value;
                  setState(() {});
                },
                label: 'Out of Stock'),
            const SizedBox(height: 5),
            CustomCheckBox(
                isSelected: product.updated,
                onClicked: (bool value) {
                  product.updated = value;
                  setState(() {});
                },
                label: 'Updated'),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 2,
                  children: [
                    GestureDetector(
                      onTap: () {
                        product.sizeDescription = 'S';
                        setState(() {});
                      },
                      child: Chip(
                        label: Text('S'),
                        backgroundColor: product.sizeDescription == 'S'
                            ? Colors.blue[400]
                            : Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        product.sizeDescription = 'M';
                        setState(() {});
                      },
                      child: Chip(
                        label: Text('M'),
                        backgroundColor: product.sizeDescription == 'M'
                            ? Colors.blue[400]
                            : Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        product.sizeDescription = 'L';
                        setState(() {});
                      },
                      child: Chip(
                        label: Text('L'),
                        backgroundColor: product.sizeDescription == 'L'
                            ? Colors.blue[400]
                            : Colors.white,
                      ),
                    )
                  ],
                ),
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  if (category == null ||
                      (category != null && category!.isEmpty)) {
                    showCategoryError = true;
                    setState(() {});
                    return;
                  }
                  if (vendor == null || (vendor != null && vendor!.isEmpty)) {
                    showVendorError = true;
                    setState(() {});
                    return;
                  }
                  if (_form.currentState!.validate()) {
                    _addProduct();
                  }
                },
                child: const Text(
                  'ADD PRODUCT',
                ))
          ],
        ),
      ),
    );
  }
}
