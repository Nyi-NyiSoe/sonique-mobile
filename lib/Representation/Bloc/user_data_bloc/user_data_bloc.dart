import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Domain/usecases/user_data_usecase.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_event.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_state.dart';

class UserDataBloc extends Bloc<UserDataEvent, UserDataState> {
  final UserDataUsecase _userDataUsecase;
  UserDataBloc(this._userDataUsecase) : super(UserDataInitialState()) {
    on<UserDataEvent>((event, emit) async {
      if (event is FetchUserDataEvent) {
        emit(UserDataLoadingState());
        try {
          final user = await _userDataUsecase.fetchUserData();

          log('User data fetched: ${user.toJson()}');

          emit(UserDataFetchedState(user: user));
        } catch (e) {
          emit(UserDataErrorState(error: e.toString()));
        }
      }
    });
  }
}
