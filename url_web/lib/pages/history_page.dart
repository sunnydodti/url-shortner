import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/provider/url_provider.dart';
import '../widgets/mobile_wrapper.dart';
import '../widgets/my_appbar.dart';
import '../widgets/shortened_url_dialog.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final urlProvider = Provider.of<UrlProvider>(context);

    return MobileWrapper(
      child: Scaffold(
        appBar: MyAppbar.build(context, title: 'History'),
        body: RefreshIndicator(
          onRefresh: () async {
            await urlProvider.loadUrls();
          },
          child: _buildHistory(urlProvider),
        ),
      ),
    );
  }

  Column _buildHistory(UrlProvider urlProvider) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
                itemCount: urlProvider.urls.length,
                itemBuilder: (context, index) {
                  final url = urlProvider.urls[index];
                  return ListTile(
                    title: Text(url.shortUrl),
                    subtitle: Text(url.originalUrl),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ShortenedUrlDialog(
                          shortenedUrl: url.shortUrl,
                          url: url.originalUrl,
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Delete URL'),
                            content: Text('Are you sure you want to delete this URL?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  urlProvider.deleteUrl(index);
                                  Navigator.pop(context);
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              urlProvider.loadUrls();
            },
            child: Text('Refresh'),
          ),
        ),
      ],
    );
  }
}