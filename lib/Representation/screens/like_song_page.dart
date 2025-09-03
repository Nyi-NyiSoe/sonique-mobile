import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/song_data_status.dart';
import 'package:sonique/Domain/entities/song.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_bloc.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_event.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_state.dart';
import 'package:sonique/Representation/widgets/CustomSongCard.dart';

class LikeSongPage extends StatefulWidget {
  const LikeSongPage({super.key});

  @override
  State<LikeSongPage> createState() => _LikeSongPageState();
}

class _LikeSongPageState extends State<LikeSongPage> {

  @override
  void initState() {
    super.initState();
    context.read<LikesBloc>().add(LoadLikedSongs());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<LikesBloc, LikeSongState>(
        builder: (context, state) {
          if (state.status == SongDataStatus.loading) {
            return Center(child: CircularProgressIndicator());
          } else if (state.status == SongDataStatus.success) {
            final songList = state.likedSongs;
            log(songList.toString());
            final List<Song> songs =
                songList
                    .map(
                      (songModel) => Song(
                        artist: songModel.artist,
                        audioUrl: songModel.fileUrl,
                        coverImageUrl: songModel.coverImageUrl,
                        created_at: "null",
                        duration: songModel.duration,
                        genre: songModel.genre.id,
                        id: songModel.id,
                        title: songModel.title,
                      ),
                    )
                    .toList();
            return ListView.builder(
              itemCount: songList.length,
              itemBuilder: (context, index) {
                return Customsongcard(song: songs[index], queue: false);
              },
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
