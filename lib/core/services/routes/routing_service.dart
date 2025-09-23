import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_state.dart';
import 'package:sonique/Representation/screens/album_by_artist_page.dart';
import 'package:sonique/Representation/screens/album_detail_page.dart';
import 'package:sonique/Representation/screens/artist_detail_page.dart';
import 'package:sonique/Representation/screens/home_page.dart';
import 'package:sonique/Representation/screens/library_page.dart';
import 'package:sonique/Representation/screens/like_song_page.dart';
import 'package:sonique/Representation/screens/login_page.dart';
import 'package:sonique/Representation/screens/playlist_page.dart';
import 'package:sonique/Representation/screens/profile_page.dart';
import 'package:sonique/Representation/screens/root_page.dart';
import 'package:sonique/Representation/screens/signup_page.dart';
import 'package:sonique/Representation/screens/upload_album_page.dart';
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
      GoRoute(
        path: Routes.upload,
        builder: (context, state) {
          return UploadSongPage();
        },
      ),
       GoRoute(
        path: Routes.uploadAlbum,
        builder: (context, state) {
          return UploadAlbumPage();
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
                builder: (context, state) => HomePage(),
                routes: [
                  GoRoute(
                    path: Routes.albumDetailPage,
                    builder: (context, state) {
                      return AlbumDetailPage();
                    },
                  ),
                  GoRoute(
                    path: Routes.artistDetail,
                    builder: (context, state) {
                      final artistId = int.parse(state.pathParameters['id']!);
                      return ArtistDetailPage(artistId: artistId,);
                    },
                    routes: [
                       GoRoute(
                    path: Routes.albumDetailPage,
                    builder: (context, state) {
                      return AlbumDetailPage();
                    },
                  ),
                    ]
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.library,
                builder: (context, state) => LibraryPage(),
                routes: [
                  GoRoute(
                    path: Routes.likedSongPage,
                    builder: (context, state) {
                      return LikeSongPage();
                    },
                  ),
                  GoRoute(
                    path: Routes.playlistPage,
                    builder: (context, state) {
                      return PlaylistPage();
                    },
                  ),
                  GoRoute(
                    path: Routes.albumByArtist,
                    builder: (context, state) {
                      return AlbumByArtistPage();
                    },
                    routes: [
                      GoRoute(
                        path: Routes.albumDetailPage,
                        builder: (context, state) {
                          return AlbumDetailPage();
                        },
                      ),
                    ],
                  ),
                ],
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
