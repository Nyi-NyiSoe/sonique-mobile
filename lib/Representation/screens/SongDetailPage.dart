import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
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

class Songdetailcard extends StatelessWidget {
  const Songdetailcard({
    super.key,
    required this.song,
    required this.controller,
  });

  final Song song;
  final ScrollController controller;

  String formatTime(Duration duration) {
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inMinutes}:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2A2A2A), Color(0xFF050505)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
          builder: (context, state) {
            final currentSong = state.currentSong ?? song;
            final total = Duration(
              seconds: (state.currentSong?.duration ?? song.duration).toInt(),
            );
            final position =
                state.position > total && total != Duration.zero
                    ? total
                    : state.position;
            final maxSeconds =
                total.inSeconds <= 0 ? 1.0 : total.inSeconds.toDouble();
            final sliderValue =
                position.inSeconds.clamp(0, maxSeconds.toInt()).toDouble();

            return SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(
                    title: currentSong.title,
                    showQueue: state.queue.isNotEmpty,
                    onClose: () => context.pop(),
                    onQueue: () => _showQueue(context),
                  ),
                  const SizedBox(height: 24),
                  _Artwork(imageUrl: currentSong.coverImageUrl),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currentSong.artist.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.66),
                              ),
                            ),
                          ],
                        ),
                      ),
                      BlocSelector<LikesBloc, LikeSongState, bool>(
                        selector:
                            (state) => state.likedSongs.any(
                              (s) => s.id == currentSong.id,
                            ),
                        builder: (context, isLiked) {
                          return IconButton.filledTonal(
                            tooltip: isLiked ? 'Unlike' : 'Like',
                            icon: Icon(
                              Icons.favorite,
                              color: isLiked ? Colors.red : Colors.white70,
                            ),
                            onPressed: () {
                              if (isLiked) {
                                context.read<LikesBloc>().add(
                                  UnlikeSong(currentSong.id),
                                );
                              } else {
                                context.read<LikesBloc>().add(
                                  LikeSong(currentSong.id),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SongInfoPanel(song: currentSong, duration: total),
                  const SizedBox(height: 28),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
                      thumbColor: Colors.green,
                      overlayColor: Colors.green.withValues(alpha: 0.14),
                    ),
                    child: Slider(
                      min: 0,
                      max: maxSeconds,
                      value: sliderValue,
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
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatTime(position),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          formatTime(total),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundControl(
                        tooltip: 'Shuffle',
                        icon: Icons.shuffle,
                        isActive: state.shuffle,
                        onPressed:
                            () => context.read<MusicPlayerBloc>().add(
                              ToggleShuffle(),
                            ),
                      ),
                      _RoundControl(
                        tooltip: 'Previous',
                        icon: Icons.skip_previous,
                        onPressed:
                            () => context.read<MusicPlayerBloc>().add(
                              PreviousSong(),
                            ),
                      ),
                      _PlayButton(
                        isPlaying: state.status == PlayBackStatus.playing,
                        onPressed: () {
                          if (state.status == PlayBackStatus.playing) {
                            context.read<MusicPlayerBloc>().add(PauseSong());
                          } else {
                            context.read<MusicPlayerBloc>().add(ResumeSong());
                          }
                        },
                      ),
                      _RoundControl(
                        tooltip: 'Next',
                        icon: Icons.skip_next,
                        onPressed:
                            () =>
                                context.read<MusicPlayerBloc>().add(NextSong()),
                      ),
                      _RepeatControl(
                        repeatModeName: state.repeatMode.name,
                        onPressed:
                            () => context.read<MusicPlayerBloc>().add(
                              ToggleRepeat(),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.showQueue,
    required this.onClose,
    required this.onQueue,
  });

  final String title;
  final bool showQueue;
  final VoidCallback onClose;
  final VoidCallback onQueue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Close',
          onPressed: onClose,
          icon: const Icon(FontAwesomeIcons.angleDown, color: Colors.white),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Queue',
          onPressed: showQueue ? onQueue : null,
          icon: Icon(
            FontAwesomeIcons.bars,
            color: showQueue ? Colors.white : Colors.white24,
          ),
        ),
      ],
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                errorWidget:
                    (context, url, error) => const Icon(
                      Icons.music_note,
                      size: 56,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SongInfoPanel extends StatelessWidget {
  const _SongInfoPanel({required this.song, required this.duration});

  final Song song;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _InfoPill(
              icon: Icons.person_outline,
              label: 'Artist',
              value: song.artist.name,
            ),
            const SizedBox(width: 10),
            _InfoPill(
              icon: Icons.schedule,
              label: 'Length',
              value: _formatDuration(duration),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inMinutes}:$seconds';
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.52),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      color: isActive ? Colors.green : Colors.white,
      iconSize: 28,
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.isPlaying, required this.onPressed});

  final bool isPlaying;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 68,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 36),
      ),
    );
  }
}

class _RepeatControl extends StatelessWidget {
  const _RepeatControl({required this.repeatModeName, required this.onPressed});

  final String repeatModeName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = switch (repeatModeName) {
      'one' => Icons.repeat_one,
      _ => Icons.repeat,
    };
    final isActive = repeatModeName == 'all' || repeatModeName == 'one';

    return IconButton(
      tooltip: 'Repeat',
      onPressed: onPressed,
      icon: Icon(icon),
      color: isActive ? Colors.green : Colors.white,
      iconSize: 28,
    );
  }
}

void _showQueue(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Queue',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: QueuePage(),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
