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

  
}
