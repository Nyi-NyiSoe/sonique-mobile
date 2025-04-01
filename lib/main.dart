import 'package:flutter/material.dart';
import 'package:sonique/core/theme/app_theme.dart';
import 'package:sonique/core/theme/routes/routing_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
     final RoutingService routingService = RoutingService();
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: AppTheme().darkTheme,
      routerConfig: routingService.router,
    );
  }
}

