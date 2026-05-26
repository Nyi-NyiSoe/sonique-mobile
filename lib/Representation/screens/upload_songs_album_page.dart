import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Data/models/song_data_status.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_event.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_state.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';

class UploadSongsAlbumPage extends StatefulWidget {
  const UploadSongsAlbumPage({
    super.key,
    required this.userId,
    required this.albumId,
  });

  final int userId;
  final int albumId;

  @override
  State<UploadSongsAlbumPage> createState() => _UploadSongsAlbumPageState();
}

class _UploadSongsAlbumPageState extends State<UploadSongsAlbumPage> {
  final Set<String> selectedSongIds = <String>{};

  void toggleSongSelection(String songId) {
    setState(() {
      if (selectedSongIds.contains(songId)) {
        selectedSongIds.remove(songId);
      } else {
        selectedSongIds.add(songId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 1,
      maxChildSize: 1,
      minChildSize: 0.3,
      builder: (context, controller) {
        return Material(
          color: theme.scaffoldBackgroundColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
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
                        Icons.playlist_add,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Songs',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${selectedSongIds.length} selected',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.68),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<SongDataBloc, SongDataState>(
                  builder: (context, state) {
                    if (state.fetchStatus == SongDataStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.fetchStatus != SongDataStatus.success) {
                      return const _StateMessage(
                        icon: Icons.error_outline,
                        message: 'Unable to load songs',
                      );
                    }

                    final filteredSongs =
                        state.songs
                            .where(
                              (song) => song.artist.artistId == widget.userId,
                            )
                            .toList();

                    if (filteredSongs.isEmpty) {
                      return const _StateMessage(
                        icon: Icons.music_off_outlined,
                        message: 'No tracks available for this album',
                      );
                    }

                    return ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      itemCount: filteredSongs.length,
                      itemBuilder: (context, index) {
                        final song = filteredSongs[index];
                        final isSelected = selectedSongIds.contains(song.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SongSelectTile(
                            title: song.title,
                            artist: song.artist.name,
                            imageUrl: song.coverImageUrl,
                            isSelected: isSelected,
                            onTap: () => toggleSongSelection(song.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: CustomElevatedButton(
                    backgroundColor: Colors.green,
                    onPressed: selectedSongIds.isEmpty ? null : _addSongs,
                    child: Text(
                      selectedSongIds.isEmpty
                          ? 'Select Songs'
                          : 'Add ${selectedSongIds.length} Songs',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addSongs() {
    try {
      context.read<AlbumOperationsBloc>().add(
        AddSongsToAlbumEvent(selectedSongIds, widget.albumId),
      );
      context.read<AlbumByArtistBloc>().add(
        FetchAlbumByArtistIdEvent(widget.userId),
      );
      context.read<AlbumDetailBloc>().add(
        FetchAlbumDetailEvent(widget.albumId),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

class _SongSelectTile extends StatelessWidget {
  const _SongSelectTile({
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String artist;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

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
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => const SizedBox(
                        width: 56,
                        height: 56,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) =>
                          const Icon(Icons.music_note, size: 34),
                ),
              ),
              const SizedBox(width: 12),
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
                      artist,
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
              Checkbox(value: isSelected, onChanged: (_) => onTap()),
            ],
          ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
