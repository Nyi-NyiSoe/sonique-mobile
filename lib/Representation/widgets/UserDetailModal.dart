import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/user_model.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_event.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';
import 'package:sonique/Representation/widgets/CustomTextFormField.dart';

class UserDetailsModal extends StatefulWidget {
  const UserDetailsModal({super.key, required this.user});

  final UserModel user;

  @override
  State<UserDetailsModal> createState() => _UserDetailsModalState();
}

class _UserDetailsModalState extends State<UserDetailsModal> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController bioController;
  late final TextEditingController usernameController;
  final _formKey = GlobalKey<FormState>();

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
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.62,
      maxChildSize: 0.98,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          clipBehavior: Clip.antiAlias,
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Profile',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Update your public profile details',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.68),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        label: 'First name',
                        hintText: 'First name',
                        controller: firstNameController,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextFormField(
                        label: 'Last name',
                        hintText: 'Last name',
                        controller: lastNameController,
                        prefixIcon: const Icon(Icons.badge_outlined),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                CustomTextFormField(
                  label: 'Username',
                  controller: usernameController,
                  prefixIcon: const Icon(Icons.alternate_email),
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please enter your username'
                              : null,
                ),
                const SizedBox(height: 18),
                CustomTextFormField(
                  label: 'Bio',
                  controller: bioController,
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.55,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomElevatedButton(
                        height: 48,
                        borderRadius: 8,
                        backgroundColor: theme.colorScheme.primary,
                        textColor: theme.colorScheme.onPrimary,
                        onPressed: _saveProfile,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    try {
      context.read<UserDataBloc>().add(
        UpdateUserDetailEvent(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          username: usernameController.text.trim(),
          bio: bioController.text.trim(),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}
