import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Data/models/song_data_status.dart';
import 'package:sonique/Data/models/song_model.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_state.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_bloc.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_event.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_state.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
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
    final accent = theme.colorScheme.primary;

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
                        color: accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.graphic_eq, color: accent),
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
                            'Pick up a track or browse new releases',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.72),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<SongDataBloc, SongDataState>(
                builder: (context, state) {
                  if (state.fetchStatus == SongDataStatus.loading) {
                    return const _StartListeningLoading();
                  }

                  if (state.fetchStatus == SongDataStatus.success &&
                      state.songs.isNotEmpty) {
                    return _StartListeningCard(song: state.songs.first);
                  }

                  return const SizedBox.shrink();
                },
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
                height: 176,
                child: BlocBuilder<AlbumListBloc, AlbumListState>(
                  builder: (context, state) {
                    if (state is AlbumListLoading) {
                      return const _ShelfLoading(
                        itemCount: 4,
                        itemWidth: 128,
                        itemHeight: 150,
                      );
                    } else if (state is AlbumListError) {
                      return _StateMessage(
                        icon: Icons.error_outline,
                        message: 'Albums could not load. Try again.',
                        actionLabel: 'Retry albums',
                        onAction:
                            () => context.read<AlbumListBloc>().add(
                              FetchAlbumsEvent(),
                            ),
                      );
                    } else if (state is AlbumListLoaded) {
                      if (state.albums.isEmpty) {
                        return const _StateMessage(
                          icon: Icons.album_outlined,
                          message:
                              'No albums yet. Browse songs while artists add releases.',
                        );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.albums.length,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemBuilder: (context, index) {
                          final album = state.albums[index];
                          return CustomAlbumCard(
                            albumId: album.id ?? 0,
                            imageUrl: album.coverImageUrl ?? '',
                            albumName: album.name,
                            showTitle: true,
                            size: 128,
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
                height: 138,
                child: BlocBuilder<ArtistBloc, ArtistState>(
                  builder: (context, state) {
                    if (state is ArtistLoading) {
                      return const _ShelfLoading(
                        itemCount: 4,
                        itemWidth: 92,
                        itemHeight: 124,
                        circularImage: true,
                      );
                    } else if (state is ArtistError) {
                      return _StateMessage(
                        icon: Icons.error_outline,
                        message: 'Artists could not load. Try again.',
                        actionLabel: 'Retry artists',
                        onAction:
                            () => context.read<ArtistBloc>().add(
                              FetchArtistsEvent(),
                            ),
                      );
                    } else if (state is ArtistLoaded) {
                      if (state.artists.isEmpty) {
                        return const _StateMessage(
                          icon: Icons.person_outline,
                          message: 'No artists yet. Songs will appear below.',
                        );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.artists.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final artist = state.artists[index];
                          return _ArtistCard(
                            name: artist.name,
                            imageUrl: artist.profile_image ?? '',
                            songCount: artist.totalSongs ?? 0,
                            onTap: () {
                              context.read<AlbumByArtistBloc>().add(
                                FetchAlbumByArtistIdEvent(artist.artistId),
                              );
                              context.go(
                                '/home/artistDetail/${artist.artistId}',
                              );
                            },
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
                  return const SliverToBoxAdapter(child: _SongListLoading());
                } else if (state.fetchStatus == SongDataStatus.success) {
                  if (state.songs.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: _StateMessage(
                        icon: Icons.music_off_outlined,
                        message:
                            'No songs available yet. Check back after tracks are uploaded.',
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
                } else if (state.fetchStatus == SongDataStatus.failure) {
                  return SliverToBoxAdapter(
                    child: _StateMessage(
                      icon: Icons.error_outline,
                      message: 'Songs could not load. Try again.',
                      actionLabel: 'Retry songs',
                      onAction:
                          () => context.read<SongDataBloc>().add(
                            FetchAllSongEvent(),
                          ),
                    ),
                  );
                }

                return const SliverToBoxAdapter(
                  child: _StateMessage(
                    icon: Icons.library_music_outlined,
                    message: 'Songs will appear here when they are ready.',
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

class _StartListeningCard extends StatelessWidget {
  const _StartListeningCard({required this.song});

  final SongModel song;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.read<MusicPlayerBloc>().add(PlaySong(song)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: song.coverImageUrl,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) =>
                            _BlockPlaceholder(width: 58, height: 58, radius: 8),
                    errorWidget:
                        (context, url, error) => Container(
                          width: 58,
                          height: 58,
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          child: Icon(
                            Icons.music_note,
                            color: theme.iconTheme.color?.withValues(
                              alpha: 0.58,
                            ),
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start listening',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.artist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.68,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.play_circle_fill, color: accent, size: 34),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartListeningLoading extends StatelessWidget {
  const _StartListeningLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        height: 82,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            _BlockPlaceholder(width: 58, height: 58, radius: 8),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BlockPlaceholder(width: 92, height: 12, radius: 8),
                  SizedBox(height: 8),
                  _BlockPlaceholder(width: 180, height: 16, radius: 8),
                  SizedBox(height: 8),
                  _BlockPlaceholder(width: 128, height: 12, radius: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  const _ArtistCard({
    required this.name,
    required this.imageUrl,
    required this.songCount,
    required this.onTap,
  });

  final String name;
  final String imageUrl;
  final int songCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Semantics(
      button: true,
      label: 'Open artist $name',
      child: SizedBox(
        width: 92,
        child: Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accent.withValues(alpha: 0.42),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Icon(
                                Icons.person,
                                size: 34,
                                color: theme.iconTheme.color?.withValues(
                                  alpha: 0.58,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$songCount songs',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.textTheme.labelSmall?.color?.withValues(
                          alpha: 0.62,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
          Icon(icon, size: 20, color: theme.colorScheme.primary),
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
  const _ShelfLoading({
    required this.itemCount,
    required this.itemWidth,
    required this.itemHeight,
    this.circularImage = false,
  });

  final int itemCount;
  final double itemWidth;
  final double itemHeight;
  final bool circularImage;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder:
          (context, index) => SizedBox(
            width: itemWidth,
            height: itemHeight,
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                children: [
                  _BlockPlaceholder(
                    width: circularImage ? 78 : itemWidth - 14,
                    height: circularImage ? 78 : itemWidth - 14,
                    radius: circularImage ? 999 : 8,
                  ),
                  if (!circularImage) ...[
                    const SizedBox(height: 8),
                    _BlockPlaceholder(
                      width: itemWidth - 28,
                      height: 12,
                      radius: 8,
                    ),
                  ],
                  if (circularImage) ...[
                    const SizedBox(height: 8),
                    const _BlockPlaceholder(width: 64, height: 12, radius: 8),
                    const SizedBox(height: 6),
                    const _BlockPlaceholder(width: 44, height: 10, radius: 8),
                  ],
                ],
              ),
            ),
          ),
    );
  }
}

class _SongListLoading extends StatelessWidget {
  const _SongListLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
      child: Column(
        children: List.generate(
          4,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: _SongRowPlaceholder(),
          ),
        ),
      ),
    );
  }
}

class _SongRowPlaceholder extends StatelessWidget {
  const _SongRowPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 86,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          _BlockPlaceholder(width: 66, height: 66, radius: 8),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BlockPlaceholder(width: 180, height: 16, radius: 8),
                SizedBox(height: 8),
                _BlockPlaceholder(width: 112, height: 12, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockPlaceholder extends StatelessWidget {
  const _BlockPlaceholder({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.32,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

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
                  alpha: 0.72,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 10),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
