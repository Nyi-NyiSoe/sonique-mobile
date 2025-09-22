import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_state.dart';
import 'package:sonique/Representation/widgets/CustomPlayList.dart';

class AlbumDetailPage extends StatelessWidget {
  const AlbumDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
