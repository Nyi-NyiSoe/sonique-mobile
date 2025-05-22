import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_state.dart';
import 'package:sonique/Representation/screens/home_page.dart';
import 'package:sonique/Representation/screens/library_page.dart';
import 'package:sonique/Representation/screens/login_page.dart';
import 'package:sonique/Representation/screens/profile_page.dart';
import 'package:sonique/Representation/screens/root_page.dart';
import 'package:sonique/Representation/screens/signup_page.dart';
import 'package:sonique/Representation/screens/upload_song_page.dart';
import 'package:sonique/core/services/routes/routes.dart';

class RoutingService {
  final AuthBloc authBloc;

  RoutingService(this.authBloc);

  late final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    redirect: (context, state) async {
      final authState = context.read<AuthBloc>().state;

      // Define auth pages that don't need redirection between them
      final isAuthPage = [
        Routes.login,
        Routes.signUp,
      ].contains(state.uri.toString());

      // IMPORTANT: For auth pages, allow free navigation between them
      if (isAuthPage) {
        return null; // Don't redirect between auth pages
      }

      // Handle states
      if (authState is UnAuthenticatedState) {
        // Only redirect to login if trying to access a protected route (not splash, login, or signup)
        return ![Routes.login, Routes.signUp].contains(state.uri.toString())
            ? Routes.login
            : null;
      } else if (authState is AuthSuccessState) {
        // Only redirect to home if trying to access auth pages
        return [Routes.login, Routes.signUp].contains(state.uri.toString())
            ? Routes.home
            : null; // ← This change allows navigation between tabs
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) {
          return LoginPage();
        },
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (context, state) {
          return SignupPage();
        },
      ),

      StatefulShellRoute.indexedStack(
        builder:
            (context, state, navigationShell) =>
                RootPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.library,
                builder: (context, state) => const LibraryPage(),
              ),
            ],
          ),
          
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.upload,
                  builder: (context, state) => const UploadSongPage(),
                ),
              ],
            ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
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
