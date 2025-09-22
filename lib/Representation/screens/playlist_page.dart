import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_state.dart';
import 'package:sonique/Representation/widgets/CustomPlayList.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state.status == PlaylistStatus.loading) {
            return Center(child: CircularProgressIndicator());
          } else if (state.status == PlaylistStatus.success) {
            final songs = state.selectedPlaylist?.songs ?? [];


            if (songs!.isEmpty) {
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
                  Center(child: Text("No songs added yet.")),
                  SizedBox.shrink(),
                ],
              );
            }

            return CustomPlayList(songs: songs,playlistId: state.selectedPlaylist!.id,);
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
