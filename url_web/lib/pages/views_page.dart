import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';
import '../data/constants.dart';
import '../service/url_service.dart';
import '../widgets/colored_text_box.dart';
import '../widgets/mobile_wrapper.dart';
import '../widgets/my_appbar.dart';

enum ViewStatus { none, checking, valid, invalid }

class ViewsPage extends StatefulWidget {
  const ViewsPage({super.key});

  @override
  ViewsPageState createState() => ViewsPageState();
}

class ViewsPageState extends State<ViewsPage> {
  final TextEditingController _inputController = TextEditingController();
  ViewStatus viewStatus = ViewStatus.none;
  int? views;
  bool isLoading = false;
  Timer? inputTimer;
  String previousCode = '';
  int previousViews = 0;
  final double helperFontSize = 9;

  @override
  void dispose() {
    _inputController.dispose();
    inputTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchViews() async {
    setState(() => isLoading = true);

    try {
      String input = _inputController.text.trim();
      if (!isValidInput(input)) throw Exception('Invalid input');
      String shortCode = getShortCode(input);

      final fetchedViews = await UrlService.getViews(shortCode);
      setState(() {
        views = fetchedViews;
        previousViews = fetchedViews;
        previousCode = shortCode;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        showSnackbar(e.toString().replaceAll('Exception: ', ''));
        isLoading = false;
        views = null;
      });
    }
  }

  String getShortCode(String input) {
    String shortCode = input
        .replaceFirst('https://', '')
        .replaceFirst('http://', '')
        .replaceFirst('urls.persist.site/', '')
        .replaceFirst('url.persist.site/', '');
    return shortCode;
  }

  void onInputChanged(String? value) {
    if (inputTimer != null && inputTimer!.isActive) {
      inputTimer!.cancel();
    }

    setState(() => viewStatus = ViewStatus.checking);
    inputTimer = Timer(const Duration(milliseconds: 400), () {
      evaluateInput(value);
    });
  }

  void evaluateInput(String? input) {
    if (input == null || input.isEmpty) {
      setState(() => viewStatus = ViewStatus.none);
      return;
    }

    views = null;
    if (!isValidInput(input)) {
      setState(() => viewStatus = ViewStatus.invalid);
      return;
    }
    if (getShortCode(input) == previousCode) {
      setState(() {
        viewStatus = ViewStatus.valid;
        views = previousViews;
      });
      return;
    }
    setState(() => viewStatus = ViewStatus.valid);
  }

  bool isValidInput(String input) {
    if (isURL(input)) {
      if (!input.contains('url.persist.site')) return false;
      return true;
    }
    if (input.length < 3) return false;

    if (!RegExp(r'^[a-zA-Z0-9-_.]+$').hasMatch(input)) return false;
    return true;
  }

  bool isValidUrl(String url) {
    try {
      return isURL(url);
    } catch (e) {
      return false;
    }
  }

  Future<String> get clipboardText async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      return clipboardData?.text ?? '';
    } catch (_) {
      return '';
    }
  }

  void pasteFromClipboard() async {
    final text = await clipboardText;
    _inputController.text = text;
    onInputChanged(text);
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MobileWrapper(
      child: Scaffold(
        appBar: MyAppbar.build(context, title: 'Check Views'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildInputField(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: viewStatus == ViewStatus.valid ? _fetchViews : null,
                child: const Text('Check Views'),
              ),
              const SizedBox(height: 16),
              if (views != null) _buildResult(),
              if (isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildResult() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                launchUrl(Uri.parse('${Constants.apiBase}/$previousCode'));
              },
              child: ColoredTextBox.blue(
                '${Constants.apiBase}/$previousCode',
                fontSize: 18,
                upperCase: false,
              ),
            ),
            Spacer(),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            ColoredTextBox.green(
              'Views: $views',
              fontSize: 18,
              upperCase: false,
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }

  TextField _buildInputField() {
    return TextField(
      controller: _inputController,
      onChanged: onInputChanged,
      decoration: InputDecoration(
        labelText: 'Enter URL or Short Code',
        border: const OutlineInputBorder(),
        helper: _getHelperText(),
        suffix: IconButton(
          icon: const Icon(Icons.clear_outlined),
          onPressed: () {
            views = null;
            _inputController.clear();
            setState(() => viewStatus = ViewStatus.none);
          },
        ),
      ),
    );
  }

  Widget? _getHelperText() {
    switch (viewStatus) {
      case ViewStatus.none:
        return GestureDetector(
          onTap: pasteFromClipboard,
          child: ColoredTextBox.blue('Paste', fontSize: helperFontSize),
        );
      case ViewStatus.checking:
        return ColoredTextBox.grey('Checking...', fontSize: helperFontSize);
      case ViewStatus.valid:
        return ColoredTextBox.green('Valid', fontSize: helperFontSize);
      case ViewStatus.invalid:
        return ColoredTextBox.red('Invalid input', fontSize: helperFontSize);
    }
  }
}
