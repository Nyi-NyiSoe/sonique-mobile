import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Data/models/song_data_status.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_state.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_bloc.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_state.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_event.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_state.dart';
import 'package:sonique/Representation/widgets/CustomAlbumCard.dart';
import 'package:sonique/Representation/widgets/CustomSongCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AlbumListBloc>().add(FetchAlbumsEvent());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 160) {
        final currentState = context.read<SongDataBloc>().state;
        if (currentState.fetchStatus == SongDataStatus.success &&
            currentState.hasMore) {
          context.read<SongDataBloc>().add(FetchMoreSongEvent());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          controller: _scrollController,
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
                      child: const Icon(Icons.graphic_eq, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sonique',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Fresh albums, artists, and songs',
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
            const SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Latest Albums',
                icon: Icons.album_outlined,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 156,
                child: BlocBuilder<AlbumListBloc, AlbumListState>(
                  builder: (context, state) {
                    if (state is AlbumListLoading) {
                      return const _ShelfLoading();
                    } else if (state is AlbumListError) {
                      return _StateMessage(
                        icon: Icons.error_outline,
                        message: state.error,
                      );
                    } else if (state is AlbumListLoaded) {
                      if (state.albums.isEmpty) {
                        return const _StateMessage(
                          icon: Icons.album_outlined,
                          message: 'No albums yet',
                        );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.albums.length,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemBuilder: (context, index) {
                          final album = state.albums[index];
                          return CustomAlbumCard(
                            albumId: album.id!,
                            imageUrl: album.coverImageUrl!,
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Artists',
                icon: Icons.person_search_outlined,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 132,
                child: BlocBuilder<ArtistBloc, ArtistState>(
                  builder: (context, state) {
                    if (state is ArtistLoading) {
                      return const _ShelfLoading();
                    } else if (state is ArtistError) {
                      return _StateMessage(
                        icon: Icons.error_outline,
                        message: state.error,
                      );
                    } else if (state is ArtistLoaded) {
                      if (state.artists.isEmpty) {
                        return const _StateMessage(
                          icon: Icons.person_outline,
                          message: 'No artists yet',
                        );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.artists.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final artist = state.artists[index];
                          return GestureDetector(
                            onTap: () {
                              context.read<AlbumByArtistBloc>().add(
                                FetchAlbumByArtistIdEvent(artist.artistId),
                              );
                              context.go(
                                '/home/artistDetail/${artist.artistId}',
                              );
                            },
                            child: SizedBox(
                              width: 92,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 78,
                                      height: 78,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.green.withValues(
                                            alpha: 0.45,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: artist.profile_image ?? '',
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) => const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                          errorWidget:
                                              (context, url, error) =>
                                                  const Icon(
                                                    Icons.person,
                                                    size: 34,
                                                  ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      artist.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      '${artist.totalSongs ?? 0} songs',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .labelSmall
                                                ?.color
                                                ?.withValues(alpha: 0.62),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: _SectionHeader(title: 'Songs', icon: Icons.music_note),
            ),
            BlocBuilder<SongDataBloc, SongDataState>(
              builder: (context, state) {
                if (state.fetchStatus == SongDataStatus.loading) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                } else if (state.fetchStatus == SongDataStatus.success) {
                  if (state.songs.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: _StateMessage(
                        icon: Icons.music_off_outlined,
                        message: 'No songs available',
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < state.songs.length) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Customsongcard(
                                song: state.songs[index],
                                queue: true,
                              ),
                            );
                          }

                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        childCount:
                            state.songs.length + (state.hasMore ? 1 : 0),
                      ),
                    ),
                  );
                }

                return const SliverToBoxAdapter(
                  child: _StateMessage(
                    icon: Icons.library_music_outlined,
                    message: 'No data available',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShelfLoading extends StatelessWidget {
  const _ShelfLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: theme.iconTheme.color?.withValues(alpha: 0.58),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.68,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
