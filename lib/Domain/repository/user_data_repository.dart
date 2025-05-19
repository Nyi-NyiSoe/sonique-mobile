import 'package:image_picker/image_picker.dart';
import 'package:sonique/Data/models/user_model.dart';

abstract class UserDataRepository {
  Future<UserModel> getUserData();
  Future<String> updateUserImage(XFile? profile_image);
  Future<void> updateUserData(String? bio,String? firstName,String? lastName,String? username);
}