import 'package:flutter/material.dart';

import '../widgets/my_appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.build(context),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Placeholder(),
    );
  }
}
