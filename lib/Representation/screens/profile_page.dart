import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_event.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_state.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_event.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_state.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';
import 'package:sonique/Representation/widgets/CustomTextFormField.dart';
import 'package:sonique/core/services/routes/routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? user;
  XFile? temp_image; // Declare temp_image as a state variable

  @override
  void initState() {
    super.initState();
    // Fetch user data when the widget is initialized
    context.read<UserDataBloc>().add(FetchUserDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle settings action

              context.read<AuthBloc>().add(LogoutEvent());
            },
          ),
        ],
      ),

      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoadingState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Logged out')));
            context.go(Routes.login);
          }
        },
        child: BlocBuilder<UserDataBloc, UserDataState>(
          builder: (context, state) {
            if (state is UserDataLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserDataFetchedState) {
              user = state.user;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              GestureDetector(
                                onTap: () => updateImageModal(context),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(
                                    user!.profile_image == ""
                                        ? 'https://i.imgur.com/BoN9kdC.png'
                                        : user!.profile_image!,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () => updateUserDetailsModal(context),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${user!.firstName} ${user!.lastName}",
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.displayMedium!,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "@${user!.username}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => updateUserDetailsModal(context),
                            child: Text(
                              user!.bio == ""
                                  ? "'Add a bio'"
                                  : "'${user!.bio}'",
                              style: Theme.of(context).textTheme.labelLarge!
                                  .copyWith(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is UserDataErrorState) {
              return Center(child: Text(state.error));
            } else {
              return const Center(child: Text('Something went wrong!'));
            }
          },
        ),
      ),
    );
  }

  Future<dynamic> updateUserDetailsModal(BuildContext context) {
    final TextEditingController _firstNameController = TextEditingController(
      text: user!.firstName,
    );
    final TextEditingController _lastNameController = TextEditingController(
      text: user!.lastName,
    );

    final TextEditingController _bioController = TextEditingController(
      text: user!.bio,
    );
    final TextEditingController _usernameController = TextEditingController(
      text: user!.username,
    );

    return showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text("Edit profile"),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          label: "First Name",
                          hintText: "First Name",
                          controller: _firstNameController,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: CustomTextFormField(
                          label: "Last Name",
                          hintText: "Last Name",
                          controller: _lastNameController,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    label: "Username",

                    controller: _usernameController,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(label: "Bio", controller: _bioController),
                  const SizedBox(height: 20),
                  CustomElevatedButton(
                    width: 200,
                    child: Text('Save'),
                    onPressed: () {
                      // Handle save action
                      try {
                        context.read<UserDataBloc>().add(
                          UpdateUserDetailEvent(
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            username: _usernameController.text,
                            bio: _bioController.text,
                          ),
                        );

                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<dynamic> updateImageModal(BuildContext context) {
    final ImagePicker picker = ImagePicker();

    return showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        backgroundImage:
                            temp_image == null
                                ? NetworkImage(user!.profile_image!)
                                    as ImageProvider
                                : FileImage(File(temp_image!.path))
                                    as ImageProvider,
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () async {
                            final hasPermission =
                                await requestGalleryPermission();
                            if (!hasPermission) return;
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              // Update both parent state and modal state
                              setState(() {
                                temp_image = image;
                              });
                              setModalState(() {
                                // This forces the modal to rebuild
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
                      if (temp_image != null) {
                        context.read<UserDataBloc>().add(
                          UserImageUpdateEvent(profile_image: temp_image),
                        );
                      }

                      setState(() {
                        temp_image = null;
                      });

                      setModalState(() {
                        // This forces the modal to rebuild
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Future<bool> requestGalleryPermission() async {
  var status = await Permission.photos.request(); // iOS
  if (status.isGranted) return true;

  status = await Permission.storage.request(); // Android
  return status.isGranted;
}
