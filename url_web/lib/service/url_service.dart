class UrlService {
  static Future<String> shortenUrl(String longUrl) async {
    // Simulate shortening the URL
    await Future.delayed(const Duration(seconds: 1));
    return 'short.url/123';
  }

  static Future<bool> isAvailable(String longUrl) async {
    // Simulate checking if the URL is available
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
