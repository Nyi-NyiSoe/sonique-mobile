import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_event.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_state.dart';
import 'package:sonique/Representation/widgets/library/create_playlist_dialog.dart';
import 'package:sonique/core/services/routes/routes.dart';

class LibraryActions extends StatelessWidget {
  const LibraryActions({super.key, required this.isDialOpen});

  final ValueNotifier<bool> isDialOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          children: [
            if (state.user.isArtist) ...[
              SpeedDialChild(
                child: const Icon(Icons.upload),
                backgroundColor: theme.colorScheme.tertiaryContainer,
                foregroundColor: theme.colorScheme.onTertiaryContainer,
                label: 'Upload Track',
                onTap: () => context.push(Routes.upload),
              ),
              SpeedDialChild(
                child: const Icon(Icons.album),
                backgroundColor: theme.colorScheme.tertiaryContainer,
                foregroundColor: theme.colorScheme.onTertiaryContainer,
                label: 'Upload Album',
                onTap: () => context.push(Routes.uploadAlbum),
              ),
            ],
            SpeedDialChild(
              child: const Icon(Icons.playlist_add),
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              label: 'Create Playlist',
              onTap: () => showCreatePlaylistDialog(context),
            ),
          ],
        );
      },
    );
  }
}

void showCreatePlaylistDialog(BuildContext context) {
  final playlistBloc = context.read<PlaylistBloc>();

  showDialog(
    context: context,
    builder:
        (dialogContext) => CreatePlaylistDialog(
          onCreate: (title) {
            playlistBloc.add(CreatePlaylistEvent(name: title));
            Navigator.of(dialogContext).pop();
          },
        ),
  );
}
