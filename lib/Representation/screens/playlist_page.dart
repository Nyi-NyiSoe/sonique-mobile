import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_state.dart';
import 'package:sonique/Representation/widgets/CustomPlayList.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state.status == PlaylistStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == PlaylistStatus.success) {
            final songs = state.selectedPlaylist?.songs ?? [];

            if (songs.isEmpty) {
              return _PlaylistEmptyState(
                title: state.selectedPlaylist?.name ?? 'Playlist',
                onBack: () => Navigator.of(context).pop(),
              );
            }

            return CustomPlayList(
              songs: songs,
              playlistId: state.selectedPlaylist!.id,
            );
          } else if (state.status == PlaylistStatus.error) {
            return _PlaylistEmptyState(
              title: 'Playlist',
              message: state.message ?? 'Unable to load playlist',
              icon: Icons.error_outline,
              onBack: () => Navigator.of(context).pop(),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class _PlaylistEmptyState extends StatelessWidget {
  const _PlaylistEmptyState({
    required this.title,
    required this.onBack,
    this.message = 'No songs added yet',
    this.icon = Icons.playlist_add,
  });

  final String title;
  final VoidCallback onBack;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.queue_music,
                    color: Colors.green,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 34,
                    color: theme.iconTheme.color?.withValues(alpha: 0.58),
                  ),
                  const SizedBox(height: 10),
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
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
