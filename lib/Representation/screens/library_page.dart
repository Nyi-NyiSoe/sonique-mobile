import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_state.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';
import 'package:sonique/Representation/widgets/CustomTextFormField.dart';
import 'package:sonique/core/services/routes/routes.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    final userDataState = context.watch<UserDataBloc>().state;
    if (userDataState is UserDataLoadingState) {
      return const Center(child: CircularProgressIndicator());
    } else if (userDataState is UserDataErrorState) {
      return Center(child: Text(userDataState.error));
    } else if (userDataState is UserDataFetchedState) {
      final isArtist = userDataState.user.isArtist;
      // Display user data
      return Scaffold(
        appBar: AppBar(title: const Text('Library Page')),
        floatingActionButton:
            isArtist
                ? FloatingActionButton(
                  onPressed: () {
                    // Add your action for artists here
                    context.push(Routes.upload);
                  },
                  child: const Icon(Icons.add),
                )
                : null,
        body: Center(child: Text('Welcome to the Library Page!')),
      );
    }
    return const Center(child: Text('No user data available.'));
  }
}

void showBottomSheet(BuildContext context) {
  final ImagePicker picker = ImagePicker();
  String selectedTrack = '';
  XFile? selectedCover;

  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,

        expand: false,
        builder: (context, controller) {
          return SizedBox(
            height: 300,

            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add New Track'),
                  const SizedBox(height: 20),
                  CustomTextFormField(label: 'Track Title'),
                  const SizedBox(height: 20),
                  ListTile(
                    title:
                        selectedTrack == ''
                            ? const Text('Select Track')
                            : Text(selectedTrack),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () async {
                      final permissionGranted =
                          await requestGalleryPermission();
                      if (!permissionGranted) {
                        return;
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text('Select Cover'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () async {
                      final permissionGranted =
                          await requestGalleryPermission();
                      if (!permissionGranted) {
                        return;
                      }
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomElevatedButton(child: Text('Upload'), onPressed: () {}),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<bool> requestGalleryPermission() async {
  var status = await Permission.photos.request(); // iOS
  if (status.isGranted) return true;

  status = await Permission.storage.request(); // Android
  return status.isGranted;
}
