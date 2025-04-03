import 'dart:async';

import 'package:flutter/widgets.dart';
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
  final AuthBloc authBloc;
  RoutingService(this.authBloc);

  late final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    redirect: (context, state) async {
      final authState = context.read<AuthBloc>().state;

      // Define public routes that don't require authentication
      final isPublicRoute = [
        Routes.login,
        Routes.signUp,
        Routes.splash,
      ].contains(state.uri.toString());

      // Don't redirect during auth loading to avoid interrupting the process
      if (authState is AuthLoadingState) {
        return null;
      }

      // If authenticated, don't allow access to login/signup pages
      if (authState is AuthSuccessState &&
          isPublicRoute &&
          state.uri.toString() != Routes.splash) {
        return Routes.home;
      }

      // If not authenticated, only allow access to public routes
      if (authState is UnAuthenticatedState && !isPublicRoute) {
        return Routes.login;
      }

      // Default case - no redirect needed
      return null;
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

// Better stream to listenable converter
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      // This will ensure immediate notification
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
