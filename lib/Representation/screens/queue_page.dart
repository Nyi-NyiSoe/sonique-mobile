import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_state.dart';
import 'package:sonique/Representation/widgets/CustomSongCard.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
      builder: (context, state) {
        if (state.queue.isEmpty) {
          return Center(child: Text('No song in the queue!'));
        } else {
          final songs = state.queue;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: Icon(FontAwesomeIcons.angleDown),
                    ),

                    Text('Queue'),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(FontAwesomeIcons.bars, size: 20),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Next up'),
                ),

                Expanded(
                  child: ReorderableListView.builder(
                    itemBuilder: (context, index) {
                      return Container(
                        key: ValueKey(songs[index]),
                        child: Customsongcard(song: songs[index]),
                      );
                    },
                    itemCount: songs.length,
                    onReorder: (oldIndex, newIndex) {
                      context.read<MusicPlayerBloc>().add(
                        ReorderQueue(oldIndex: oldIndex, newIndex: newIndex),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
