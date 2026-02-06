import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class UploadDownload {
  static const String apiBase = "https://api.uploadthing.com/v6";
  static const String apiKey =
      "sk_live_054df1cfe0e890343ef89b3ccdb99a81eeb2adbe0a9179e2522b67877700d6b5"; // 🔴 NEVER COMMIT

  /// Upload image file to UploadThing
  /// Returns public download URL
  static Future<String> uploadImage(File file) async {
    final bytes = await file.readAsBytes();
    final fileName = path.basename(file.path);

    final mimeType = lookupMimeType(file.path) ?? "image/jpeg";

    // 1️⃣ Request presigned upload URL
    final presignResp = await http.post(
      Uri.parse("$apiBase/uploadFiles"),
      headers: {
        "Content-Type": "application/json",
        "X-Uploadthing-Api-Key": apiKey,
      },
      body: jsonEncode({
        "files": [
          {"name": fileName, "size": bytes.length, "type": mimeType},
        ],
        "acl": "public-read",
        "contentDisposition": "inline",
      }),
    );

    if (presignResp.statusCode != 200) {
      throw Exception("UploadThing presign failed");
    }

    final presignData = jsonDecode(presignResp.body);
    final uploadInfo = presignData["data"][0];

    final uploadUrl = uploadInfo["url"];
    final fields = uploadInfo["fields"] ?? {};

    // 2️⃣ Upload file to S3
    final request = http.MultipartRequest("POST", Uri.parse(uploadUrl));

    // ⚠️ ORDER MATTERS
    fields.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    request.files.add(
      http.MultipartFile.fromBytes(
        "file",
        bytes,
        filename: fileName,
        contentType: http.MediaType.parse(mimeType),
      ),
    );

    final uploadResp = await request.send();

    if (uploadResp.statusCode != 204 && uploadResp.statusCode != 201) {
      throw Exception("UploadThing upload failed");
    }

    // 3️⃣ Final public URL
    return uploadInfo["fileUrl"];
  }
}
