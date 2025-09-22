import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Data/models/song_model.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_bloc.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_event.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_state.dart';

class Customsongcard extends StatelessWidget {
  const Customsongcard({super.key, required this.song, required this.queue});
  final SongModel song;
  final bool queue;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<MusicPlayerBloc>().add(PlaySong(song));
      },
      child: SizedBox(
        height: 100,
        child: Card(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  song.coverImageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    song.artist.name,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              //if in playlist display check icon
              //Icon(Icons.check_circle, color: Colors.green),
              queue
                  ? IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        useRootNavigator: true,
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 200,

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    print('clicked');
                                    context.read<MusicPlayerBloc>().add(
                                      PlaySong(song),
                                    );
                                    context.pop();
                                  },
                                  child: ListTile(
                                    leading: Icon(Icons.play_arrow),
                                    title: Text('Play'),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    try {
                                      context.read<LikesBloc>().add(
                                        LikeSong(song.id),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Liked Song')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to like the song',
                                          ),
                                        ),
                                      );
                                    }
                                    context.pop();
                                  },
                                  child: ListTile(
                                    leading: Icon(FontAwesomeIcons.heart),
                                    title: Text('Like Song'),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    try {
                                      context.read<MusicPlayerBloc>().add(
                                        AddToQueue(song),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Added to queue'),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to add to queue',
                                          ),
                                        ),
                                      );
                                    }
                                    context.pop();
                                  },
                                  child: ListTile(
                                    leading: Icon(Icons.add),
                                    title: Text('Add to Queue'),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return SizedBox(
                                          height: 300,
                                          child: BlocBuilder<
                                            PlaylistBloc,
                                            PlaylistState
                                          >(
                                            builder: (context, state) {
                                              final playlists = state.playlists;
                                              return ListView.builder(
                                                itemCount: playlists.length,
                                                itemBuilder: (context, index) {
                                                  final playlist =
                                                      playlists[index];
                                                  return ListTile(
                                                    leading: Icon(
                                                      Icons.playlist_play,
                                                    ),
                                                    title: Text(
                                                      playlists[index].name!,
                                                    ),
                                                    onTap: () {

                                                      try{
                                                        context.read<PlaylistBloc>().add(AddToPlaylistEvent(playlistId: playlists[index].id!, songId: song.id));
                                                        ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Added to ${playlist.name}',
                                                          ),
                                                        ),
                                                      );
                                                      }catch(e){
                                                         ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Failed to add to ${playlist.name}',
                                                          ),
                                                        ),
                                                      );
                                                      }
                                                      Navigator.pop(
                                                        context,
                                                      ); // Close playlist sheet
                                                      context
                                                          .pop(); // Close main sheet
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: ListTile(
                                    leading: Icon(Icons.add),
                                    title: Text('Add to Playlist'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.more_vert),
                  )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
