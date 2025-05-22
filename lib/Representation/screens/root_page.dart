import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_state.dart';

class RootPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const RootPage({required this.navigationShell, Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserDataBloc, UserDataState>(
      builder: (context, state) {
        if (state is UserDataFetchedState) {
          final isArtist = state.user.isArtist;
          return Scaffold(
            body: widget.navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: (index) {
                widget.navigationShell.goBranch(index);
              },
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.library_music_outlined),
                  selectedIcon: Icon(Icons.library_music),
                  label: 'Library',
                ),
                if (isArtist)
                  NavigationDestination(
                    icon: Icon(Icons.upload_file_outlined),
                    selectedIcon: Icon(Icons.upload_file),
                    label: 'Upload',
                  ),

                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        } else if (state is UserDataErrorState) {
          return Scaffold(body: Center(child: Text('Error: ${state.error}')));
        } else if (state is UserDataLoadingState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text('Something went wrong')),
          );
        }
      },
    );
  }
}
