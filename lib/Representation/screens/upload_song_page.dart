import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonique/Data/models/genre_model.dart';
import 'package:sonique/Data/models/song_data_status.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_event.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_state.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';
import 'package:sonique/Representation/widgets/CustomTextFormField.dart';

class UploadSongPage extends StatefulWidget {
  UploadSongPage({super.key});

  @override
  State<UploadSongPage> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends State<UploadSongPage> {
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  GenreModel? _genre;
  XFile? _coverImage;
  XFile? _audioFile;
  final ImagePicker picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

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
          if (state.fetchStatus == SongDataStatus.loading) {
            return Center(child: CircularProgressIndicator());
          } else if (state.fetchStatus == SongDataStatus.failure) {
            return Center(child: Text('Error loading genre: ${state.error}'));
          } else if (state.fetchStatus == SongDataStatus.success) {
            final genres = state.genres;
            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  CustomTextFormField(
                    label: 'Track title',
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a track title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownMenu(
                          initialSelection: null,
                          onSelected: (value) {
                            if (value != null) {
                              _genre = genres.elementAt(value - 1);
                            }
                          },
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
                                            controller: _genreController,
                                            label: 'Genre',
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'Please enter a genre';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        CustomElevatedButton(
                                          width: 100,
                                          child: BlocBuilder<
                                            SongDataBloc,
                                            SongDataState
                                          >(
                                            builder: (context, state) {
                                              if (state.fetchStatus ==
                                                  SongDataStatus.loading) {
                                                return CircularProgressIndicator();
                                              }
                                              if (state.fetchStatus ==
                                                  SongDataStatus.success) {
                                                return Text('Add');
                                              } else {
                                                return Text('Error');
                                              }
                                            },
                                          ),
                                          onPressed: () {
                                            try {
                                              context.read<SongDataBloc>().add(
                                                UploadSongGenreEvent(
                                                  genreName:
                                                      _genreController.text,
                                                ),
                                              );
                                              context.pop();
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    state.error.toString(),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
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
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.audio,
                      );
                      final hasPermission = await requestGalleryPermission();
                      if (!hasPermission) return;
                      if (result != null && result.files.isNotEmpty) {
                        final XFile? audioFile = XFile(
                          result.files.first.path!,
                        );
                        if (audioFile != null) {
                          setState(() {
                            _audioFile = audioFile;
                          });

                          log(_audioFile!.name.toString());
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            style:
                                BorderStyle
                                    .solid, // Dotted not directly supported
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child:
                              _audioFile != null
                                  ? Text(_audioFile!.name.toString())
                                  : Icon(FontAwesomeIcons.music),
                        ),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () async {
                      final hasPermission = await requestGalleryPermission();
                      if (!hasPermission) return;
                      final XFile? imageFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );

                      if (imageFile != null) {
                        setState(() {
                          _coverImage = imageFile;
                        });

                        log(_coverImage!.name.toString());
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            style:
                                BorderStyle
                                    .solid, // Dotted not directly supported
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child:
                              _coverImage != null
                                  ? Image.file(File(_coverImage!.path))
                                  : Icon(FontAwesomeIcons.photoFilm),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: CustomElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              _audioFile != null &&
                              _coverImage != null) {
                            // Check if audio file is mp3
                            if (_audioFile!.name.toLowerCase().endsWith(
                              '.mp3',
                            )) {
                              try {
                                context.read<SongDataBloc>().add(
                                  UploadSongEvent(
                                    audioFile: _audioFile!,
                                    coverImage: _coverImage!,
                                    genreId: _genre!.id.toString(),
                                    title: _titleController.text,
                                  ),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Uploaded song successfully!',
                                    ),
                                  ),
                                );

                                context.pop();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                              // Proceed with upload logic here
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please select an MP3 audio file',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Upload'),
                      ),
                    ),
                  ),
                ],
              ),
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
