import 'package:sonique/Data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);

  Future<UserModel> register(String email, String firstName, String lastName, String password,String username);

  Future<void> logout();
}