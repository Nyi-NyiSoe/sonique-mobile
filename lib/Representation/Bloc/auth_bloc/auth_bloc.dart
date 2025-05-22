import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/source/auth_repo/auth_local_data_source.dart';
import 'package:sonique/Domain/usecases/auth_usecase.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_event.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUsecase authUsecase;
  final AuthLocalDataSource authLocalDataSource;

  AuthBloc(this.authUsecase, this.authLocalDataSource)
    : super(UnAuthenticatedState()) {
    on<AuthEvent>((event, emit) async {
      if (event is AppStartedEvent) {
        emit(AuthLoadingState());

        final user = await authLocalDataSource.getUser();
        //log("User from local data source: $user");
        emit(AuthSuccessState(user: user));
      }

      if (event is LoginEvent) {
        emit(AuthLoadingState());
        try {
          final user = await authUsecase.login(event.email, event.password);
          //log("User: $user");
          emit(AuthSuccessState(user: user));
          // log("auth success state: ${state.runtimeType}");
        } catch (e) {
          emit(AuthErrorState(error: e.toString()));
        }
      }

      if (event is RegisterEvent) {
        emit(AuthLoadingState());
        try {
          final user = await authUsecase.register(
            event.email,
            event.firstName,
            event.lastName,
            event.password,
            event.username,
          );
          log("User Register: $user");
          add(LoginEvent(email: event.email, password: event.password));
        } catch (e) {
          emit(AuthErrorState(error: e.toString()));
        }
      }

      if (event is LogoutEvent) {
        emit(AuthLoadingState());
        try {
          await authUsecase.logout();
          emit(UnAuthenticatedState());
        } catch (e) {
          emit(AuthErrorState(error: e.toString()));
        }
      }
    });
  }
}
