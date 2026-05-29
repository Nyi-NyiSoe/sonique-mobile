import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_state.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_bloc.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_state.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_event.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_state.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_state.dart';
import 'package:sonique/core/services/routes/routes.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final ValueNotifier<bool> _isDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: _LibraryActions(isDialOpen: _isDialOpen),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.library_music_outlined,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Library',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your saved songs, playlists, and releases',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.68),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  BlocBuilder<LikesBloc, LikeSongState>(
                    builder: (context, state) {
                      final likedSongsCount =
                          state.likedSongs
                              .map((song) => song.id)
                              .toSet()
                              .length;
                      return _LibraryTile(
                        icon: Icons.favorite,
                        iconColor: Colors.white,
                        background: const LinearGradient(
                          colors: [Colors.pinkAccent, Colors.redAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        title: 'Liked Songs',
                        subtitle: '$likedSongsCount songs',
                        onTap: () => context.go('/library/likedSong'),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const _SectionHeader(title: 'Playlists'),
                  BlocBuilder<PlaylistBloc, PlaylistState>(
                    builder: (context, state) {
                      if (state.status == PlaylistStatus.loading) {
                        return const _StateMessage(
                          icon: Icons.sync,
                          message: 'Loading playlists',
                        );
                      } else if (state.status == PlaylistStatus.error) {
                        return _StateMessage(
                          icon: Icons.error_outline,
                          message: state.message ?? 'Unable to load playlists',
                        );
                      } else if (state.status == PlaylistStatus.success) {
                        if (state.playlists.isEmpty) {
                          return const _StateMessage(
                            icon: Icons.playlist_add,
                            message: 'No playlists yet',
                          );
                        }

                        return Column(
                          children:
                              state.playlists.map((playlist) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _LibraryTile(
                                    icon: Icons.queue_music,
                                    iconColor: Colors.white,
                                    background: const LinearGradient(
                                      colors: [
                                        Colors.lightGreen,
                                        Colors.tealAccent,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    title: playlist.name ?? 'Untitled',
                                    subtitle:
                                        '${playlist.totalSongs ?? 0} songs',
                                    onTap: () {
                                      context.read<PlaylistBloc>().add(
                                        FetchPlaylistDetailevent(
                                          playlistId: playlist.id!,
                                        ),
                                      );
                                      context.go('/library/playlistPage');
                                    },
                                  ),
                                );
                              }).toList(),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  BlocBuilder<UserDataBloc, UserDataState>(
                    builder: (context, state) {
                      if (state is! UserDataFetchedState ||
                          !state.user.isArtist) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          const _SectionHeader(title: 'Artist Tools'),
                          BlocBuilder<AlbumByArtistBloc, AlbumByArtistState>(
                            builder: (context, albumState) {
                              final albumCount =
                                  albumState is AlbumByArtistLoaded
                                      ? albumState.albums.length
                                      : 0;
                              return _LibraryTile(
                                icon: Icons.folder,
                                iconColor: Colors.white,
                                color: Colors.blueAccent,
                                title: 'Your Albums',
                                subtitle: '$albumCount albums',
                                onTap: () {
                                  context.read<AlbumByArtistBloc>().add(
                                    FetchAlbumByArtistIdEvent(null),
                                  );
                                  context.go('/library/albumByArtist');
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDialOpen.dispose();
    super.dispose();
  }
}

class _LibraryActions extends StatelessWidget {
  const _LibraryActions({required this.isDialOpen});

  final ValueNotifier<bool> isDialOpen;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserDataBloc, UserDataState>(
      builder: (context, state) {
        if (state is! UserDataFetchedState) return const SizedBox.shrink();

        return SpeedDial(
          useRotationAnimation: true,
          icon: Icons.add,
          activeIcon: Icons.close,
          spacing: 8,
          spaceBetweenChildren: 8,
          openCloseDial: isDialOpen,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          children: [
            if (state.user.isArtist) ...[
              SpeedDialChild(
                child: const Icon(Icons.upload),
                label: 'Upload Track',
                onTap: () => context.push(Routes.upload),
              ),
              SpeedDialChild(
                child: const Icon(Icons.album),
                label: 'Upload Album',
                onTap: () => context.push(Routes.uploadAlbum),
              ),
            ],
            SpeedDialChild(
              child: const Icon(Icons.playlist_add),
              label: 'Create Playlist',
              onTap: () => _showCreatePlaylistDialog(context),
            ),
          ],
        );
      },
    );
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.background,
    this.color,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Gradient? background;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  gradient: background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
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
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color: theme.iconTheme.color?.withValues(alpha: 0.58),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }
}

void _showCreatePlaylistDialog(BuildContext context) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Create Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Playlist title'),
          onSubmitted: (_) => _createPlaylist(context, controller),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _createPlaylist(context, controller),
            child: const Text('Create'),
          ),
        ],
      );
    },
  ).whenComplete(controller.dispose);
}

void _createPlaylist(BuildContext context, TextEditingController controller) {
  final title = controller.text.trim();
  if (title.isEmpty) return;

  context.read<PlaylistBloc>().add(CreatePlaylistEvent(name: title));
  Navigator.of(context).pop();
}
