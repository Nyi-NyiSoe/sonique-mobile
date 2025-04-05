import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonique/Data/repository/auth_repo_impl/auth_repository_impl.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';
import 'package:sonique/Data/source/auth_repo/auth_remote_data_source.dart';
import 'package:sonique/Domain/repository/auth_repository.dart';
import 'package:sonique/Domain/usecases/auth_usecase.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
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
  locator.registerFactory<AuthBloc>(
    () => AuthBloc(
      locator<AuthUsecase>(),
      locator<AuthLocalDataSource>(),
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

  //Register repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: locator<AuthLocalDataSource>(),
      remoteDataSource: locator<AuthRemoteDataSource>(),
    ),
  );

  //Usecases
  locator.registerLazySingleton<AuthUsecase>(
    () => AuthUsecase(locator<AuthRepository>()),
  );
}
