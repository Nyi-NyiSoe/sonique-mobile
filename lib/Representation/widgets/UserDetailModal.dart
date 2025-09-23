import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_event.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';
import 'package:sonique/Representation/widgets/CustomTextFormField.dart';

class UserDetailsModal extends StatelessWidget {
  final UserModel user;

  const UserDetailsModal({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController(
      text: user.firstName,
    );
    final TextEditingController lastNameController = TextEditingController(
      text: user.lastName,
    );
    final TextEditingController bioController = TextEditingController(
      text: user.bio,
    );
    final TextEditingController usernameController = TextEditingController(
      text: user.username,
    );

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
                      controller: firstNameController,
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
                      controller: lastNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
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
                controller: usernameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                label: "Bio", 
                controller: bioController
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                width: 200,
                child: Text('Save'),
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