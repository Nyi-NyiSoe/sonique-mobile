import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_state.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_bloc.dart';
import 'package:sonique/Representation/Bloc/like_song_bloc/like_song_state.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_bloc.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_event.dart';
import 'package:sonique/Representation/Bloc/playlist_bloc/playlist_state.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_bloc.dart';
import 'package:sonique/Representation/Bloc/user_data_bloc/user_data_state.dart';
import 'package:sonique/core/services/routes/routes.dart';

class LibraryPage extends StatelessWidget {
  LibraryPage({super.key});

  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    // Display user data
    return Scaffold(
      appBar: AppBar(title: const Text('Library Page')),
      floatingActionButton: BlocBuilder<UserDataBloc, UserDataState>(
        builder: (context, state) {
          if (state is UserDataFetchedState) {
            final isArtist = state.user.isArtist;
            return SpeedDial(
              useRotationAnimation: true,
              icon: Icons.add,
              activeIcon: Icons.close,
              spacing: 3,
              openCloseDial: isDialOpen,
              children: [
                if (isArtist) ...[
                  SpeedDialChild(
                    child: Icon(Icons.upload),
                    label: 'Upload Track',
                    onTap: () {
                      context.push(Routes.upload);
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.album),
                    label: 'Upload Album',
                    onTap: () {
                      context.push(Routes.uploadAlbum);
                    },
                  ),
                ],

                SpeedDialChild(
                  child: Icon(Icons.playlist_add),
                  label: 'Create playlist',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final TextEditingController _controller =
                            TextEditingController();
                        return AlertDialog(
                          title: Text('Create Playlist'),
                          content: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              labelText: 'Playlist Title',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final title = _controller.text.trim();
                                if (title.isNotEmpty) {
                                  context.read<PlaylistBloc>().add(
                                    CreatePlaylistEvent(name: title),
                                  );
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text('Create'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                context.go('/library/likedSong'); // works fine
              },
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.grey.withOpacity(0.2),
              highlightColor: Colors.grey.withOpacity(0.1),
              child: ListTile(
                leading: Container(
                  width: 50, // Set a fixed width to fit the leading space
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    gradient: LinearGradient(
                      colors: [Colors.pinkAccent, Colors.redAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(FontAwesomeIcons.heart, color: Colors.white),
                ),
                title: Text('Liked Songs'),
                subtitle: BlocBuilder<LikesBloc, LikeSongState>(
                  builder: (context, state) {
                    final likedSongsCount = state.likedSongs.length;
                    return Text("$likedSongsCount songs");
                  },
                ),
              ),
            ),
            BlocBuilder<PlaylistBloc, PlaylistState>(
              builder: (context, state) {
                if (state.status == PlaylistStatus.loading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state.status == PlaylistStatus.success) {
                  final songs = state.playlists;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          context.read<PlaylistBloc>().add(
                            FetchPlaylistDetailevent(
                              playlistId: state.playlists[index].id!,
                            ),
                          );
                          context.go('/library/playlistPage');
                        },
                        borderRadius: BorderRadius.circular(12),
                        splashColor: Colors.greenAccent.withOpacity(0.2),
                        highlightColor: Colors.greenAccent.withOpacity(0.1),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              gradient: LinearGradient(
                                colors: [Colors.lightGreen, Colors.tealAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              FontAwesomeIcons.listUl,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(songs[index].name!),
                          subtitle: Text(
                            "${songs[index].totalSongs.toString()} songs",
                          ),
                        ),
                      );
                    },
                  );
                } else if (state.status == PlaylistStatus.error) {
                  return Center(child: Text(state.message.toString()));
                } else {
                  return SizedBox.shrink();
                }
              },
            ),

            BlocBuilder<UserDataBloc, UserDataState>(
              builder: (context, state) {
                if (state is UserDataFetchedState) {
                  final isArtist = state.user.isArtist;
                  if (isArtist) {
                    return InkWell(
                      onTap: () {
                        context.read<AlbumByArtistBloc>().add(
                          FetchAlbumByArtistIdEvent(state.user.userId),
                        );
                        context.go('/library/albumByArtist'); // works fine
                      },
                      borderRadius: BorderRadius.circular(12),
                      splashColor: Colors.grey.withOpacity(0.2),
                      highlightColor: Colors.grey.withOpacity(0.1),
                      child: ListTile(
                        leading: Container(
                          width:
                              50, // Set a fixed width to fit the leading space
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.blueAccent,
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            FontAwesomeIcons.folder,
                            color: Colors.white,
                          ),
                        ),
                        title: Text('Your Albums'),
                        subtitle:
                            BlocBuilder<AlbumByArtistBloc, AlbumByArtistState>(
                              builder: (context, albumState) {
                                if (albumState is AlbumByArtistLoaded) {
                                  return Text(
                                    "${albumState.albums.length} albums",
                                  );
                                } else {
                                  return Text("0 albums");
                                }
                              },
                            ),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
