import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_state.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_state.dart';
import 'package:sonique/Representation/screens/upload_songs_album_page.dart';
import 'package:sonique/Representation/widgets/CustomPlayList.dart';

class AlbumDetailPage extends StatelessWidget {
  const AlbumDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BlocBuilder<UserDataBloc, UserDataState>(
        builder: (context, state) {
          if (state is UserDataFetchedState) {
            final isArtist = state.user.isArtist;
            if (isArtist) {
              return FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    //backgroundColor: Colors.transparent, // no black background
                    context: context,
                    builder: (context) {
                      final albumDetailState = context.read<AlbumDetailBloc>().state;
                      int? albumId = null;
                      if (albumDetailState is AlbumDetailLoaded) {
                      albumId = albumDetailState.album.id;
                      }
                      return UploadSongsAlbumPage(
                      userId: state.user.userId,
                      albumId: albumId!,
                      );
                    },
                  );
                },
                child: Icon(Icons.upload),
              );
            } else {
              return SizedBox.shrink();
            }
          } else {
            return SizedBox.shrink();
          }
        },
      ),
      body: BlocBuilder<AlbumDetailBloc, AlbumDetailState>(
        builder: (context, state) {
          if (state is AlbumDetailLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AlbumDetailLoaded) {
            final songs = state.album.songs;
            log(state.album.toString());
            if (songs.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(FontAwesomeIcons.angleLeft),
                  ),
                  Center(child: Text("No songs in album yet.")),
                  SizedBox.shrink(),
                ],
              );
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
