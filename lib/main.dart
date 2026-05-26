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
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_event.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_bloc.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_event.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_event.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_bloc.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_event.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_event.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_event.dart';
import 'package:sonique/core/services/locator/locator.dart';
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
            routerDelegate: router.routerDelegate,
            routeInformationParser: router.routeInformationParser,
            routeInformationProvider: router.routeInformationProvider,
          );
        },
      ),
    );
  }
}
