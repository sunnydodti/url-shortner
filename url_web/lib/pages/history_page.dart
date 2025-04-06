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
                      dialog: 'Short Url',
                      showViews: true,
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    Brightness brightness =
                        Theme.of(context).colorScheme.brightness;
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Delete URL'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Are you sure you want to delete this URL?'),
                            SizedBox(height: 16),
                            Text(
                              'Actualy short url will not be deleted',
                              style: TextStyle(
                                  color: brightness == Brightness.dark
                                      ? Colors.red.shade200
                                      : Colors.red.shade800),
                            ),
                          ],
                        ),
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
          padding: const EdgeInsets.all(16.0),
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
