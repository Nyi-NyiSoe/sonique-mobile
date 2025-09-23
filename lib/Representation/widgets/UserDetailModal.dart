import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_event.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';
import 'package:sonique/Representation/widgets/CustomTextFormField.dart';

class UserDetailsModal extends StatefulWidget {
  final UserModel user;

  const UserDetailsModal({super.key, required this.user});

  @override
  State<UserDetailsModal> createState() => _UserDetailsModalState();
}

class _UserDetailsModalState extends State<UserDetailsModal> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController bioController;
  late final TextEditingController usernameController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    bioController = TextEditingController(text: widget.user.bio);
    usernameController = TextEditingController(text: widget.user.username);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    bioController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 0.5,
      maxChildSize: 1,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text("Edit profile"),
              const SizedBox(height: 20),

              // First + Last name row
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      label: "First Name",
                      hintText: "First Name",
                      controller: firstNameController,
                      validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter your first name'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextFormField(
                      label: "Last Name",
                      hintText: "Last Name",
                      controller: lastNameController,
                      validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter your last name'
                              : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              CustomTextFormField(
                label: "Username",
                controller: usernameController,
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Please enter your username'
                        : null,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                label: "Bio",
                controller: bioController,
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                width: 200,
                child: const Text('Save'),
                onPressed: () {
                  try {
                    context.read<UserDataBloc>().add(
                      UpdateUserDetailEvent(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        username: usernameController.text,
                        bio: bioController.text,
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
  }
}
