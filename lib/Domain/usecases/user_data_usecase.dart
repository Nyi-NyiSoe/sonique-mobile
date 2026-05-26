import 'package:image_picker/image_picker.dart';
import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Domain/repository/user_data_repository.dart';

class UserDataUsecase {
  final UserDataRepository _userDataRepository;
  UserDataUsecase(this._userDataRepository);

  Future<UserModel> fetchUserData() async {
    return _userDataRepository.getUserData();
  }

  Future<String> updateUserImage(XFile? profile_image) {
    return _userDataRepository.updateUserImage(profile_image);
  }

  Future<void> updateUserData(
    String? bio,
    String? firstName,
    String? lastName,
    String? username,
  ) {
    return _userDataRepository.updateUserData(
      bio,
      firstName,
      lastName,
      username,
    );
  }

  Future<void> updateArtistStatus(bool isArtist) {
    return _userDataRepository.updateArtistStatus(isArtist);
  }
}
