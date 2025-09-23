import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Data/models/song_model.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_state.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_event.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';
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
    final currentRoute = GoRouter.of(context).state.uri;

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                opacity: 0.7,
                filterQuality: FilterQuality.high,
                colorFilter: ColorFilter.mode(
                  Colors.grey,
                  BlendMode.saturation,
                ),
                fit: BoxFit.cover,
                image: NetworkImage(songs[songs.length - 1].coverImageUrl),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: Icon(FontAwesomeIcons.angleLeft),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("${songs.length} songs")],
                      ),
                      Row(
                        children: [
                          BlocSelector<MusicPlayerBloc, MusicPlayerState, bool>(
                            selector: (state) => state.shuffle,
                            builder: (context, isShuffle) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomElevatedButton(
                                  borderRadius: 100,
                                  width: 50,
                                  height: 50,
                                  backgroundColor: Colors.black87,
                                  child: Icon(
                                    Icons.shuffle,
                                    color:
                                        isShuffle ? Colors.green : Colors.white,
                                  ),
                                  onPressed: () {
                                    context.read<MusicPlayerBloc>().add(
                                      ShufflePlay(songs),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomElevatedButton(
                              borderRadius: 100,
                              width: 50,
                              height: 50,
                              backgroundColor: Colors.black87,
                              child: Icon(Icons.play_arrow),
                              onPressed: () {
                                context.read<MusicPlayerBloc>().add(
                                  PlayAList(songs),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(10),
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];

                if (currentRoute.toString().startsWith(
                  "/library/playlistPage",
                )) {
                  return Dismissible(
                    key: ValueKey(UniqueKey()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      context.read<PlaylistBloc>().add(
                        RemoveFromPlaylistEvent(
                          playlistId: playlistId!,
                          songId: song.id,
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${song.title} removed from playlist"),
                        ),
                      );
                    },
                    child: Customsongcard(song: song, queue: true),
                  );
                } else if (currentRoute.toString().startsWith(
                  "/library/albumByArtist/albumDetail",
                )) {
                  return Dismissible(
                    key: ValueKey(UniqueKey()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      context.read<AlbumOperationsBloc>().add(
                        RemoveSongsFromAlbumEvent(song.id, albumId!),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${song.title} removed from album"),
                        ),
                      );
                    },
                    child: Customsongcard(song: song, queue: true),
                  );
                } else {
                  // Normal card (no swipe-to-delete)
                  return Customsongcard(song: song, queue: true);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
