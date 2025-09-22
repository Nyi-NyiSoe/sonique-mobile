import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_state.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_event.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';
import 'package:sonique/Representation/widgets/CustomTextFormField.dart';

class UploadAlbumPage extends StatefulWidget {
  const UploadAlbumPage({super.key});

  @override
  State<UploadAlbumPage> createState() => _UploadAlbumPageState();
}

class _UploadAlbumPageState extends State<UploadAlbumPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _desController = TextEditingController();

  XFile? _coverImage;

  final ImagePicker picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload your album'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocBuilder<AlbumOperationsBloc, AlbumOperationsState>(
        builder: (context, state) {
          if (state is AlbumOperationLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AlbumOperationError) {
            return Center(child: Text('Error loading genre: ${state.error}'));
          } else if (state is AlbumOperationInitial) {
            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  CustomTextFormField(
                    label: 'Album title',
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a album title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    label: 'Description',
                    controller: _desController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () async {
                      // 1️⃣ Request gallery permission
                      final hasPermission = await requestGalleryPermission();
                      if (!hasPermission) return;

                      // 2️⃣ Pick an image
                      final XFile? pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile == null) return;

                      // 3️⃣ Read bytes and decode
                      final bytes = await pickedFile.readAsBytes();
                      final decodedImage = img.decodeImage(bytes);
                      if (decodedImage == null) {
                        print('Failed to decode image');
                        return;
                      }

                      // 4️⃣ Encode as JPEG to ensure backend compatibility
                      final jpgBytes = img.encodeJpg(decodedImage, quality: 90);

                      // 5️⃣ Save to temporary file with timestamp for uniqueness
                      final tempDir = await getTemporaryDirectory();
                      final timestamp = DateTime.now().millisecondsSinceEpoch;
                      final tempPath =
                          '${tempDir.path}/cover_$timestamp.jpg'; // 🔥 Better naming
                      final tempFile = File(tempPath);
                      await tempFile.writeAsBytes(jpgBytes);

                      // 6️⃣ Verify the file was written correctly
                      final fileExists = await tempFile.exists();
                      final fileSize = await tempFile.length();
                      print('File exists: $fileExists, Size: $fileSize bytes');

                      // 7️⃣ Update state with valid XFile for upload
                      setState(() {
                        _coverImage = XFile(tempFile.path);
                      });

                      print(
                        '✅ Cover image ready for upload: ${_coverImage!.path}',
                      );
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
                              _coverImage != null) {
                            try {
                              print(
                                'Selected cover image path: ${_coverImage?.path}',
                              );
                              context.read<AlbumOperationsBloc>().add(
                                CreateAlbumEvent(
                                  _titleController.text,
                                  _coverImage!,
                                  _desController.text,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Uploaded song successfully!'),
                                ),
                              );
                              context.read<AlbumListBloc>().add(FetchAlbumsEvent());

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
                                content: Text('Please select a cover photo'),
                              ),
                            );
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
