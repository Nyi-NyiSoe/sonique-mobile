import 'package:sonique/Data/models/user_model.dart';

abstract class UserDataState {

}

class UserDataInitialState extends UserDataState {}

class UserDataLoadingState extends UserDataState {}

class UserDataFetchedState extends UserDataState {
  final UserModel user;

  UserDataFetchedState({
    required this.user,
  });
}

class UserDataErrorState extends UserDataState {
  final String error;

  UserDataErrorState({required this.error});
}