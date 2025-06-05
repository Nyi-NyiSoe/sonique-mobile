import 'package:sonique/Data/models/genre_model.dart';
import 'package:sonique/Data/models/song_model.dart';

abstract class SongDataState {}

class SongDataInitialState extends SongDataState {}

class SongDataLoadingState extends SongDataState {}

class SongDataFetchedState extends SongDataState {
  final List<SongModel> songs;
  final bool hasMore;
  final String cursor;
  final List<GenreModel> genres;

  SongDataFetchedState({
    required this.songs,
    required this.hasMore,
    required this.cursor,
    required this.genres
  });
}

class SongDataErrorState extends SongDataState {
  final String error;

  SongDataErrorState({required this.error});
}
