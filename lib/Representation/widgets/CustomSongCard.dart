import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Data/models/song_model.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_bloc.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_event.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_state.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_event.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_state.dart';

class Customsongcard extends StatelessWidget {
  const Customsongcard({super.key, required this.song, required this.queue});
  final SongModel song;
  final bool queue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.read<MusicPlayerBloc>().add(PlaySong(song));
        },
        child: SizedBox(
          height: 86,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: song.coverImageUrl,
                    width: 66,
                    height: 66,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => const SizedBox(
                          width: 66,
                          height: 66,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) =>
                            const Icon(Icons.music_note, size: 36),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      song.artist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.66,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              queue
                  ? IconButton(
                    tooltip: 'More',
                    onPressed: () => _showSongActions(context),
                    icon: const Icon(Icons.more_vert),
                  )
                  : const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showSongActions(BuildContext context) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('Play'),
                onTap: () {
                  context.read<MusicPlayerBloc>().add(PlaySong(song));
                  context.pop();
                },
              ),
              BlocBuilder<LikesBloc, LikeSongState>(
                builder: (context, state) {
                  final isLiked = state.likedSongs.any((s) => s.id == song.id);

                  return ListTile(
                    leading: Icon(
                      isLiked
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart,
                      color: isLiked ? Colors.red : null,
                    ),
                    title: Text(isLiked ? 'Unlike Song' : 'Like Song'),
                    onTap: () {
                      if (isLiked) {
                        context.read<LikesBloc>().add(UnlikeSong(song.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unliked Song')),
                        );
                      } else {
                        context.read<LikesBloc>().add(LikeSong(song.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Liked Song')),
                        );
                      }
                      context.pop();
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add to Queue'),
                onTap: () {
                  try {
                    context.read<MusicPlayerBloc>().add(AddToQueue(song));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to queue')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add to queue')),
                    );
                  }
                  context.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Add to Playlist'),
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    builder: (context) {
                      return BlocBuilder<PlaylistBloc, PlaylistState>(
                        builder: (context, state) {
                          final playlists = state.playlists;
                          if (playlists.isEmpty) {
                            return const SafeArea(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(child: Text('No playlists yet')),
                              ),
                            );
                          }

                          return SafeArea(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: playlists.length,
                              itemBuilder: (context, index) {
                                final playlist = playlists[index];
                                return ListTile(
                                  leading: const Icon(Icons.playlist_play),
                                  title: Text(playlist.name!),
                                  onTap: () {
                                    try {
                                      context.read<PlaylistBloc>().add(
                                        AddToPlaylistEvent(
                                          playlistId: playlist.id!,
                                          songId: song.id,
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Added to ${playlist.name}',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to add to ${playlist.name}',
                                          ),
                                        ),
                                      );
                                    }
                                    Navigator.pop(context);
                                    context.pop();
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
