import 'package:sonique/Data/models/song_response_model.dart';

abstract class SongDataRepository {
  Future<SongResponseModel> getAllSongs();

  Future<SongResponseModel> getMoreSongs(String cursor);
}
