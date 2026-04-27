import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImgbbService {
  static String get _apiKey => dotenv.env['IMGBB_KEY'] ?? '';
  static const String _apiUrl = 'https://api.imgbb.com/1/upload';

  /// Uploads an image file to ImgBB and returns the public URL.
  /// Throws an exception if the upload fails.
  static Future<String> uploadImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('File not found at path: $imagePath');
    }

    // Read file bytes and encode to Base64
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Prepare POST request to ImgBB
    final response = await http.post(
      Uri.parse(_apiUrl),
      body: {
        'key': _apiKey,
        'image': base64Image,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        // Return the display URL of the uploaded image
        return jsonResponse['data']['url'];
      } else {
        throw Exception("ImgBB API returned success false: ${jsonResponse['error']}");
      }
    } else {
      throw Exception('Failed to upload image. Status code: ${response.statusCode}');
    }
  }
}
