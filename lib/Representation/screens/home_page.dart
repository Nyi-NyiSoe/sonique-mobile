import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/song_data_status.dart';
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
  final List<String> albums = List.generate(
    5,
    (i) => 'assets/images/splash.jpeg',
  );
  final List<String> artists = List.generate(
    5,
    (i) => 'assets/images/splash.jpeg',
  );

  @override
  void initState() {
    super.initState();
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Albums',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('Show all',style: Theme.of(context).textTheme.titleLarge,)
                  ],
                ),
              ),
            ),

            // Albums horizontal row
            SliverToBoxAdapter(
              child: SizedBox(
                height: screenHeight * 0.25, // 25% of screen height
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: albums.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return CustomAlbumCard(
                      imageUrl: 'assets/images/splash.jpeg',
                    );
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Artists',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('Show all',style: Theme.of(context).textTheme.titleLarge,)
                  ],
                ),
              ),
            ),
            // Artists horizontal row
            SliverToBoxAdapter(
              child: SizedBox(
                height: screenHeight * 0.15, // slightly smaller than albums
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: artists.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CircleAvatar(
                        radius: screenHeight * 0.08,
                        backgroundImage: AssetImage(artists[index]),
                        
                      ),
                    );
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
