import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Domain/repository/user_data_repository.dart';

class UserDataUsecase {
  final UserDataRepository _userDataRepository;
  UserDataUsecase(this._userDataRepository);

  Future<UserModel> fetchUserData() async {
    return _userDataRepository.getUserData();
  }
}
