import 'package:flutter/foundation.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter/foundation.dart';

class Constants {
  static String appDisplayName = 'Url Shortner';

  static String box = 'url-box';

  static String isDarkMode = 'isDarkMode';

  static String isActiveKey = 'is_active';
  static String currentDataKey = 'current_data';
  static String indexKey = 'index';
  static String urlHistoryKey = 'url_history';

  static String urlTable = 'url';

  static String url = 'urls.persistr.site';
  static String baseUrl = 'https://$url';

  static final String _apiBase = 'url.persistr.site';

  static String get apiBase {
    if (kDebugMode) {
      return 'https://url.persistr.site';
      // return 'http://127.0.0.1:61131';
    }
    return 'https://$_apiBase';
  }

  static List<String> unSupportedUrls = [
    'url.persistr.site',
    'urls.persistr.site',
    'localhost:',
    '127.0.0.1',
  ];
}