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

  static final String _apiBase = 'https://url.dodtisunny.workers.dev';

  static String get apiBase {
    if (kDebugMode) {
      return "https://url.dodtisunny.workers.dev";
      // return 'http://localhost:55494';
    }
    return _apiBase;
  }
}
