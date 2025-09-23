abstract class AuthEvent {}

class AppStartedEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String username;

  RegisterEvent({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.username,
  });
}

class LogoutEvent extends AuthEvent {}
