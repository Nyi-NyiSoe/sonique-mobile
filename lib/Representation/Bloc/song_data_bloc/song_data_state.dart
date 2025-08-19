import 'package:sonique/Data/models/genre_model.dart';
import 'package:sonique/Data/models/song_data_status.dart';
import 'package:sonique/Data/models/song_model.dart';

class SongDataState {
  final List<SongModel> songs;
  final bool hasMore;
  final String cursor;
  final List<GenreModel> genres;

  final SongDataStatus fetchStatus;
  final SongDataStatus uploadStatus;
  final String? error;

  const SongDataState({
    this.songs = const [],
    this.hasMore = true,
    this.cursor = '',
    this.genres = const [],
    this.fetchStatus = SongDataStatus.initial,
    this.uploadStatus = SongDataStatus.initial,
    this.error,
  });

  SongDataState copyWith({
    List<SongModel>? songs,
    bool? hasMore,
    String? cursor,
    List<GenreModel>? genres,
    SongDataStatus? fetchStatus,
    SongDataStatus? uploadStatus,
    String? error,
  }) {
    return SongDataState(
      songs: songs ?? this.songs,
      hasMore: hasMore ?? this.hasMore,
      cursor: cursor ?? this.cursor,
      genres: genres ?? this.genres,
      fetchStatus: fetchStatus ?? this.fetchStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      error: error ?? this.error,
    );
  }
}