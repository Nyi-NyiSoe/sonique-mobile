import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Data/services/song_service.dart';
import 'package:sonique/Domain/repository/album_repository.dart';
import 'package:sonique/Domain/repository/playlist_repository.dart';
import 'package:sonique/Domain/usecases/add_song_to_playlist_usecase.dart';
import 'package:sonique/Domain/usecases/add_songs_to_album_usecase.dart';
import 'package:sonique/Domain/usecases/create_album_usecase.dart';
import 'package:sonique/Domain/usecases/create_playlist_usecase.dart';
import 'package:sonique/Domain/usecases/remove_song_from_playlist_usecase.dart';
import 'package:sonique/Domain/usecases/remove_songs_from_album_usecase.dart';
import 'package:sonique/Domain/usecases/song_data_usecase.dart';
import 'package:sonique/Domain/usecases/user_data_usecase.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_state.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_state.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_state.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_state.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_bloc.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_event.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_state.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_event.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_state.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_bloc.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_event.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_state.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_event.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_state.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_event.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_state.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_event.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_state.dart';
import 'package:sonique/core/services/locator/locator.dart';
import 'package:sonique/core/services/routes/routes.dart';
import 'package:sonique/core/theme/app_theme.dart';
import 'package:sonique/core/theme/app_theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await setupLocator();
  await AppThemeController.instance.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final GoRouter router = locator<GoRouter>();
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(
          value: locator<AuthBloc>()..add(AppStartedEvent()),
        ),

        BlocProvider<SongDataBloc>(
          create: (context) {
            final songDataBloc = locator<SongDataBloc>();
            songDataBloc.add(FetchAllSongEvent());

            return songDataBloc;
          },
        ),

        BlocProvider<UserDataBloc>(
          create: (context) {
            final userDataBloc = UserDataBloc(locator<UserDataUsecase>());
            userDataBloc.add(FetchUserDataEvent());
            return userDataBloc;
          },
        ),

        BlocProvider<MusicPlayerBloc>(
          create: (context) {
            final musicPlayerBloc = locator<MusicPlayerBloc>();
            musicPlayerBloc.add(StopSong());
            return musicPlayerBloc;
          },
        ),

        BlocProvider<LikesBloc>(
          create: (context) {
            final likeSongBloc = LikesBloc(
              songDataUsecase: locator<SongDataUsecase>(),
              songService: locator<SongService>(),
            )..add(LoadLikedSongs());

            return likeSongBloc;
          },
        ),
        BlocProvider<AlbumListBloc>(
          create: (context) {
            final albumListBloc = locator<AlbumListBloc>();
            albumListBloc.add(FetchAlbumsEvent());
            return albumListBloc;
          },
        ),
        BlocProvider<AlbumDetailBloc>(
          create: (context) {
            final albumDetailBloc = locator<AlbumDetailBloc>();

            return albumDetailBloc;
          },
        ),
        BlocProvider<AlbumByArtistBloc>(
          create: (context) {
            final albumByArtist = AlbumByArtistBloc(
              albumRepository: locator<AlbumRepository>(),
            )..add(FetchAlbumByArtistIdEvent(null));

            return albumByArtist;
          },
        ),
        BlocProvider<AlbumOperationsBloc>(
          create: (context) {
            final albumOperation = AlbumOperationsBloc(
              addSongsToAlbumUsecase: locator<AddSongsToAlbumUsecase>(),
              albumRepository: locator<AlbumRepository>(),
              createAlbumUsecase: locator<CreateAlbumUsecase>(),
              removeSongsFromAlbumUsecase:
                  locator<RemoveSongsFromAlbumUsecase>(),
            );

            return albumOperation;
          },
        ),
        BlocProvider<ArtistBloc>(
          create: (context) {
            final artistBloc = locator<ArtistBloc>();
            artistBloc.add(FetchArtistsEvent());
            return artistBloc;
          },
        ),
        BlocProvider<PlaylistBloc>(
          create: (context) {
            final playlistBloc = PlaylistBloc(
              playlistRepository: locator<PlaylistRepository>(),
              createPlaylistUsecase: locator<CreatePlaylistUsecase>(),
              addSongToPlaylistUsecase: locator<AddSongToPlaylistUsecase>(),
              removeSongFromPlaylistUsecase:
                  locator<RemoveSongFromPlaylistUsecase>(),
            );
            playlistBloc.add(FetchUserPlaylistEvent());
            return playlistBloc;
          },
        ),
      ],
      child: ValueListenableBuilder(
        valueListenable: AppThemeController.instance,
        builder: (context, selectedTheme, _) {
          return MaterialApp.router(
            title: 'Sonique',
            theme: AppTheme().themeFor(selectedTheme),
            debugShowCheckedModeBanner: false,
            builder:
                (context, child) => _SessionExpiryGuard(
                  child: child ?? const SizedBox.shrink(),
                ),
            routerDelegate: router.routerDelegate,
            routeInformationParser: router.routeInformationParser,
            routeInformationProvider: router.routeInformationProvider,
          );
        },
      ),
    );
  }
}

