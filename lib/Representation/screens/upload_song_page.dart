import 'package:flutter/material.dart';

class UploadSongPage extends StatelessWidget {
  const UploadSongPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Song'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(child: Text('Upload Page')),
    );
  }
}
