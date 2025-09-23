import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_state.dart';
import 'package:sonique/Representation/widgets/CustomAlbumCard.dart';

class AlbumByArtistPage extends StatelessWidget {
  const AlbumByArtistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(),
      body: BlocBuilder<AlbumByArtistBloc, AlbumByArtistState>(
        builder: (context, state) {
          if (state is AlbumByArtistLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AlbumByArtistLoaded) {
            final albums = state.albums;
            if (albums.isEmpty) {
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
                  Center(child: Text("No albums yet.")),
                  SizedBox.shrink(),
                ],
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              padding: const EdgeInsets.fromLTRB(
                12,
                0,
                12,
                12,
              ), // 👈 no top padding
              itemCount: albums.length,
              itemBuilder: (context, index) {
                return CustomAlbumCard(
                  imageUrl: albums[index].coverImageUrl!,
                  albumId: albums[index].id!,
                );
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
