import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Data/models/playback_status.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_bloc.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_state.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_event.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_event.dart';
import 'package:sonique/Representation/widgets/miniplayer.dart';

class RootPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const RootPage({required this.navigationShell, Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index, BuildContext context) {
    setState(() {
      _selectedIndex = index;
    });

    // Trigger fetch when Library is selected
    if (index == 1 || index == 2) {
      // assuming Library is at index 1
      context.read<PlaylistBloc>().add(FetchUserPlaylistEvent());
      context.read<LikesBloc>().add(LoadLikedSongs());
      context.read<UserDataBloc>().add(FetchUserDataEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
            builder: (context, state) {
              if (state.currentSong == null) {
                return const SizedBox.shrink();
              }

              return MiniPlayer(
                song: state.currentSong!,
                isPlaying: state.status == PlayBackStatus.playing,
                onPlayPause: () {
                  if (state.status == PlayBackStatus.playing) {
                    context.read<MusicPlayerBloc>().add(PauseSong());
                  } else {
                    context.read<MusicPlayerBloc>().add(ResumeSong());
                  }
                },
                onNext: () {
                  context.read<MusicPlayerBloc>().add(NextSong());
                },
              );
            },
          ),
          NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              _onItemTapped(index, context);
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

              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
