import 'package:flutter/material.dart';

class CustomAlbumCard extends StatelessWidget {
  const CustomAlbumCard({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image(image: AssetImage(imageUrl)),
      ),
    );
  }
}
