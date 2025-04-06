import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pwa_install/pwa_install.dart';
import 'package:validators/validators.dart';

import '../data/constants.dart';
import '../data/provider/url_provider.dart';
import '../enums/url_status.dart';
import '../service/url_service.dart';
import '../widgets/colored_text_box.dart';
import '../widgets/mobile_wrapper.dart';
import '../widgets/my_appbar.dart';
import '../widgets/shortened_url_dialog.dart';
import 'history_page.dart';
import 'views_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController urlController;
  late TextEditingController shortUrlController;
  UrlStatus urlStatus = UrlStatus.none;
  ShortUrlStatus shortUrlStatus = ShortUrlStatus.none;
  Timer? urlTimer;
  Timer? shortUrlTimer;
  final double helperFontSize = 9;
  bool isLoading = false;

  @override
  void initState() {
    urlController = TextEditingController();
    shortUrlController = TextEditingController();
    shortUrlController.text = '';
    super.initState();
  }

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
    return MobileWrapper(
      child: Scaffold(
        appBar: MyAppbar.build(context),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    _buildUrlField(),
                    SizedBox(height: 16),
                    _buildShortUrlField(),
                    SizedBox(height: 16),
                    _buildSubmitButton(),
                    if (isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
              _buildViewsButton(context),
              if (PWAInstall().installPromptEnabled) _buildPwaInstallButton(),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildViewsButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // got to views page material page
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ViewsPage()));
              },
              child: Text('Check Views'),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Provider.of<UrlProvider>(context, listen: false).loadUrls();
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return HistoryPage();
                }));
              },
              child: Text('Check History'),
            ),
          ),
        ),
      ],
    );
  }

  Padding _buildPwaInstallButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            PWAInstall().promptInstall_();
          },
          child: const Text('Install PWA'),
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
      maxLines: 3,
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
        return buildPasteHelper();
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
        return buildInvalidUrlHelper();
      case UrlStatus.unsupported:
        return ColoredTextBox.red(
          'unsupported url',
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
    // if (urlStatus != UrlStatus.valid) return SizedBox.shrink();

    bool isShortUrlValid = shortUrlStatus == ShortUrlStatus.available ||
        shortUrlStatus == ShortUrlStatus.none;
    bool isUrlValid = urlStatus == UrlStatus.valid;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton(
        onPressed:
            (!isShortUrlValid || !isUrlValid || isLoading) ? null : submitUrl,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
        child: Text('Shorten'),
      ),
    );
  }

  Future<void> submitUrl() async {
    {
      FocusScope.of(context).unfocus();

      // Show loading state if needed
      setState(() => isLoading = true);

      final String shortUrl = shortUrlController.text;

      try {
        if (shortUrl.isNotEmpty) {
          if (shortUrl.length < 3) {
            showSnackbar('Short URL length must be atleast 3');
            return;
          }
          final result = await UrlService.isAvailable(shortUrl);
          if (!result) {
            setState(() => shortUrlStatus = ShortUrlStatus.unavailable);
            return;
          }
        }
        final String url = urlController.text;

        final shortenedUrl = await UrlService.shortenUrl(
          url,
          customShortUrl: shortUrl,
        );

        if (shortenedUrl.isEmpty) return;

        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                ShortenedUrlDialog(shortenedUrl: shortenedUrl, url: url),
          );

          // Reset form
          urlController.clear();
          shortUrlController.clear();
          setState(() {
            urlStatus = UrlStatus.none;
            shortUrlStatus = ShortUrlStatus.none;
          });
        }
      } catch (e) {
        showSnackbar('Error: ${e.toString()}');
      }
      setState(() => isLoading = false);
    }
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

  SizedBox buildInvalidUrlHelper() {
    return SizedBox(
      height: 22,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ColoredTextBox.red(
              'invalid url',
              fontSize: helperFontSize,
            ),
            SizedBox(width: 4),
            if (suggestCompletion)
              GestureDetector(
                onTap: () {
                  urlController.text += '.com';
                  onUrlChanged(urlController.text);
                },
                child: ColoredTextBox.blue(
                  '.com',
                  fontSize: helperFontSize,
                ),
              ),
          ],
        ),
      ),
    );
  }

  GestureDetector buildPasteHelper() {
    return GestureDetector(
      onTap: () async {
        urlController.text = await clipboardText;
        onUrlChanged(urlController.text);
      },
      child: ColoredTextBox.blue('paste', fontSize: helperFontSize),
    );
  }

  Future<String> get clipboardText async {
    String? clipboardText;
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      clipboardText = clipboardData?.text;
    } on Exception catch (_) {
      showSnackbar('Please Allow Clipboard Permission');
    }
    return clipboardText ?? '';
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  bool get suggestCompletion {
    bool isValidLength = urlController.text.isNotEmpty;
    bool isValidUrlChars = isValidUrl('${urlController.text}.com');

    return isValidLength && isValidUrlChars;
  }

  void onUrlChanged(String? value) {
    if (urlTimer != null && urlTimer!.isActive) {
      urlTimer!.cancel();
    }

    setState(() => urlStatus = UrlStatus.checking);
    urlTimer = Timer(const Duration(milliseconds: 400), () {
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
    if (!isSupportedUrl(url)) {
      setState(() => urlStatus = UrlStatus.unsupported);
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
    await Future.delayed(const Duration(milliseconds: 300));
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

  bool isSupportedUrl(String url) {
    bool isSupported = true;
    try {
      for (String unsupportedUrl in Constants.unSupportedUrls) {
        if (url.contains(unsupportedUrl)) {
          isSupported = false;
          break;
        }
      }
    } catch (e) {
      isSupported = false;
    }
    return isSupported;
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
