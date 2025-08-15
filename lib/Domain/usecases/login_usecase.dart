import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Domain/repository/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _repo;
  LoginUsecase(this._repo);
  Future<UserModel> call(String username, String password) async {
    return _repo.login(username, password);
  }
}
