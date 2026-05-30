import 'package:flutter/material.dart';

class CreatePlaylistDialog extends StatefulWidget {
  const CreatePlaylistDialog({super.key, required this.onCreate});

  final ValueChanged<String> onCreate;

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _canCreate = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTitleChanged);
  }

  void _handleTitleChanged() {
    final canCreate = _controller.text.trim().isNotEmpty;
    if (canCreate == _canCreate) return;

    setState(() {
      _canCreate = canCreate;
    });
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    widget.onCreate(title);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Playlist'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(labelText: 'Playlist title'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canCreate ? _submit : null,
          child: const Text('Create'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTitleChanged);
    _controller.dispose();
    super.dispose();
  }
}
