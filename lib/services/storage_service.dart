import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class StorageService {
  static const String _apiKey = '';
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  Future<String> uploadImage(XFile file, String folder) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_uploadUrl?key=$_apiKey'));
      
      final originalBytes = await file.readAsBytes();
      List<int> webpBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
        minWidth: 1080,
        minHeight: 1080,
        quality: 80,
        format: CompressFormat.webp,
      );

      // Ensure file size is less than 100KB
      int quality = 70;
      while (webpBytes.length > 100 * 1024 && quality > 10) {
        webpBytes = await FlutterImageCompress.compressWithList(
          originalBytes,
          minWidth: 1080,
          minHeight: 1080,
          quality: quality,
          format: CompressFormat.webp,
        );
        quality -= 10;
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        webpBytes,
        filename: '${file.name}.webp',
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseData);
        // ImgBB returns the direct image link in data['url']
        return jsonResponse['data']['url'];
      } else {
        throw Exception('Failed to upload image: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('ImgBB Upload Error: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    // Note: ImgBB's free API doesn't easily support deleting via URL without a 'delete_url'
    // which they provide in the initial upload response. 
    // For a pet project, we can just leave it or log it.
    print('Delete requested for $imageUrl (Not supported on ImgBB free API via URL alone)');
  }
}
