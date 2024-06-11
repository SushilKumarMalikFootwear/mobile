import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UploadDownload {
  Reference ref = FirebaseStorage.instance.ref().child('footwear_images');
  late UploadTask uploadTask;
  UploadTask uploadImage(String fileName) {
    String cloudFileName = fileName.split("/").last;
    ref = ref.child("/$cloudFileName");
    uploadTask = ref.putFile(File(fileName));
    return uploadTask;
  }
}
