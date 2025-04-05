import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_event.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_state.dart';
import 'package:sonique/core/services/routes/routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is UnAuthenticatedState) {
            context.go(Routes.login);
            return Container();
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text("Home Page"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    // Handle logout action
                    context.read<AuthBloc>().add(LogoutEvent());
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                if (state is AuthLoadingState)
                  const Center(child: SpinKitWave(color: Colors.white)),
                Center(child: Text("Welcome to the Home Page!")),
              ],
            ),
          );
        },
      ),
    );
  }
}
