import 'package:image_picker/image_picker.dart';
import 'package:sonique/Data/models/user_model.dart';

abstract class UserDataEvent {}

class FetchUserDataEvent extends UserDataEvent {}

class UserImageUpdateEvent extends UserDataEvent {
  final XFile? profile_image;

  UserImageUpdateEvent({required this.profile_image});
}

class UpdateUserDetailEvent extends UserDataEvent{
  final XFile? profile_image;
  final String? bio;
  final String? firstName;
  final String? lastName;
  final String? username;
  final UserModel user;

  UpdateUserDetailEvent({
    required this.profile_image,
    required this.bio,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.user,
  });
}
