import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/display_artist_model.dart';
import 'package:sonique/Data/models/song_data_status.dart';
import 'package:sonique/Data/models/song_model.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_state.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_bloc.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_state.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_state.dart';
import 'package:sonique/Representation/widgets/CustomAlbumCard.dart';
import 'package:sonique/Representation/widgets/CustomSongCard.dart';

class ArtistDetailPage extends StatelessWidget {
  const ArtistDetailPage({super.key, required this.artistId});
  final int artistId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Artist Detail")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            BlocBuilder<ArtistBloc, ArtistState>(
              builder: (context, state) {
                if (state is ArtistLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ArtistLoaded) {
                  final matches = state.artists.where(
                    (a) => a.artistId == artistId,
                  );
                  if (matches.isEmpty) {
                    return const _StateMessage(
                      icon: Icons.person_off_outlined,
                      message: 'Artist not found',
                    );
                  }

                  return _ArtistInfoCard(artist: matches.first);
                } else if (state is ArtistError) {
                  return Center(
                    child: Text(
                      state.error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 20),

            // Albums Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Albums",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: BlocBuilder<AlbumByArtistBloc, AlbumByArtistState>(
                      builder: (context, state) {
                        if (state is AlbumByArtistLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else if (state is AlbumByArtistLoaded) {
                          final albums = state.albums;
                          if (albums.isNotEmpty) {
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: albums.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade600,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: CustomAlbumCard(
                                      imageUrl: albums[index].coverImageUrl!,
                                      albumId: albums[index].id!,
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return Center(
                              child: Text(
                                "This Artist has yet to release an album!",
                              ),
                            );
                          }
                        } else if (state is AlbumByArtistError) {
                          return Center(child: Text(state.error));
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Songs Section
            BlocBuilder<SongDataBloc, SongDataState>(
              builder: (context, state) {
                if (state.fetchStatus == SongDataStatus.loading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state.fetchStatus == SongDataStatus.success) {
                  final List<SongModel> filteredSongs =
                      state.songs
                          .where((song) => song.artist.artistId == artistId)
                          .toList();
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Songs",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade900,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                context.read<MusicPlayerBloc>().add(
                                  PlayAList(filteredSongs),
                                );
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text("Play All"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: filteredSongs.length,
                          separatorBuilder:
                              (_, __) => const Divider(color: Colors.white24),
                          itemBuilder: (context, index) {
                            return Customsongcard(
                              song: filteredSongs[index],
                              queue: true,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else if (state.fetchStatus == SongDataStatus.failure) {
                  return Center(child: Text(state.error.toString()));
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistInfoCard extends StatelessWidget {
  const _ArtistInfoCard({required this.artist});

  final DisplayArtistModel artist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl =
        artist.profile_image?.isNotEmpty == true
            ? artist.profile_image!
            : 'https://i.imgur.com/BoN9kdC.png';
    final bio =
        artist.bio?.trim().isNotEmpty == true
            ? artist.bio!.trim()
            : 'No bio yet';

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.42),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  errorWidget:
                      (context, url, error) =>
                          const Icon(Icons.person, size: 42),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          artist.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ArtistBadge(songCount: artist.totalSongs ?? 0),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${artist.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.62,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.72,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistBadge extends StatelessWidget {
  const _ArtistBadge({required this.songCount});

  final int songCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$songCount songs',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.green,
          fontWeight: FontWeight.w700,
        ),
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
