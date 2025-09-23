import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_event.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';

class ImageUpdateModal extends StatefulWidget {
  final UserModel user;

  const ImageUpdateModal({super.key, required this.user});

  @override
  State<ImageUpdateModal> createState() => _ImageUpdateModalState();
}

class _ImageUpdateModalState extends State<ImageUpdateModal> {
  XFile? tempImage;

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();

    return Container(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text("Edit profile"),
          const SizedBox(height: 20),
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: tempImage == null
                    ? NetworkImage(widget.user.profile_image!)
                        as ImageProvider
                    : FileImage(File(tempImage!.path)) as ImageProvider,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () async {
                    final hasPermission = await requestGalleryPermission();
                    if (!hasPermission) return;
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() {
                        tempImage = image;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomElevatedButton(
            width: 200,
            child: Text('Save'),
            onPressed: () async {
              if (tempImage != null) {
                context.read<UserDataBloc>().add(
                  UserImageUpdateEvent(profile_image: tempImage),
                );
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<bool> requestGalleryPermission() async {
    var status = await Permission.photos.request(); // iOS
    if (status.isGranted) return true;

    status = await Permission.storage.request(); // Android
    return status.isGranted;
  }
}