import 'short_url.dart';

class UrlHistory {
  List<ShortUrl> shortUrls = [];

  UrlHistory({required this.shortUrls});

  factory UrlHistory.fromMap(Map<String, dynamic> map) {
    return UrlHistory(
      shortUrls: (map['shortUrls'] as List)
          .map((item) => ShortUrl.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shortUrls': shortUrls.map((url) => url.toMap()).toList(),
    };
  }
}
