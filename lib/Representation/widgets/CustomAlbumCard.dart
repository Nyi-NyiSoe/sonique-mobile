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
        } else {
          context.go('/library/albumByArtist/albumDetail');
        }
      },
      child: Container(
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(imageUrl,fit: BoxFit.cover,),
        ),
      ),
    );
  }
}
