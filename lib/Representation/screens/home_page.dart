import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        if (currentState.fetchStatus == SongDataStatus.success &&
            currentState.hasMore) {
          context.read<SongDataBloc>().add(FetchMoreSongEvent());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          
          title: const Text('Home Page'),
          actions: [],
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(),
            tabs: [
              Tab(icon: Icon(FontAwesomeIcons.music)),
              Tab(icon: Icon(FontAwesomeIcons.layerGroup)),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            buildTrackTab(scrollController: _scrollController),
            Text('Album'),
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

class buildTrackTab extends StatelessWidget {
  const buildTrackTab({super.key, required ScrollController scrollController})
    : _scrollController = scrollController;

  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongDataBloc, SongDataState>(
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
                return Customsongcard(song: song, queue: true);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}
