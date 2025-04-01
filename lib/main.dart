import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/core/theme/app_theme.dart';
import 'package:sonique/core/theme/services/locator/locator.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final GoRouter router = locator<GoRouter>();
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: AppTheme().darkTheme,
      routerConfig: router,
    );
  }
}
