import 'dart:convert';
import 'package:http/http.dart' as http;

import '../data/constants.dart';

class UrlService {
  static final String _baseUrl = Constants.apiBase;
  static Future<String> shortenUrl(String longUrl, {String? customShortUrl = ''}) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/shorten'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'url': longUrl,
        'shortCode': customShortUrl,
      }),
    );
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['shortCode'];
    } else {
      // Parse error message from the response if available
      var errorMessage = 'Failed to shorten URL';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        }
      } catch (_) {
        // If we can't parse the error, use the status code
        errorMessage = 'Server returned status code ${response.statusCode}';
      }
      
      throw Exception(errorMessage);
    }
  } catch (e) {
    print('Error shortening URL: $e');
    if (e is Exception) {
      rethrow;
    }
    throw Exception('Failed to shorten URL: $e');
  }
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