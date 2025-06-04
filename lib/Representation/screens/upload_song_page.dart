import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_state.dart';

class UploadSongPage extends StatelessWidget {
  const UploadSongPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload your track'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocBuilder<SongDataBloc, SongDataState>(
        builder: (context, state) {
          if (state is SongDataLoadingState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is GenreFetchingErrorState) {
            return Center(child: Text('Error loading genre: ${state.error}'));
          } else if (state is GenreFetchedState) {
            final genres = state.genres;
            return ListView.builder(
              itemCount: genres.length,
              itemBuilder: (context, index) {
                return Text(genres[index].name);
              },
            );
          } else {
            return Text('upload page');
          }
        },
      ),
    );
  }
}

Future<bool> requestGalleryPermission() async {
  var status = await Permission.photos.request(); // iOS
  if (status.isGranted) return true;

  status = await Permission.storage.request(); // Android
  return status.isGranted;
}
