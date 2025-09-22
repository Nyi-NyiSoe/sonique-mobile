import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Data/models/song_data_status.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_bloc.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_list_bloc/album_list_state.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_bloc.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_state.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_event.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_state.dart';
import 'package:sonique/Representation/widgets/CustomAlbumCard.dart';
import 'package:sonique/Representation/widgets/CustomSongCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AlbumListBloc>().add(FetchAlbumsEvent());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        final currentState = context.read<SongDataBloc>().state;
        if (currentState.fetchStatus == SongDataStatus.success &&
            currentState.hasMore) {
          context.read<SongDataBloc>().add(FetchMoreSongEvent());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Latest',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),

            // Albums horizontal row
            SliverToBoxAdapter(
              child: SizedBox(
                height: screenHeight * 0.25, // 25% of screen height
                child: BlocBuilder<AlbumListBloc, AlbumListState>(
                  builder: (context, state) {
                    if (state is AlbumListLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is AlbumListError) {
                      return Center(child: Text(state.error));
                    } else if (state is AlbumListLoaded) {
                      final albums = state.albums;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: albums.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          return CustomAlbumCard(
                            albumId: albums[index].id!,
                            imageUrl: albums[index].coverImageUrl!,
                          );
                        },
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Artists',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
            // Artists horizontal row
            SliverToBoxAdapter(
              child: SizedBox(
                height: screenHeight * 0.15, // slightly smaller than albums
                child: BlocBuilder<ArtistBloc, ArtistState>(
                  builder: (context, state) {
                    if (state is ArtistLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is ArtistLoaded) {
                      final artists = state.artists;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: artists.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: (){
                              context.read<AlbumByArtistBloc>().add(FetchAlbumByArtistIdEvent(artists[index].artistId));
                              context.go('/home/artistDetail/${artists[index].artistId}');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: CircleAvatar(
                                radius: screenHeight * 0.08,
                                backgroundImage: NetworkImage(artists[index].profile_image!),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is ArtistError) {
                      return Center(child: Text(state.error));
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Songs',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),

            // Songs vertical list
            BlocBuilder<SongDataBloc, SongDataState>(
              builder: (context, state) {
                if (state.fetchStatus == SongDataStatus.loading) {
                  return SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state.fetchStatus == SongDataStatus.success) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < state.songs.length) {
                          final song = state.songs[index];
                          return Customsongcard(song: song, queue: true);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                      childCount: state.songs.length + (state.hasMore ? 1 : 0),
                    ),
                  );
                } else {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('No data available')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
