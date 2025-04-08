import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonique/Data/repository/auth_repo_impl/auth_repository_impl.dart';
import 'package:sonique/Data/repository/song_data_repo_impl/song_data_repository_impl.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';
import 'package:sonique/Data/source/auth_repo/auth_remote_data_source.dart';
import 'package:sonique/Data/source/song_data_repo/song_remote_data.dart';
import 'package:sonique/Domain/repository/auth_repository.dart';
import 'package:sonique/Domain/repository/song_data_repository.dart';
import 'package:sonique/Domain/usecases/auth_usecase.dart';
import 'package:sonique/Domain/usecases/song_data_usecase.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_bloc.dart';
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

  //Register Blocs
  locator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(locator<AuthUsecase>(), locator<AuthLocalDataSource>()),
  );
  locator.registerLazySingleton<SongDataBloc>(
    () => SongDataBloc(songDataUsecase: locator<SongDataUsecase>()),
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

  //Usecases
  locator.registerLazySingleton<AuthUsecase>(
    () => AuthUsecase(locator<AuthRepository>()),
  );

  locator.registerLazySingleton<SongDataUsecase>(
    () => SongDataUsecase(songDataRepository: locator<SongDataRepository>()),
  );
}
