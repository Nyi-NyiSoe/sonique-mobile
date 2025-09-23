import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/song_data_status.dart';
import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_bloc.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_state.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_state.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_state.dart';

class MusicStats extends StatelessWidget {
  const MusicStats({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Music Journey',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem<PlaylistBloc, PlaylistState>(
                  'Playlists',
                  Icons.playlist_play,
                  Colors.blue,
                  context,
                  bloc: context.read<PlaylistBloc>(),
                  getCount: (state) {
                    if (state.status == PlaylistStatus.success) {
                      return state.playlists.length.toString();
                    }
                    return '0';
                  },
                ),
                _buildStatItem<SongDataBloc, SongDataState>(
                  'Songs',

                  Icons.music_note,
                  Colors.green,
                  context,
                  bloc: context.read<SongDataBloc>(),
                  getCount: (state) {
                    if (state.fetchStatus == SongDataStatus.success) {
                      final userSongs = state.songs.where(
                        (e) => user.userId == e.artist.artistId,
                      );
                      return userSongs.length.toString();
                    }
                    return '0';
                  },
                ),
                _buildStatItem<LikesBloc, LikeSongState>(
                  'Favorites',

                  Icons.favorite,
                  Colors.red,
                  context,
                  bloc: context.read<LikesBloc>(),
                  getCount: (state) {
                    if (state.status == SongDataStatus.success) {
                      return state.likedSongs
                          .map((song) => song.id) // extract the song ID
                          .toSet() // remove duplicates
                          .length
                          .toString();
                    }
                    return '0';
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildStatItem<B extends BlocBase<S>, S>(
  String label,
  IconData icon,
  Color color,
  BuildContext context, {
  required B bloc,
  required String Function(S state) getCount,
}) {
  return BlocBuilder<B, S>(
    bloc: bloc,
    builder: (context, state) {
      final count = getCount(state);

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      );
    },
  );
}
