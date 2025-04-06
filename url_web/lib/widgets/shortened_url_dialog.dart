import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'colored_text_box.dart';
import 'views_row.dart';

class ShortenedUrlDialog extends StatelessWidget {
  const ShortenedUrlDialog({
    super.key,
    required this.shortenedUrl,
    required this.url,
    this.dialog = 'URL Shortened Successfully',
    this.showViews = false,
  });

  final String shortenedUrl;
  final String url;
  final String dialog;
  final bool showViews;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return AlertDialog(
      title: Text(dialog),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your shortened URL:'),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  launchUrl(
                    Uri.parse('https://url.persist.site/$shortenedUrl'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: width * 0.5),
                  child: ColoredTextBox.green(
                    'url.persist.site/$shortenedUrl',
                    fontSize: 11,
                    upperCase: false,
                  ),
                ),
              ),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.copy),
                ),
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: 'url.persist.site/$shortenedUrl'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Shortened URL copied to clipboard')),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          Text('Original URL:'),
          SizedBox(height: 8),
          Text(url, maxLines: 3, overflow: TextOverflow.ellipsis),
          if (showViews) _buildViews(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Close'),
        ),
      ],
    );
  }

  Column _buildViews() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
          ViewsRow(shortUrl: shortenedUrl),
          SizedBox(height: 16),
        ],
      );
}
