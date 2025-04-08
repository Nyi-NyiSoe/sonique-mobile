import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_bloc.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_event.dart';
import 'package:sonique/Representation/Bloc/song_data_bloc/song_data_state.dart';
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
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        final currentState = context.read<SongDataBloc>().state;
        if (currentState is SongDataFetchedState && currentState.hasMore) {
          context.read<SongDataBloc>().add(FetchMoreSongEvent());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<SongDataBloc>().add(FetchMoreSongEvent());
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: BlocListener<SongDataBloc, SongDataState>(
        listener: (context, state) {
          if (state is SongDataErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: BlocBuilder<SongDataBloc, SongDataState>(
          builder: (context, state) {
            if (state is SongDataLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SongDataFetchedState) {
              return ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                itemCount: state.songs.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < state.songs.length) {
                    final song = state.songs[index];
                    return Customsongcard(
                      songId: song.id,
                      img_url: song.coverImageUrl,
                      songTitle: song.title,
                      artistName: song.artist.name,
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          },
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
