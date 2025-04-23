import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_event.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    late final UserModel user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle settings action

              context.read<AuthBloc>().add(LogoutEvent());
            },
          ),
        ],
      ),

      body: BlocListener<UserDataBloc, UserDataState>(
        listener: (context, state) {
          if (state is UserDataErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is UserDataFetchedState) {
            user = state.user;
          }
        },
        child: BlocBuilder<UserDataBloc, UserDataState>(
          builder: (context, state) {
            if (state is UserDataLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserDataFetchedState) {
              return Center(child: Text(user.firstName),);
            } else {
              return const Center(child: Text('Error fetching user data'));
            }
          },
        ),
      ),
    );
  }
}
