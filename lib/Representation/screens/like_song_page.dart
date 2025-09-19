import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/liked_song_model.dart';
import 'package:sonique/Data/models/song_data_status.dart';
import 'package:sonique/Domain/entities/song.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_bloc.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_event.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_state.dart';
import 'package:sonique/Representation/widgets/CustomPlayList.dart';

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
      body: BlocBuilder<LikesBloc, LikeSongState>(
        builder: (context, state) {
          if (state.status == SongDataStatus.loading) {
            return Center(child: CircularProgressIndicator());
          } else if (state.status == SongDataStatus.success) {
            final uniqueSongs = <LikedSongModel>[];
            final seenIds = <String>{};

            for (var song in state.likedSongs) {
              if (seenIds.add(song.id)) {
                uniqueSongs.add(song);
              }
            }

            final List<Song> songs =
                uniqueSongs
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

            if (songs.isEmpty) {
              return Center(child: Text("No liked songs yet."));
            }

            return CustomPlayList(songs: songs);
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}

