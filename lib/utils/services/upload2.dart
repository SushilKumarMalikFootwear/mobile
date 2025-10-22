import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadService {
  static const String _baseUrl = "https://api.uploadthing.com/v6";
  static final String _apiKey = "sk_live_054df1cfe0e890343ef89b3ccdb99a81eeb2adbe0a9179e2522b67877700d6b5";

  /// Uploads a file (XFile or file path) to UploadThing and returns the public URL.
  static Future<String?> uploadFile(String fileInput) async {
    try {
      // Resolve file
      File file = File(fileInput);

      final fileName = file.uri.pathSegments.last;
      final fileSize = await file.length();
      final mimeType = "image/${fileName.split('.').last}";

      // Step 1: Get presigned URL
      final presignResp = await http.post(
        Uri.parse("$_baseUrl/uploadFiles"),
        headers: {
          "Content-Type": "application/json",
          "X-Uploadthing-Api-Key": _apiKey,
        },
        body: jsonEncode({
          "files": [
            {
              "name": fileName,
              "size": fileSize,
              "type": mimeType,
              "customId": null,
            }
          ],
          "acl": "public-read",
          "metadata": null,
          "contentDisposition": "inline",
        }),
      );

      if (presignResp.statusCode != 200) {
        print("Presign failed: ${presignResp.body}");
        return null;
      }

      final presignData = jsonDecode(presignResp.body);
      if (presignData["data"] == null || presignData["data"].isEmpty) {
        print("Presign response invalid: $presignData");
        return null;
      }

      final uploadInfo = presignData["data"][0];
      final uploadUrl = uploadInfo["url"];
      final fields = Map<String, dynamic>.from(uploadInfo["fields"] ?? {});

      // Step 2: Upload file to presigned URL
      final request = http.MultipartRequest("POST", Uri.parse(uploadUrl));
      fields.forEach((k, v) => request.fields[k] = v.toString());
      request.files.add(await http.MultipartFile.fromPath("file", file.path));

      final streamedResp = await request.send();
      final resp = await http.Response.fromStream(streamedResp);

      if (resp.statusCode == 204 || resp.statusCode == 200) {
        // Success
        return uploadInfo["fileUrl"];
      } else {
        print("Upload failed: ${resp.statusCode} - ${resp.body}");
        return null;
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }
}
