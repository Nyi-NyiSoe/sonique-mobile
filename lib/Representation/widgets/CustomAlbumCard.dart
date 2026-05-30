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
    this.albumName,
    this.size = 120,
    this.showTitle = false,
  });

  final String imageUrl;
  final int albumId;
  final String? albumName;
  final double size;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title =
        albumName?.trim().isNotEmpty == true ? albumName!.trim() : 'Untitled';

    return Semantics(
      button: true,
      label: 'Open album $title',
      child: SizedBox(
        width: size,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (albumId <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Album details are unavailable'),
                  ),
                );
                return;
              }

              context.read<AlbumDetailBloc>().add(
                FetchAlbumDetailEvent(albumId),
              );
              final currentRoute = GoRouter.of(context).state.uri;
              if (currentRoute.toString().startsWith('/home/artistDetail')) {
                context.go('/home/artistDetail/albumDetail');
              } else if (currentRoute.toString().startsWith('/home')) {
                context.go('/home/albumDetail');
              } else {
                context.go('/library/albumByArtist/albumDetail');
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: size - 12,
                      height: size - 12,
                      placeholder:
                          (context, url) => _AlbumImageFallback(
                            size: size - 12,
                            icon: Icons.album_outlined,
                          ),
                      errorWidget:
                          (context, url, error) => _AlbumImageFallback(
                            size: size - 12,
                            icon: Icons.broken_image_outlined,
                          ),
                    ),
                  ),
                  if (showTitle) ...[
                    const SizedBox(height: 6),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AlbumImageFallback extends StatelessWidget {
  const _AlbumImageFallback({required this.size, required this.icon});

  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      child: Center(
        child: Icon(
          icon,
          size: 34,
          color: theme.iconTheme.color?.withValues(alpha: 0.54),
        ),
      ),
    );
  }
}
