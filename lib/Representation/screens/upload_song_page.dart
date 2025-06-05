import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_state.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';
import 'package:sonique/Representation/widgets/CustomTextFormField.dart';

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
          } else if (state is SongDataErrorState) {
            return Center(child: Text('Error loading genre: ${state.error}'));
          } else if (state is SongDataFetchedState) {
            final genres = state.genres;
            return Column(
              children: [
                CustomTextFormField(label: 'Track title'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownMenu(
                        inputDecorationTheme: InputDecorationTheme(
                          border: null,
                          contentPadding: EdgeInsets.all(15),
                        ),
                        hintText: 'Choose your genre',
                        width: double.infinity,
                        dropdownMenuEntries: [
                          ...genres.map(
                            (genre) => DropdownMenuEntry(
                              value: genre.id,
                              label: genre.name,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      child: CustomElevatedButton(
                        width: 50,

                        child: Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: Container(
                                  height: 200,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text('Genre'),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CustomTextFormField(
                                          label: 'Genre',
                                        ),
                                      ),
                                      CustomElevatedButton(
                                        width: 100,
                                        child: Text('Add'),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            log(state.toString());
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
