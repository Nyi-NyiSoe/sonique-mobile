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
  UploadSongsAlbumPage({
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
  Set<String> selectedSongIds = <String>{};
  bool isUploading = false;

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
    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 1, // full height when opened
      maxChildSize: 1.0, // prevent leaving gap
      minChildSize: 0.3, // you can allow small drag state if you like
      builder: (context, controller) {
        return Column(
          children: [
            Expanded(
              child: BlocBuilder<SongDataBloc, SongDataState>(
                builder: (context, state) {
                  if (state.fetchStatus == SongDataStatus.success) {
                    final songs = state.songs;
                    final filteredSongs =
                        songs
                            .where(
                              (song) => song.artist.artistId == widget.userId,
                            )
                            .toList();

                    return ListView.builder(
                      itemCount: filteredSongs.length,
                      itemBuilder: (context, index) {
                        final song = filteredSongs[index];
                        final isSelected = selectedSongIds.contains(song.id);
                        return CheckboxListTile(
                          title: Text(song.title),
                          subtitle: Text(song.artist.name),
                          controlAffinity: ListTileControlAffinity.trailing,
                          value: isSelected,
                          onChanged: (bool? value) {
                            toggleSongSelection(song.id);
                          },
                        );
                      },
                    );
                  } else if (state.fetchStatus == SongDataStatus.loading) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return Center(child: Text('error'));
                  }
                },
              ),
            ),

            // Button fixed at bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomElevatedButton(
                width: 100,
                child: Text('Add songs'),
                onPressed: () {
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.watch<AlbumOperationsBloc>().state.toString(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
