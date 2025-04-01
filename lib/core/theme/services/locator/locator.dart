import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/core/theme/services/routes/routing_service.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // Register your services here
  // Example: locator.registerLazySingleton<SomeService>(() => SomeService());

  // Register SharedPreferences
  //final sharedPreferences = await SharedPreferences.getInstance();
  //locator.registerSingleton<SharedPreferences>(sharedPreferences);

  //GoRouter
  locator.registerLazySingleton<GoRouter>(() => RoutingService().router);
}
