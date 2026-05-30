import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Data/models/song_model.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_state.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_event.dart';
import 'package:sonique/Representation/widgets/CustomSongCard.dart';

class CustomPlayList extends StatelessWidget {
  const CustomPlayList({
    super.key,
    required this.songs,
    this.playlistId,
    this.albumId,
  });

  final List<SongModel> songs;
  final int? playlistId;
  final int? albumId;

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouter.of(context).state.uri.toString();
    final isPlaylist = currentRoute.startsWith('/library/playlistPage');
    final isAlbum = currentRoute.startsWith('/library/albumByArtist/albumDetail');
    final title =
        isPlaylist
            ? 'Playlist'
            : isAlbum
            ? 'Album'
            : 'Collection';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _PlaylistHeader(
            songs: songs,
            title: title,
            onBack: () => context.pop(),
            onPlay: () => context.read<MusicPlayerBloc>().add(PlayAList(songs)),
            onShuffle:
                () => context.read<MusicPlayerBloc>().add(ShufflePlay(songs)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index.isOdd) {
                return const SizedBox(height: 10);
              }

              final songIndex = index ~/ 2;
              final song = songs[songIndex];
              final card = Customsongcard(song: song, queue: true);

              if (isPlaylist) {
                return _DismissibleSong(
                  song: song,
                  message: '${song.title} removed from playlist',
                  onDismissed: () {
                    context.read<PlaylistBloc>().add(
                      RemoveFromPlaylistEvent(
                        playlistId: playlistId!,
                        songId: song.id,
                      ),
                    );
                  },
                  child: card,
                );
              }

              if (isAlbum) {
                return _DismissibleSong(
                  song: song,
                  message: '${song.title} removed from album',
                  onDismissed: () {
                    context.read<AlbumOperationsBloc>().add(
                      RemoveSongsFromAlbumEvent(song.id, albumId!),
                    );
                  },
                  child: card,
                );
              }

              return card;
            }, childCount: songs.isEmpty ? 0 : songs.length * 2 - 1),
          ),
        ),
      ],
    );
  }
}

class _PlaylistHeader extends StatelessWidget {
  const _PlaylistHeader({
    required this.songs,
    required this.title,
    required this.onBack,
    required this.onPlay,
    required this.onShuffle,
  });

  final List<SongModel> songs;
  final String title;
  final VoidCallback onBack;
  final VoidCallback onPlay;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewSongs = songs.take(4).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ArtworkStack(songs: previewSongs),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${songs.length} ${songs.length == 1 ? 'song' : 'songs'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.64),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            BlocSelector<
                              MusicPlayerBloc,
                              MusicPlayerState,
                              bool
                            >(
                              selector: (state) => state.shuffle,
                              builder: (context, isShuffle) {
                                return IconButton.filledTonal(
                                  tooltip: 'Shuffle',
                                  onPressed: onShuffle,
                                  icon: Icon(
                                    Icons.shuffle,
                                    color: isShuffle ? Colors.green : null,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: onPlay,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Play'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtworkStack extends StatelessWidget {
  const _ArtworkStack({required this.songs});

  final List<SongModel> songs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      height: 118,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.14)),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              if (index >= songs.length) {
                return const Icon(Icons.music_note, color: Colors.green);
              }

              return Image.network(
                songs[index].coverImageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.music_note, color: Colors.green),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DismissibleSong extends StatelessWidget {
  const _DismissibleSong({
    required this.song,
    required this.message,
    required this.onDismissed,
    required this.child,
  });

  final SongModel song;
  final String message;
  final VoidCallback onDismissed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(song.id),
      direction: DismissDirection.endToStart,
      background: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete_outline, color: Colors.white),
          ),
        ),
      ),
      onDismissed: (direction) {
        onDismissed();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      child: child,
    );
  }
}
