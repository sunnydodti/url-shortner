class ShortUrl {
  String originalUrl;
  String shortUrl;

  ShortUrl({required this.originalUrl, required this.shortUrl});

  factory ShortUrl.fromMap(Map<String, dynamic> map) {
    return ShortUrl(
      originalUrl: map['originalUrl'],
      shortUrl: map['shortUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'originalUrl': originalUrl,
      'shortUrl': shortUrl,
    };
  }
}
