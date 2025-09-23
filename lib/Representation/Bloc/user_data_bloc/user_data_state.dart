import 'package:sonique/Data/models/user_model.dart';

abstract class UserDataState {}

class UserDataInitialState extends UserDataState {}

class UserDataLoadingState extends UserDataState {}

class UserDataFetchedState extends UserDataState {
  final UserModel user;

  UserDataFetchedState({required this.user});
}

class UserImageUpdatedState extends UserDataState {
  final String imageUrl;

  UserImageUpdatedState({required this.imageUrl});
}

class UpdateUserDetailState extends UserDataState {
  final String? bio;
  final String? firstName;
  final String? lastName;
  final String? username;

  UpdateUserDetailState({
    required this.bio,
    required this.firstName,
    required this.lastName,
    required this.username,
  });
}


class UserDataErrorState extends UserDataState {
  final String error;

  UserDataErrorState({required this.error});
}
