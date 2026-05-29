import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_event.dart';
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
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  XFile? _coverImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<AlbumOperationsBloc, AlbumOperationsState>(
          listener: (context, state) {
            if (state is AlbumOperationSuccess) {
              context.read<AlbumListBloc>().add(FetchAlbumsEvent());
              context.read<AlbumByArtistBloc>().add(
                FetchAlbumByArtistIdEvent(null, forceRefresh: true),
              );
              _showSnackBar('Uploaded album successfully!');
              context.pop();
            }
          },
          builder: (context, state) {
            if (state is AlbumOperationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AlbumOperationError) {
              return _AlbumForm(
                formKey: _formKey,
                titleController: _titleController,
                descriptionController: _desController,
                coverImagePath: _coverImage?.path,
                errorMessage: state.error,
                onBack: () => Navigator.of(context).pop(),
                onPickCoverImage: _pickCoverImage,
                onUploadAlbum: _uploadAlbum,
              );
            } else {
              return _AlbumForm(
                formKey: _formKey,
                titleController: _titleController,
                descriptionController: _desController,
                coverImagePath: _coverImage?.path,
                onBack: () => Navigator.of(context).pop(),
                onPickCoverImage: _pickCoverImage,
                onUploadAlbum: _uploadAlbum,
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _pickCoverImage() async {
    final hasPermission = await requestGalleryPermission();
    if (!hasPermission) return;

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      _showSnackBar('Failed to read selected image');
      return;
    }

    final jpgBytes = img.encodeJpg(decodedImage, quality: 90);
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempPath = '${tempDir.path}/cover_$timestamp.jpg';
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(jpgBytes);

    setState(() => _coverImage = XFile(tempFile.path));
  }

  void _uploadAlbum() {
    if (!_formKey.currentState!.validate()) return;

    if (_coverImage == null) {
      _showSnackBar('Please select a cover photo');
      return;
    }

    try {
      context.read<AlbumOperationsBloc>().add(
        CreateAlbumEvent(
          _titleController.text.trim(),
          _coverImage!,
          _desController.text.trim(),
        ),
      );
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _desController.dispose();
    super.dispose();
  }
}

class _AlbumForm extends StatelessWidget {
  const _AlbumForm({
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.coverImagePath,
    required this.onBack,
    required this.onPickCoverImage,
    required this.onUploadAlbum,
    this.errorMessage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? coverImagePath;
  final VoidCallback onBack;
  final VoidCallback onPickCoverImage;
  final VoidCallback onUploadAlbum;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          _UploadHeader(
            title: 'Upload Album',
            subtitle: 'Create a release with cover artwork',
            icon: Icons.album_outlined,
            onBack: onBack,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            _InlineError(message: errorMessage!),
          ],
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Album Details'),
          CustomTextFormField(
            label: 'Album title',
            controller: titleController,
            prefixIcon: const Icon(Icons.title),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an album title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            label: 'Description',
            controller: descriptionController,
            prefixIcon: const Icon(Icons.notes_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Artwork'),
          _CoverPicker(imagePath: coverImagePath, onTap: onPickCoverImage),
          const SizedBox(height: 26),
          CustomElevatedButton(
            onPressed: onUploadAlbum,
            backgroundColor: Colors.green,
            child: const Text('Upload Album'),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadHeader extends StatelessWidget {
  const _UploadHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 4),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.68,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CoverPicker extends StatelessWidget {
  const _CoverPicker({required this.imagePath, required this.onTap});

  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    imagePath == null
                        ? const Icon(
                          Icons.image_outlined,
                          color: Colors.green,
                          size: 34,
                        )
                        : Image.file(File(imagePath!), fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cover artwork',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      imagePath == null
                          ? 'Choose an image from your gallery'
                          : 'Artwork ready for upload',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.66,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                imagePath == null
                    ? Icons.upload_file_outlined
                    : Icons.check_circle,
                color: imagePath == null ? null : Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> requestGalleryPermission() async {
  var status = await Permission.photos.request();
  if (status.isGranted) return true;

  status = await Permission.storage.request();
  return status.isGranted;
}
