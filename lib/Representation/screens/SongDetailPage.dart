import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Domain/entities/song.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_state.dart';
import 'package:sonique/Representation/screens/queue_page.dart';

class Songdetailcard extends StatelessWidget {
  final Song song;
  final ScrollController controller;
  const Songdetailcard({
    super.key,
    required this.song,
    required this.controller,
  });

  //convert duration to min,sec
  String formatTime(Duration duration){
    String twoDigitSeconds = duration.inSeconds.remainder(60).toString();
    String formattedTime = "${duration.inMinutes}:${twoDigitSeconds}";

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          controller: controller,
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
                Text(song.title),
                IconButton(
                  onPressed: () {},
                  icon: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                    builder: (context, state) {
                      if (state.queue.isEmpty) {
                        return SizedBox.shrink();
                      } else {
                        return GestureDetector(
                          onTap: () {
                            _showQueue(context);
                          },
                          child: Icon(FontAwesomeIcons.bars),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 300,
                        child: Image.network(
                          song.coverImageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          width: double.infinity,
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  song.title,
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(song.artist.name),
                              ),
                            ],
                          ),

                          IconButton(
                            onPressed: () {},
                            icon: Icon(FontAwesomeIcons.heart),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
              builder: (context, state) {
                final total = Duration(
                  seconds: (state.currentSong?.duration ?? 0).toInt(),
                );
                final position = state.position;
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatTime(position)),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.shuffle),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.repeat),
                          ),
                          Text(formatTime(total)),
                        ],
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 0,
                        ),
                      ),
                      child: Slider(
                        min: 0.0,
                        max: total.inSeconds.toDouble(),
                        activeColor: Colors.green,
                        value: position.inSeconds.toDouble(),
                        onChanged: (value) {
                          context.read<MusicPlayerBloc>().add(
                            UpdatePosition(Duration(seconds: value.toInt())),
                          );
                        },
                        onChangeEnd: (value) {
                          context.read<MusicPlayerBloc>().add(
                            SeekToEvent(Duration(seconds: value.toInt())),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.skip_previous)),
                IconButton(
                  onPressed: () {
                    context.read<MusicPlayerBloc>().add(PlaySong(song));
                  },
                  icon: Icon(Icons.play_arrow),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.skip_next)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showQueue(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Queue",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: MediaQuery.of(context).size.width, // slide panel width
          child: Material(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: QueuePage(),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(1, 0), // from right
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
