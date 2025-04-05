import 'package:flutter/foundation.dart';

class Constants {
  static String appDisplayName = 'Url Shortner';

  static String box = 'url-box';

  static String isDarkMode = 'isDarkMode';

  static String isActiveKey = 'is_active';
  static String currentDataKey = 'current_data';
  static String indexKey = 'index';

  static String urlTable = 'url';

  static String url = 'urls.persist.site';
  static String baseUrl = 'https://$url';

  static final String _apiBase = 'url.persist.site';

  static String get apiBase {
    if (kDebugMode) {
      // return 'https://url.persist.site';
      return 'http://127.0.0.1:61131';
    }
    return 'https://$_apiBase';
  }

  static List<String> unSupportedUrls = [
    'url.persist.site',
    'urls.persist.site',
    'localhost:',
    '127.0.0.1',
  ];
}
