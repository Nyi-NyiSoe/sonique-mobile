import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Data/models/song_data_status.dart';
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
        if (currentState.fetchStatus == SongDataStatus.success && currentState.hasMore) {
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
         
        ],
      ),
      body: BlocListener<SongDataBloc, SongDataState>(
        listener: (context, state) {
          if (state.fetchStatus == SongDataStatus.failure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error.toString())));
          }
        },
        child: BlocBuilder<SongDataBloc, SongDataState>(
          builder: (context, state) {
            if (state.fetchStatus == SongDataStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.fetchStatus == SongDataStatus.success) {
              return ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                itemCount: state.songs.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < state.songs.length) {
                    final song = state.songs[index];
                    return Customsongcard(
                      song: song,
                      queue: true,
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
