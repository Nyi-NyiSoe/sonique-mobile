import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Domain/entities/song.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';

class Customsongcard extends StatelessWidget {
  const Customsongcard({super.key, required this.song,required this.queue});
  final Song song;
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
              queue ? IconButton(
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
                                  context.read<MusicPlayerBloc>().add(
                                    AddToQueue(song),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Added to playlist'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to add to playlist',
                                      ),
                                    ),
                                  );
                                }
                                context.pop();
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
              ) : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
