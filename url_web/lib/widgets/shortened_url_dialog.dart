import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'colored_text_box.dart';

class ShortenedUrlDialog extends StatelessWidget {
  const ShortenedUrlDialog({
    super.key,
    required this.shortenedUrl,
    required this.url,
    this.dialog = 'URL Shortened Successfully',
  });

  final String shortenedUrl;
  final String url;
  final String dialog;

  @override
  Widget build(BuildContext context) {
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
                  constraints: BoxConstraints(maxWidth: 180),
                  child: ColoredTextBox.blue(
                    'url.persist.site/$shortenedUrl',
                    fontSize: 11,
                    upperCase: false,
                  ),
                ),
              ),
              GestureDetector(
                child: Icon(Icons.copy),
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
          Text(
            url,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
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
}
