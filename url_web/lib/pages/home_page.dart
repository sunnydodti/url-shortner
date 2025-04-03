import 'dart:async';

import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

import '../enums/url_status.dart';
import '../service/url_service.dart';
import '../widgets/colored_text_box.dart';
import '../widgets/my_appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController urlController = TextEditingController();
  TextEditingController shortUrlController = TextEditingController();
  UrlStatus urlStatus = UrlStatus.none;
  ShortUrlStatus shortUrlStatus = ShortUrlStatus.none;
  Timer? urlTimer;
  Timer? shortUrlTimer;
  final double helperFontSize = 9;

  @override
  void dispose() {
    urlController.dispose();
    shortUrlController.dispose();
    urlTimer?.cancel();
    shortUrlTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: MyAppbar.build(context),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            _buildUrlField(),
            SizedBox(height: 16),
            _buildShortUrlField(),
            SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlField() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(
        controller: urlController,
        maxLines: 10,
        minLines: 1,
        // expands: true,

        onChanged: onUrlChanged,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            label: Text('Enter URL'),
            helper: _getUrlHelperText(),
            suffix: IconButton(
              icon: Icon(Icons.clear_outlined),
              onPressed: () {
                urlController.clear();
                shortUrlController.clear();
                setState(() => urlStatus = UrlStatus.none);
              },
            )),
      ),
    ]);
  }

  Widget _buildShortUrlField() {
    if (urlStatus != UrlStatus.valid) return const SizedBox.shrink();
    return TextField(
      controller: shortUrlController,
      onChanged: onShortUrlChanged,
      maxLength: 50,
      maxLines: 2,
      minLines: 1,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          label: Text('Short URL (optional)'),
          hintText: '<auto>',
          hintStyle: const TextStyle(color: Colors.grey),
          helper: _getShortUrlHelperText(),
          prefix: ColoredTextBox(
            text: 'url.persist.site/',
            color: Theme.of(context).colorScheme.primary,
            upperCase: false,
          ),
          suffix: IconButton(
            icon: Icon(Icons.clear_outlined),
            onPressed: () {
              shortUrlController.clear();
              setState(() => shortUrlStatus = ShortUrlStatus.none);
            },
          )),
    );
  }

  Widget? _getUrlHelperText() {
    switch (urlStatus) {
      case UrlStatus.none:
        return null;
      case UrlStatus.checking:
        return ColoredTextBox.grey(
          'checking...',
          fontSize: helperFontSize,
        );
      case UrlStatus.valid:
        return ColoredTextBox.green(
          'valid',
          fontSize: helperFontSize,
        );
      case UrlStatus.invalid:
        return ColoredTextBox.red(
          'invalid url',
          fontSize: helperFontSize,
        );
    }
  }

  Widget? _getShortUrlHelperText() {
    switch (shortUrlStatus) {
      case ShortUrlStatus.none:
        return null;
      case ShortUrlStatus.checking:
        return ColoredTextBox.grey(
          'checking...',
          fontSize: helperFontSize,
        );
      case ShortUrlStatus.checkingAvalability:
        return ColoredTextBox.grey(
          'checking availability...',
          fontSize: helperFontSize,
        );
      case ShortUrlStatus.available:
        return ColoredTextBox.green(
          'available',
          fontSize: helperFontSize,
        );
      case ShortUrlStatus.unavailable:
        return ColoredTextBox.red(
          'unavailable',
          fontSize: helperFontSize,
        );
      case ShortUrlStatus.valid:
        return ColoredTextBox.green(
          'valid',
          fontSize: helperFontSize,
        );
      case ShortUrlStatus.invalid:
        return buildInvalidShortUrlHelper();
    }
  }

  Widget _buildSubmitButton() {
  if (urlStatus != UrlStatus.valid) return SizedBox.shrink();
  
  // Determine if the button should be enabled
  bool isShortUrlValid = shortUrlStatus == ShortUrlStatus.valid || 
                         shortUrlStatus == ShortUrlStatus.available ||
                         shortUrlStatus == ShortUrlStatus.none;
  
  return Padding(
    padding: const EdgeInsets.only(top: 16.0),
    child: ElevatedButton(
      onPressed: !isShortUrlValid ? null : () async {
        // Unfocus any text fields to prevent the pointer binding issue
        FocusScope.of(context).unfocus();
        
        // Show loading state if needed
        setState(() {
          // Optional loading state
        });
        
        try {
          final String url = urlController.text;
          final String? shortUrl = shortUrlController.text.isEmpty ? null : shortUrlController.text;
          
          final result = await UrlService.isAvailable(shortUrl ?? "");
          
          if (result || shortUrl == null) {
            final shortenedUrl = await UrlService.shortenUrl(url,);
            // final shortenedUrl = await UrlService.shortenUrl(
            //   originalUrl: url,
            //   customShortUrl: shortUrl,
            // );
            
            if (shortenedUrl != null) {
              // Show success dialog
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: Text('URL Shortened Successfully'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your shortened URL:'),
                        SizedBox(height: 8),
                        SelectableText('url.persist.site/$shortenedUrl'),
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
                  ),
                );
              }
              
              // Reset form
              urlController.clear();
              shortUrlController.clear();
              setState(() {
                urlStatus = UrlStatus.none;
                shortUrlStatus = ShortUrlStatus.none;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to create short URL')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('The custom short URL is not available')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
      child: Text('Submit'),
    ),
  );
}

  SizedBox buildInvalidShortUrlHelper() {
    return SizedBox(
      height: 22,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ColoredTextBox.red(
              'invalid',
              fontSize: helperFontSize,
            ),
            SizedBox(width: 4),
            ColoredTextBox.grey(
              'SUPPORTED: a-z | A-Z | 0-9 | - | _ | .',
              fontSize: helperFontSize,
              upperCase: false,
            ),
            SizedBox(width: 4),
            ColoredTextBox.grey(
              'length: 3-50',
              fontSize: helperFontSize,
            ),
          ],
        ),
      ),
    );
  }

  void onUrlChanged(String? value) {
    if (urlTimer != null && urlTimer!.isActive) {
      urlTimer!.cancel();
    }

    setState(() => urlStatus = UrlStatus.checking);
    urlTimer = Timer(const Duration(milliseconds: 500), () {
      evaluateUrl(value);
    });
  }

  void onShortUrlChanged(String? value) {
    if (shortUrlTimer != null && shortUrlTimer!.isActive) {
      shortUrlTimer!.cancel();
    }

    setState(() => shortUrlStatus = ShortUrlStatus.checking);
    shortUrlTimer = Timer(const Duration(milliseconds: 500), () {
      evaluateShortUrl(value);
    });
  }

  void evaluateUrl(String? url) {
    if (url == null || url.isEmpty) {
      setState(() => urlStatus = UrlStatus.none);
      return;
    }
    if (!isValidUrl(url)) {
      setState(() => urlStatus = UrlStatus.invalid);
      return;
    }
    setState(() => urlStatus = UrlStatus.valid);
  }

  void evaluateShortUrl(String? url) async {
    if (url == null || url.isEmpty) {
      setState(() => shortUrlStatus = ShortUrlStatus.none);
      return;
    }
    if (!isValidShortUrl(url)) {
      setState(() => shortUrlStatus = ShortUrlStatus.invalid);
      return;
    }
    setState(() => shortUrlStatus = ShortUrlStatus.valid);
    setState(() => shortUrlStatus = ShortUrlStatus.checkingAvalability);

    bool isAvailaable = await UrlService.isAvailable(shortUrlController.text);

    if (!isAvailaable) {
      setState(() => shortUrlStatus = ShortUrlStatus.unavailable);
      return;
    }
    setState(() => shortUrlStatus = ShortUrlStatus.available);
  }

  bool isValidUrl(String url) {
    try {
      return isURL(url);
    } catch (e) {
      return false;
    }
  }

  bool isValidShortUrl(String url) {
    try {
      if (url.length < 3) return false;
      url = url.replaceAll('_', '');
      url = url.replaceAll('-', '');
      url = url.replaceAll('.', '');
      return isAlphanumeric(url);
    } catch (e) {
      return false;
    }
  }
}
