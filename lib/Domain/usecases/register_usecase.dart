import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Domain/repository/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository _repo;
  RegisterUsecase(this._repo);
  Future<UserModel> call(
    String email,
    String firstName,
    String lastName,
    String password,
    String username,
  ) async {
    return _repo.register(email, firstName, lastName, password,username);
  }
}