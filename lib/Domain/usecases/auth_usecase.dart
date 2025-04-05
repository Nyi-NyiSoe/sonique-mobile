import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Domain/repository/auth_repository.dart';

class AuthUsecase {
  final AuthRepository _authRepository;

  AuthUsecase(this._authRepository);

  Future<UserModel> login(String username, String password) async {
    return _authRepository.login(username, password);
  }

  Future<UserModel> register(
    String email,
    String firstName,
    String lastName,
    String password,
    String username,
  ) async {
    return _authRepository.register(email, firstName, lastName, password,username);
  }

  Future<void> logout() async {
    return _authRepository.logout();
  }
}
