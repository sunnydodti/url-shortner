import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/constants.dart';
import 'data/provider/theme_provider.dart';
import 'pages/home_page.dart';
import 'widgets/mobile_wrapper.dart';

class UrlShortner extends StatelessWidget {
  const UrlShortner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appDisplayName,
      theme: context.watch<ThemeProvider>().theme,
      home: MobileWrapper(child: HomePage()),
    );
  }
}
