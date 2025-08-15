import 'package:sonique/Domain/repository/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository _repo;
  LogoutUsecase(this._repo);
   Future<void> call() async {
    return _repo.logout();
  }
}
