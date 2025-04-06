import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;

import '../data/constants.dart';
import '../models/short_url.dart';
import '../models/url_history.dart';

class UrlService {
  static Future<String> shortenUrl(String longUrl,
      {String? customShortUrl = ''}) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiBase}/shorten'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'url': longUrl,
          'shortCode': customShortUrl,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        saveShorternedUrl(data['shortCode'], longUrl);
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
      debugPrint('Error shortening URL: $e');
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
      String url = '${Constants.apiBase}/is-available/$shortUrl';

      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isAvailable'] == true;
      } else {
        debugPrint('Failed to check availability: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error checking availability: $e');
      return false;
    }
  }

  static Future<int> getViews(String shortCode) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBase}/views/$shortCode'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['views'] ?? 0;
      } else if (response.statusCode == 404) {
        throw Exception('short code not found');
      } else if (response.statusCode == 400) {
        throw Exception('invalid request');
      } else {
        throw Exception('failed - ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching views: $e');
      throw Exception('Error fetching views: $e');
    }
  }

  static saveShorternedUrl(shortUrl, longUrl) async {
    try {
      await addNewUrl(ShortUrl(
        originalUrl: longUrl,
        shortUrl: shortUrl,
      ));
    } catch (e) {
      debugPrint('Error saving shortened URL: $e');
    }
  }

  static Future<void> addNewUrl(ShortUrl url) async {
    final box = Hive.box(Constants.box);
    final urlHistoryMap = box.get(Constants.urlHistoryKey, defaultValue: {
      'shortUrls': [],
    });
    final urlHistory =
        UrlHistory.fromMap(Map<String, dynamic>.from(urlHistoryMap));
    urlHistory.shortUrls.add(url);
    await box.put(Constants.urlHistoryKey, urlHistory.toMap());
  }
}
