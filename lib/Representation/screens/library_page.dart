import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:sonique/Representation/widgets/library/library_actions.dart';
import 'package:sonique/Representation/widgets/library/library_colors.dart';
import 'package:sonique/Representation/widgets/library/library_components.dart';
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
      floatingActionButton: LibraryActions(isDialOpen: _isDialOpen),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: LibraryHeader()),
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
                      return LibraryTile(
                        icon: Icons.favorite,
                        title: 'Liked Songs',
                        subtitle: '$likedSongsCount songs',
                        tone: LibraryAccentTone.favorite,
                        onTap:
                            () => context.go(
                              '${Routes.library}/${Routes.likedSongPage}',
                            ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const LibrarySectionHeader(title: 'Playlists'),
                  BlocBuilder<PlaylistBloc, PlaylistState>(
                    builder: (context, state) {
                      if (state.status == PlaylistStatus.loading) {
                        return const LibraryStateMessage(
                          icon: Icons.sync,
                          message: 'Loading playlists',
                        );
                      } else if (state.status == PlaylistStatus.error) {
                        return LibraryStateMessage(
                          icon: Icons.error_outline,
                          message: state.message ?? 'Unable to load playlists',
                          actionLabel: 'Retry',
                          onAction:
                              () => context.read<PlaylistBloc>().add(
                                FetchUserPlaylistEvent(forceRefresh: true),
                              ),
                        );
                      } else if (state.status == PlaylistStatus.success) {
                        if (state.playlists.isEmpty) {
                          return LibraryStateMessage(
                            icon: Icons.playlist_add,
                            message: 'No playlists yet',
                            actionLabel: 'Create playlist',
                            onAction: () => showCreatePlaylistDialog(context),
                          );
                        }

                        return Column(
                          children:
                              state.playlists.map((playlist) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: LibraryTile(
                                    icon: Icons.queue_music,
                                    title: playlist.name ?? 'Untitled',
                                    subtitle:
                                        '${playlist.totalSongs ?? 0} songs',
                                    tone: LibraryAccentTone.primary,
                                    onTap: () {
                                      final playlistId = playlist.id;
                                      if (playlistId == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Playlist details are unavailable',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      context.read<PlaylistBloc>().add(
                                        FetchPlaylistDetailevent(
                                          playlistId: playlistId,
                                        ),
                                      );
                                      context.go(
                                        '${Routes.library}${Routes.playlistPage}',
                                      );
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
                          const LibrarySectionHeader(title: 'Artist Tools'),
                          BlocBuilder<AlbumByArtistBloc, AlbumByArtistState>(
                            builder: (context, albumState) {
                              final albumCount =
                                  albumState is AlbumByArtistLoaded
                                      ? albumState.albums.length
                                      : 0;
                              return LibraryTile(
                                icon: Icons.folder,
                                title: 'Your Albums',
                                subtitle: '$albumCount albums',
                                tone: LibraryAccentTone.artist,
                                onTap: () {
                                  context.read<AlbumByArtistBloc>().add(
                                    FetchAlbumByArtistIdEvent(null),
                                  );
                                  context.go(
                                    '${Routes.library}/${Routes.albumByArtist}',
                                  );
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
