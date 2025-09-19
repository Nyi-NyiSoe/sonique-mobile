import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Data/models/playback_status.dart';
import 'package:sonique/Domain/entities/song.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_bloc.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_event.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_state.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_state.dart';
import 'package:sonique/Representation/screens/queue_page.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';

class Songdetailcard extends StatelessWidget {
  final Song song;
  final ScrollController controller;
  const Songdetailcard({
    super.key,
    required this.song,
    required this.controller,
  });

  //convert duration to min,sec
  String formatTime(Duration duration) {
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
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                    builder: (context, state) {
                      return Text(state.currentSong!.title);
                    },
                  ),
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
                        // 🎵 Song cover image
                        BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                          buildWhen:
                              (prev, curr) =>
                                  prev.currentSong != curr.currentSong,
                          builder: (context, state) {
                            final song = state.currentSong;
                            if (song == null)
                              return const SizedBox(height: 300);
                            return SizedBox(
                              height: 300,
                              child: Image.network(
                                song.coverImageUrl,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                width: double.infinity,
                              ),
                            );
                          },
                        ),

                        // 🎵 Title + artist + like button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                              buildWhen:
                                  (prev, curr) =>
                                      prev.currentSong != curr.currentSong,
                              builder: (context, state) {
                                final song = state.currentSong;
                                if (song == null) return const SizedBox();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        song.title,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.displayMedium,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(song.artist.name),
                                    ),
                                  ],
                                );
                              },
                            ),

                            BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                              builder: (context, playerState) {
                                final currentSong = playerState.currentSong;

                                return BlocSelector<
                                  LikesBloc,
                                  LikeSongState,
                                  bool
                                >(
                                  selector:
                                      (state) => state.likedSongs.any(
                                        (s) => s.id == currentSong?.id,
                                      ),
                                  builder: (context, isLiked) {
                                    return IconButton(
                                      icon: Icon(
                                        Icons.favorite,
                                        color:
                                            isLiked ? Colors.red : Colors.grey,
                                      ),
                                      onPressed: () {
                                        context.read<LikesBloc>().add(
                                          LikeSong(currentSong!.id),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
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
                  final isPlaying = state.status;
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formatTime(position)),
                            BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                              buildWhen:
                                  (prev, curr) =>
                                      prev.repeatMode != curr.repeatMode,
                              builder: (context, state) {
                                IconData icon;
                                Color color;

                                switch (state.repeatMode) {
                                  case RepeatMode.off:
                                    icon = Icons.repeat;
                                    color = Colors.grey;
                                    break;
                                  case RepeatMode.all:
                                    icon = Icons.repeat;
                                    color = Colors.green;
                                    break;
                                  case RepeatMode.one:
                                    icon = Icons.repeat_one;
                                    color = Colors.green;
                                    break;
                                }

                                return IconButton(
                                  icon: Icon(icon, color: color),
                                  onPressed: () {
                                    context.read<MusicPlayerBloc>().add(
                                      ToggleRepeat(),
                                    );
                                  },
                                );
                              },
                            ),

                            GestureDetector(
                              onTap:
                                  () => context.read<MusicPlayerBloc>().add(
                                    ToggleShuffle(),
                                  ),
                              child: Icon(
                                Icons.shuffle,
                                color: state.shuffle ? Colors.green : null,
                              ),
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
                          activeColor: Colors.blueGrey,
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
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomElevatedButton(
                              backgroundColor: Colors.blueGrey,
                              width: 100,
                              onPressed: () {
                                context.read<MusicPlayerBloc>().add(
                                  PreviousSong(),
                                );
                              },
                              child: Icon(Icons.skip_previous),
                            ),
                            CustomElevatedButton(
                              backgroundColor: Colors.blueGrey,
                              width: 100,
                              onPressed: () {
                                if (state.status == PlayBackStatus.playing) {
                                  context.read<MusicPlayerBloc>().add(
                                    PauseSong(),
                                  );
                                } else {
                                  context.read<MusicPlayerBloc>().add(
                                    ResumeSong(),
                                  );
                                }
                              },
                              child: Icon(
                                state.status == PlayBackStatus.playing
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                            ),
                            CustomElevatedButton(
                              backgroundColor: Colors.blueGrey,
                              width: 100,
                              onPressed: () {
                                context.read<MusicPlayerBloc>().add(NextSong());
                              },
                              child: Icon(Icons.skip_next),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
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
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              type: MaterialType.transparency,
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
