import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';
import 'package:sonique/Domain/usecases/login_usecase.dart';
import 'package:sonique/Domain/usecases/logout_usecase.dart';
import 'package:sonique/Domain/usecases/register_usecase.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_event.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final LogoutUsecase logoutUsecase;
  final AuthLocalDataSource authLocalDataSource;

  AuthBloc(
    this.authLocalDataSource,
    this.loginUsecase,
    this.registerUsecase,
    this.logoutUsecase,
  ) : super(UnAuthenticatedState()) {
    on<AppStartedEvent>(_onAppStarted);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onAppStarted(
    AppStartedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final user = await authLocalDataSource.getUser();
      emit(AuthSuccessState(user: user));
    } catch (e) {
      emit(UnAuthenticatedState());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await loginUsecase(event.email, event.password);
      emit(AuthSuccessState(user: user));
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await registerUsecase(
        event.email,
        event.firstName,
        event.lastName,
        event.password,
        event.username,
      );
      log("User Register: $user");
      // Automatically login after successful registration
      add(LoginEvent(email: event.email, password: event.password));
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      await logoutUsecase();
      emit(UnAuthenticatedState());
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }
}
