import 'package:image_picker/image_picker.dart';

abstract class UserDataEvent {}

class FetchUserDataEvent extends UserDataEvent {}

class UserImageUpdateEvent extends UserDataEvent {
  final XFile? profile_image;

  UserImageUpdateEvent({required this.profile_image});
}

class UpdateUserDetailEvent extends UserDataEvent {
  final String? bio;
  final String? firstName;
  final String? lastName;
  final String? username;

  UpdateUserDetailEvent({
    required this.bio,
    required this.firstName,
    required this.lastName,
    required this.username,
  });
}
