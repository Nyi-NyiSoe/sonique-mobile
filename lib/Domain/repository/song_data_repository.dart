import 'package:sonique/Data/models/genre_model.dart';
import 'package:sonique/Data/models/song_response_model.dart';

abstract class SongDataRepository {
  Future<SongResponseModel> getAllSongs();

  Future<SongResponseModel> getMoreSongs(String cursor);

  Future<List<GenreModel>> getGenre();
  Future<void> uploadGenre(String genreName);
}
