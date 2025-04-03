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
    : super(AuthInitialState()) {
    on<AppStartedEvent>((event, emit) async {
      emit(AuthLoadingState());

      final user = await authLocalDataSource.getUser();
      if (user != null) {
        emit(AuthSuccessState(user: user));
      } else {
        emit(AuthErrorState(error: "No user found"));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final user = await authUsecase.login(event.email, event.password);
        log("User: $user");
        emit(AuthSuccessState(user: user));
      } catch (e) {
        emit(AuthErrorState(error: e.toString()));
      }
    });
  }
}
