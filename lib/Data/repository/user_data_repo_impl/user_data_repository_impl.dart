import 'package:image_picker/image_picker.dart';
import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Data/source/user_data_repo/user_remote_data.dart';
import 'package:sonique/Domain/repository/user_data_repository.dart';

class UserDataRepositoryImpl implements UserDataRepository {
  final UserRemoteData userRemoteData;
  UserDataRepositoryImpl({required this.userRemoteData});
  @override
  Future<UserModel> getUserData() async {
    try {
      return await userRemoteData.fetchUserData();
    } catch (e) {
      throw Exception('Failed to fetch songs: $e');
    }
  }

  @override
  Future<String> updateUserImage(XFile? profile_image) async {
    try {
      return await userRemoteData.updateUserImage(profile_image);
    } catch (e) {
      throw Exception('Failed to update user image: $e');
    }
  }
  @override
  Future<void> updateUserData(
    String? bio,
    String? firstName,
    String? lastName,
    String? username,
  ) async {
    try {
      await userRemoteData.updateUserDetails(
        bio,
        firstName,
        lastName,
        username,
      );
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  @override
  Future<void> updateArtistStatus(bool isArtist) async {
    try {
      await userRemoteData.updateArtistStatus(isArtist);
    } catch (e) {
      throw Exception('Failed to update artist status: $e');
    }
  }
}
