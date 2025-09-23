import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_event.dart';

class CustomAlbumCard extends StatelessWidget {
  const CustomAlbumCard({
    super.key,
    required this.imageUrl,
    required this.albumId,
  });
  final String imageUrl;
  final int albumId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AlbumDetailBloc>().add(FetchAlbumDetailEvent(albumId));
        final currentRoute = GoRouter.of(context).state.uri;
        if (currentRoute.toString().startsWith('/home')) {
          context.go('/home/albumDetail');
        } else if (currentRoute.toString().startsWith('/home/artistDetail')) {
          context.go('/home/artistDetail/albumDetail');
        } else {
          context.go('/library/albumByArtist/albumDetail');
        }
      },
      child: Container(
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: 120, // 👈 give width
            height: 120, // 👈 and height
            placeholder:
                (context, url) => Container(
                  width: 120, // 👈 same size as image
                  height: 120,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            errorWidget:
                (context, url, error) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
          ),
        ),
      ),
    );
  }
}
