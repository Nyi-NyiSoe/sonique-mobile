import 'package:flutter/material.dart';
import 'package:sonique/Representation/screens/login_page.dart';
import 'package:sonique/core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme().darkTheme,
      home: LoginPage(),
    );
  }
}

