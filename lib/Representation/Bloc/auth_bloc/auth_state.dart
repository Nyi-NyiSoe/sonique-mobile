import 'package:sonique/Data/models/user_model.dart';

abstract class AuthState {}

class AuthInitialState extends AuthState {}

class UnAuthenticatedState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final UserModel user;

  AuthSuccessState({required this.user});
}

class AuthErrorState extends AuthState {
  final String error;

  AuthErrorState({required this.error});
}
