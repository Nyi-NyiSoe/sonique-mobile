import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonique/Data/repository/album_data_repo_impl/album_data_repository_impl.dart';
import 'package:sonique/Data/repository/artist_data_repo_impl/artist_data_repository_impl.dart';
import 'package:sonique/Data/repository/auth_repo_impl/auth_repository_impl.dart';
import 'package:sonique/Data/repository/playlist_data_repo_impl/playlist_repository_impl.dart';
import 'package:sonique/Data/repository/song_data_repo_impl/song_data_repository_impl.dart';
import 'package:sonique/Data/repository/user_data_repo_impl/user_data_repository_impl.dart';
import 'package:sonique/Data/services/song_service.dart';
import 'package:sonique/Data/source/album_data_repo/album_remote_data.dart';
import 'package:sonique/Data/source/artist_data_repo/artist_remote_data.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';
import 'package:sonique/Data/source/auth_repo/auth_remote_data_source.dart';
import 'package:sonique/Data/source/playlist_data_repo/playlist_remote_data.dart';
import 'package:sonique/Data/source/song_data_repo/song_remote_data.dart';
import 'package:sonique/Data/source/user_data_repo/user_remote_data.dart';
import 'package:sonique/Domain/repository/album_repository.dart';
import 'package:sonique/Domain/repository/artist_repository.dart';
import 'package:sonique/Domain/repository/auth_repository.dart';
import 'package:sonique/Domain/repository/playlist_repository.dart';
import 'package:sonique/Domain/repository/song_data_repository.dart';
import 'package:sonique/Domain/repository/user_data_repository.dart';
import 'package:sonique/Domain/usecases/add_song_to_playlist_usecase.dart';
import 'package:sonique/Domain/usecases/add_songs_to_album_usecase.dart';
import 'package:sonique/Domain/usecases/create_album_usecase.dart';
import 'package:sonique/Domain/usecases/create_playlist_usecase.dart';
import 'package:sonique/Domain/usecases/login_usecase.dart';
import 'package:sonique/Domain/usecases/logout_usecase.dart';
import 'package:sonique/Domain/usecases/register_usecase.dart';
import 'package:sonique/Domain/usecases/remove_song_from_playlist_usecase.dart';
import 'package:sonique/Domain/usecases/remove_songs_from_album_usecase.dart';
import 'package:sonique/Domain/usecases/song_data_usecase.dart';
import 'package:sonique/Domain/usecases/user_data_usecase.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_bloc.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_bloc.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/core/services/routes/routing_service.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // Register your services here
  // Example: locator.registerLazySingleton<SomeService>(() => SomeService());

  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);

  //register http
  locator.registerLazySingleton(() => http.Client());

  //register services
  locator.registerLazySingleton<SongService>(
    () => SongService(locator<SongDataRepository>()),
  );

  //Register Blocs
  locator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      locator<AuthLocalDataSource>(),
      locator<LoginUsecase>(),
      locator<RegisterUsecase>(),
      locator<LogoutUsecase>(),
    ),
  );
  locator.registerLazySingleton<SongDataBloc>(
    () => SongDataBloc(
      songDataUsecase: locator<SongDataUsecase>(),
      songService: locator<SongService>(),
    ),
  );
  locator.registerLazySingleton<UserDataBloc>(
    () => UserDataBloc(locator<UserDataUsecase>()),
  );

  locator.registerLazySingleton<MusicPlayerBloc>(() => MusicPlayerBloc());

  locator.registerLazySingleton<LikesBloc>(
    () => LikesBloc(
      songDataUsecase: locator<SongDataUsecase>(),
      songService: locator<SongService>(),
    ),
  );

  locator.registerLazySingleton<AlbumListBloc>(
    () => AlbumListBloc(albumRepository: locator<AlbumRepository>()),
  );
  locator.registerLazySingleton<AlbumDetailBloc>(
    () => AlbumDetailBloc(albumRepository: locator<AlbumRepository>()),
  );
  locator.registerLazySingleton<AlbumByArtistBloc>(
    () => AlbumByArtistBloc(albumRepository: locator<AlbumRepository>()),
  );

  locator.registerLazySingleton<AlbumOperationsBloc>(
    () => AlbumOperationsBloc(
      albumRepository: locator<AlbumRepository>(),
      createAlbumUsecase: locator<CreateAlbumUsecase>(),
      addSongsToAlbumUsecase: locator<AddSongsToAlbumUsecase>(),
      removeSongsFromAlbumUsecase: locator<RemoveSongsFromAlbumUsecase>()
    ),
  );

  locator.registerLazySingleton<ArtistBloc>(
    () => ArtistBloc(artistRepository: locator<ArtistRepository>()),
  );

  locator.registerLazySingleton<PlaylistBloc>(
    () => PlaylistBloc(
      playlistRepository: locator<PlaylistRepository>(),
      createPlaylistUsecase: locator<CreatePlaylistUsecase>(),
      addSongToPlaylistUsecase: locator<AddSongToPlaylistUsecase>(),
      removeSongFromPlaylistUsecase: locator<RemoveSongFromPlaylistUsecase>(),
    ),
  );

  //GoRouter
  locator.registerLazySingleton<GoRouter>(
    () => RoutingService(locator<AuthBloc>()).router,
  );

  //Data sources
  locator.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(sharedPreferences: locator<SharedPreferences>()),
  );
  locator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(client: locator<http.Client>()),
  );

  locator.registerLazySingleton<SongRemoteData>(
    () => SongRemoteData(
      client: locator<http.Client>(),
      authLocalDataSource: locator<AuthLocalDataSource>(),
    ),
  );

  locator.registerLazySingleton<UserRemoteData>(
    () => UserRemoteData(
      client: locator<http.Client>(),
      authLocalDataSource: locator<AuthLocalDataSource>(),
    ),
  );

  locator.registerLazySingleton<AlbumRemoteData>(
    () => AlbumRemoteData(
      client: locator<http.Client>(),
      authLocalDataSource: locator<AuthLocalDataSource>(),
    ),
  );

  locator.registerLazySingleton<ArtistRemoteData>(
    () => ArtistRemoteData(
      client: locator<http.Client>(),
      authLocalDataSource: locator<AuthLocalDataSource>(),
    ),
  );

  locator.registerLazySingleton<PlaylistRemoteData>(
    () => PlaylistRemoteData(
      client: locator<http.Client>(),
      authLocalDataSource: locator<AuthLocalDataSource>(),
    ),
  );

  //Register repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: locator<AuthLocalDataSource>(),
      remoteDataSource: locator<AuthRemoteDataSource>(),
    ),
  );

  locator.registerLazySingleton<SongDataRepository>(
    () => SongDataRepositoryImpl(songRemoteData: locator<SongRemoteData>()),
  );

  locator.registerLazySingleton<UserDataRepository>(
    () => UserDataRepositoryImpl(userRemoteData: locator<UserRemoteData>()),
  );

  locator.registerLazySingleton<AlbumRepository>(
    () => AlbumDataRepositoryImpl(albumRemoteData: locator<AlbumRemoteData>()),
  );
  locator.registerLazySingleton<ArtistRepository>(
    () =>
        ArtistDataRepositoryImpl(artistRemoteData: locator<ArtistRemoteData>()),
  );
  locator.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(
      playlistRemoteData: locator<PlaylistRemoteData>(),
    ),
  );

  //Usecases
  locator.registerLazySingleton<LoginUsecase>(
    () => LoginUsecase(locator<AuthRepository>()),
  );
  locator.registerLazySingleton<RegisterUsecase>(
    () => RegisterUsecase(locator<AuthRepository>()),
  );
  locator.registerLazySingleton<LogoutUsecase>(
    () => LogoutUsecase(locator<AuthRepository>()),
  );

  locator.registerLazySingleton<SongDataUsecase>(
    () => SongDataUsecase(songDataRepository: locator<SongDataRepository>()),
  );

  locator.registerLazySingleton<UserDataUsecase>(
    () => UserDataUsecase(locator<UserDataRepository>()),
  );
  locator.registerLazySingleton<CreateAlbumUsecase>(
    () => CreateAlbumUsecase(locator<AlbumRepository>()),
  );

  locator.registerLazySingleton<AddSongsToAlbumUsecase>(
    () => AddSongsToAlbumUsecase(locator<AlbumRepository>()),
  );

  locator.registerLazySingleton<RemoveSongsFromAlbumUsecase>(
    () => RemoveSongsFromAlbumUsecase(locator<AlbumRepository>()),
  );

  locator.registerLazySingleton<CreatePlaylistUsecase>(
    () => CreatePlaylistUsecase(locator<PlaylistRepository>()),
  );

  locator.registerLazySingleton<AddSongToPlaylistUsecase>(
    () => AddSongToPlaylistUsecase(locator<PlaylistRepository>()),
  );

  locator.registerLazySingleton<RemoveSongFromPlaylistUsecase>(
    () => RemoveSongFromPlaylistUsecase(locator<PlaylistRepository>()),
  );
}
