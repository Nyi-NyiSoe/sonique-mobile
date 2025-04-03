import 'package:sonique/Data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
}