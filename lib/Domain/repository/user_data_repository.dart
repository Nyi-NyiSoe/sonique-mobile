import 'package:sonique/Data/models/user_model.dart';

abstract class UserDataRepository {
  Future<UserModel> getUserData();
}