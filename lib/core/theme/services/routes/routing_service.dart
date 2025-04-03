import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_state.dart';
import 'package:sonique/Representation/screens/home_page.dart';
import 'package:sonique/Representation/screens/login_page.dart';
import 'package:sonique/Representation/screens/signup_page.dart';
import 'package:sonique/Representation/screens/splash_page.dart';
import 'package:sonique/core/theme/services/routes/routes.dart';

class RoutingService {
  final GoRouter router = GoRouter(
    redirect: (context, state) {
      final authBloc = context.watch<AuthBloc>();
      
      final authState = authBloc.state;
      if (authState is AuthSuccessState) {
        return Routes.home;
      } else if (authState is AuthErrorState) {
        return Routes.login;
      }
      return Routes.splash;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(path: Routes.home, builder: (context, state) => HomePage()),
      GoRoute(path: Routes.login, builder: (context, state) => LoginPage()),
      GoRoute(path: Routes.signUp, builder: (context, state) => SignupPage()),
    ],
  );
}
