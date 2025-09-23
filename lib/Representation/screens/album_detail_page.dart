import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_operations_bloc/album_operations_state.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_detail_bloc/album_detail_state.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_state.dart';
import 'package:sonique/Representation/screens/upload_songs_album_page.dart';
import 'package:sonique/Representation/widgets/CustomPlayList.dart';

class AlbumDetailPage extends StatelessWidget {
  const AlbumDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BlocBuilder<UserDataBloc, UserDataState>(
        builder: (context, userState) {
          if (userState is UserDataFetchedState) {
            return BlocBuilder<AlbumDetailBloc, AlbumDetailState>(
              builder: (context, albumState) {
                if (albumState is AlbumDetailLoaded) {
                  final isOwner =
                      albumState.album.artistId == userState.user.userId;
                  final isArtist = userState.user.isArtist;
                  if (isArtist && isOwner) {
                    return FloatingActionButton(
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return UploadSongsAlbumPage(
                              userId: userState.user.userId,
                              albumId: albumState.album.id!,
                            );
                          },
                        );
                      },
                      child: const Icon(Icons.upload),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      body: BlocListener<AlbumOperationsBloc, AlbumOperationsState>(
        listener: (context, operationsState) {
          // Listen for successful album operations and refresh album details
          if (operationsState is AlbumOperationSuccess) {
            final currentAlbumState = context.read<AlbumDetailBloc>().state;
            if (currentAlbumState is AlbumDetailLoaded) {
              // Refresh the album details
              context.read<AlbumDetailBloc>().add(
                FetchAlbumDetailEvent(currentAlbumState.album.id!),
              );
            }
          }
        },
        child: BlocBuilder<AlbumDetailBloc, AlbumDetailState>(
          builder: (context, state) {
            if (state is AlbumDetailLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is AlbumDetailLoaded) {
              final songs = state.album.songs;
              log(state.album.toString());
              if (songs.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(FontAwesomeIcons.angleLeft),
                    ),
                    Center(child: Text("No songs in album yet.")),
                    SizedBox.shrink(),
                  ],
                );
              }
              return CustomPlayList(songs: songs, albumId: state.album.id);
            } else {
              return SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
