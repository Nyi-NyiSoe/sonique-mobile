import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_state.dart';
import 'package:sonique/core/services/routes/routes.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    final userDataState = context.watch<UserDataBloc>().state;
    if (userDataState is UserDataLoadingState) {
      return const Center(child: CircularProgressIndicator());
    } else if (userDataState is UserDataErrorState) {
      return Center(child: Text(userDataState.error));
    } else if (userDataState is UserDataFetchedState) {
      final isArtist = userDataState.user.isArtist;
      // Display user data
      return Scaffold(
        appBar: AppBar(title: const Text('Library Page')),
        floatingActionButton:
            isArtist
                ? FloatingActionButton(
                  onPressed: () {
                    // Add your action for artists here
                    context.push(Routes.upload);
                  },
                  child: const Icon(Icons.add),
                )
                : null,
        body: Center(child: Text('Welcome to the Library Page!')),
      );
    }
    return const Center(child: Text('No user data available.'));
  }
}
