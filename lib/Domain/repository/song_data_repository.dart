import 'package:image_picker/image_picker.dart';
import 'package:sonique/Data/models/genre_model.dart';
import 'package:sonique/Data/models/liked_song_model.dart';
import 'package:sonique/Data/models/song_response_model.dart';

abstract class SongDataRepository {
  Future<SongResponseModel> getAllSongs();

  Future<SongResponseModel> getMoreSongs(String cursor);

  Future<List<GenreModel>> getGenre();
  Future<void> uploadGenre(String genreName);
  Future<void> uploadSong(XFile audioFile,XFile coverImage,String genreId,String title);
  Future<void> likeASong(String songId);
  Future<List<LikedSongModel>> loadLikedSongs();
}