class _SessionExpiryGuard extends StatefulWidget {
  const _SessionExpiryGuard({required this.child});

  final Widget child;

  @override
  State<_SessionExpiryGuard> createState() => _SessionExpiryGuardState();
}

class _SessionExpiryGuardState extends State<_SessionExpiryGuard> {
  bool _handledSessionExpiry = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccessState) {
              _handledSessionExpiry = false;
            }
          },
        ),
        BlocListener<UserDataBloc, UserDataState>(
          listener: (context, state) {
            if (state is UserDataErrorState) {
              _handleError(context, state.error);
            }
          },
        ),
        BlocListener<SongDataBloc, SongDataState>(
          listener: (context, state) => _handleError(context, state.error),
        ),
        BlocListener<LikesBloc, LikeSongState>(
          listener: (context, state) => _handleError(context, state.error),
        ),
        BlocListener<PlaylistBloc, PlaylistState>(
          listener: (context, state) {
            if (state.status == PlaylistStatus.error) {
              _handleError(context, state.message);
            }
          },
        ),
        BlocListener<AlbumListBloc, AlbumListState>(
          listener: (context, state) {
            if (state is AlbumListError) {
              _handleError(context, state.error);
            }
          },
        ),
        BlocListener<AlbumDetailBloc, AlbumDetailState>(
          listener: (context, state) {
            if (state is AlbumDetailError) {
              _handleError(context, state.error);
            }
          },
        ),
        BlocListener<AlbumByArtistBloc, AlbumByArtistState>(
          listener: (context, state) {
            if (state is AlbumByArtistError) {
              _handleError(context, state.error);
            }
          },
        ),
        BlocListener<AlbumOperationsBloc, AlbumOperationsState>(
          listener: (context, state) {
            if (state is AlbumOperationError) {
              _handleError(context, state.error);
            }
          },
        ),
        BlocListener<ArtistBloc, ArtistState>(
          listener: (context, state) {
            if (state is ArtistError) {
              _handleError(context, state.error);
            }
          },
        ),
      ],
      child: widget.child,
    );
  }

  void _handleError(BuildContext context, String? error) {
    if (_handledSessionExpiry || !_isSessionExpiredError(error)) {
      return;
    }

    _handledSessionExpiry = true;
    context.read<AuthBloc>().add(LogoutEvent());
    context.read<MusicPlayerBloc>().add(ResetPlayer());
    context.read<LikesBloc>().add(ResetBlocEvent());
    context.read<PlaylistBloc>().add(ResetLikeBlocEvent());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Your session expired. Please log in again.'),
          ),
        );
      context.go(Routes.login);
    });
  }

  bool _isSessionExpiredError(String? error) {
    if (error == null) {
      return false;
    }

    final normalized = error.toLowerCase();
    return normalized.contains('invalid refresh token') ||
        normalized.contains('invalid token') ||
        normalized.contains('token is required') ||
        normalized.contains('refresh token or access token is missing') ||
        normalized.contains('refresh token is missing') ||
        normalized.contains('access token is missing') ||
        normalized.contains('missing access token') ||
        normalized.contains('missing access token or refresh token') ||
        normalized.contains('unauthorized');
  }
}
