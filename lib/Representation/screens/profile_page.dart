import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_event.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_state.dart';
import 'package:sonique/core/services/routes/routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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

      body: BlocListener<AuthBloc,AuthState>(
        listener: (context, state) {
          if (state is UnAuthenticatedState) {
            context.go(Routes.login);
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Profile Page'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.go(Routes.home);
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
      ),
    )
    );
  }
}
