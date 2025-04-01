import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/screens/home_page.dart';
import 'package:sonique/Representation/screens/login_page.dart';
import 'package:sonique/Representation/screens/splash_page.dart';
import 'package:sonique/core/theme/routes/routes.dart';

class RoutingService {
  final GoRouter router = GoRouter(
    initialLocation: "/splash",
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(path: Routes.home, builder: (context, state) => const HomePage()),
      GoRoute(path: Routes.login, builder: (context, state) => LoginPage()),
      //GoRoute(path: Routes.signUp, builder: (context, state) =>  SignUpPage()),
    ],
  );
}
