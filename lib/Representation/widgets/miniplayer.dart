import 'package:flutter/material.dart';
import 'package:sonique/Domain/entities/song.dart';
import 'package:sonique/Representation/widgets/SongDetailCard.dart';

class MiniPlayer extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  const MiniPlayer({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent, // no black background
          context: context,
          builder: (context) {
            return DraggableScrollableSheet(
              expand: true,
              initialChildSize: 1.0, // full height when opened
              maxChildSize: 1.0, // prevent leaving gap
              minChildSize: 0.3, // you can allow small drag state if you like
              builder: (context, controller) {
                return SafeArea(
                  top: false,
                  bottom: false, // 🔑 remove bottom SafeArea gap
                  child: Songdetailcard(
                    song: song,
                    controller: controller, // make it scrollable
                  ),
                );
              },
            );
          },
        );
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.music_note, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${song.title} - ${song.artist.name}',
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: onPlayPause,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
