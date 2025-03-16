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

  SizedBox buildInvalidShortUrlHelper() {
    return SizedBox(
        height: 22,
        child: Center(
          child: Scrollbar(
            scrollbarOrientation: ScrollbarOrientation.right,
            interactive: true,
            trackVisibility: true,
            thickness: 10,
            thumbVisibility: true,
            radius: const Radius.circular(10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              
              children: [
                ColoredTextBox.red(
                  'invalid',
                  fontSize: helperFontSize,
                ),
                ColoredTextBox.grey(
                  'SUPPORTED: a-z  |  A-Z  |  0-9  |  -  |  _  |  .',
                  fontSize: helperFontSize,
                  upperCase: false,
                ),
                ColoredTextBox.grey(
                  'length: 3-50',
                  fontSize: helperFontSize,
                ),
              ],
            ),
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
