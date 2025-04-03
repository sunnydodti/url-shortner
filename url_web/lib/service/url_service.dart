import 'dart:convert';
import 'package:http/http.dart' as http;

class UrlService {
  static const String _baseUrl = 'http://localhost:64638';

  static Future<String> shortenUrl(String longUrl) async {
    // Simulate shortening the URL
    await Future.delayed(const Duration(seconds: 1));
    return '123456';
  }

  static Future<bool> isAvailable(String shortUrl) async {
    try {
      if (shortUrl.isEmpty) {
        return true; // Empty short URLs are always "available" since we'll generate one
      }
      String url = '$_baseUrl/is-available/$shortUrl'; 
      
      final response = await http.get(
        Uri.parse(url),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isAvailable'] == true;
      } else {
        print('Failed to check availability: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error checking availability: $e');
      return false;
    }
  }
}