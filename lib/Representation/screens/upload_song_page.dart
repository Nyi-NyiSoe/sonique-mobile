import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  const UploadSongPage({super.key});

  @override
  State<UploadSongPage> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends State<UploadSongPage> {
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  GenreModel? _genre;
  XFile? _coverImage;
  XFile? _audioFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<SongDataBloc, SongDataState>(
          builder: (context, state) {
            if (state.fetchStatus == SongDataStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.fetchStatus == SongDataStatus.failure) {
              return _StateMessage(
                icon: Icons.error_outline,
                message: 'Error loading genres: ${state.error}',
              );
            } else if (state.fetchStatus == SongDataStatus.success) {
              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    _UploadHeader(
                      title: 'Upload Track',
                      subtitle: 'Add a finished MP3 with artwork and genre',
                      icon: Icons.music_note,
                      onBack: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 22),
                    const _SectionTitle(title: 'Track Details'),
                    CustomTextFormField(
                      label: 'Track title',
                      controller: _titleController,
                      prefixIcon: const Icon(Icons.title),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a track title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _GenrePicker(
                      genres: state.genres,
                      selectedGenre: _genre,
                      onSelected: (genre) => setState(() => _genre = genre),
                      onAddGenre: () => _showAddGenreDialog(context, state),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'Files'),
                    _PickPanel(
                      title: 'Audio file',
                      subtitle:
                          _audioFile == null
                              ? 'Choose an MP3 file'
                              : _audioFile!.name,
                      icon: Icons.audio_file_outlined,
                      isSelected: _audioFile != null,
                      onTap: _pickAudio,
                    ),
                    const SizedBox(height: 12),
                    _PickPanel(
                      title: 'Cover image',
                      subtitle:
                          _coverImage == null
                              ? 'Choose square artwork'
                              : _coverImage!.name,
                      icon: Icons.image_outlined,
                      isSelected: _coverImage != null,
                      imagePath: _coverImage?.path,
                      onTap: _pickCoverImage,
                    ),
                    const SizedBox(height: 26),
                    CustomElevatedButton(
                      onPressed: _uploadTrack,
                      backgroundColor: Colors.green,
                      child: const Text('Upload Track'),
                    ),
                  ],
                ),
              );
            }

            log(state.toString());
            return const _StateMessage(
              icon: Icons.cloud_upload_outlined,
              message: 'Upload form is not ready yet',
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickAudio() async {
    final hasPermission = await requestGalleryPermission();
    if (!hasPermission) return;

    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path == null) return;
      setState(() => _audioFile = XFile(path));
      log(_audioFile!.name);
    }
  }

  Future<void> _pickCoverImage() async {
    final hasPermission = await requestGalleryPermission();
    if (!hasPermission) return;

    final imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) return;
    setState(() => _coverImage = imageFile);
    log(_coverImage!.name);
  }

  void _uploadTrack() {
    if (!_formKey.currentState!.validate()) return;

    if (_genre == null) {
      _showSnackBar('Please choose a genre');
      return;
    }

    if (_audioFile == null) {
      _showSnackBar('Please select an MP3 audio file');
      return;
    }

    if (_coverImage == null) {
      _showSnackBar('Please select cover artwork');
      return;
    }

    final name = _audioFile!.name.toLowerCase();
    if (!name.endsWith('.mp3') && _audioFile!.mimeType != 'audio/mpeg') {
      _showSnackBar('Please select an MP3 audio file');
      return;
    }

    try {
      context.read<SongDataBloc>().add(
        UploadSongEvent(
          audioFile: _audioFile!,
          coverImage: _coverImage!,
          genreId: _genre!.id.toString(),
          title: _titleController.text.trim(),
        ),
      );

      _showSnackBar('Uploaded song successfully!');
      context.pop();
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  void _showAddGenreDialog(BuildContext context, SongDataState state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Genre'),
          content: CustomTextFormField(
            controller: _genreController,
            label: 'Genre name',
            prefixIcon: const Icon(Icons.category_outlined),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final genreName = _genreController.text.trim();
                if (genreName.isEmpty) return;

                try {
                  context.read<SongDataBloc>().add(
                    UploadSongGenreEvent(genreName: genreName),
                  );
                  _genreController.clear();
                  context.pop();
                } catch (e) {
                  _showSnackBar(state.error.toString());
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _genreController.dispose();
    _titleController.dispose();
    super.dispose();
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

class _GenrePicker extends StatelessWidget {
  const _GenrePicker({
    required this.genres,
    required this.selectedGenre,
    required this.onSelected,
    required this.onAddGenre,
  });

  final List<GenreModel> genres;
  final GenreModel? selectedGenre;
  final ValueChanged<GenreModel> onSelected;
  final VoidCallback onAddGenre;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: selectedGenre?.id,
            decoration: const InputDecoration(
              labelText: 'Genre',
              prefixIcon: Icon(Icons.category_outlined),
              border: UnderlineInputBorder(),
            ),
            items:
                genres
                    .map(
                      (genre) => DropdownMenuItem<int>(
                        value: genre.id,
                        child: Text(genre.name),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value == null) return;
              onSelected(genres.firstWhere((genre) => genre.id == value));
            },
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filled(
          tooltip: 'Add genre',
          onPressed: onAddGenre,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _PickPanel extends StatelessWidget {
  const _PickPanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.imagePath,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? imagePath;

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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    imagePath == null
                        ? Icon(icon, color: Colors.green)
                        : Image.file(File(imagePath!), fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                isSelected ? Icons.check_circle : Icons.upload_file_outlined,
                color: isSelected ? Colors.green : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
          ],
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
