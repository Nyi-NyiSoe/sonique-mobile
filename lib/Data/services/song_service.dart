import 'package:image_picker/image_picker.dart';
import 'package:sonique/Data/models/genre_model.dart';
import 'package:sonique/Data/models/liked_song_model.dart';
import 'package:sonique/Data/models/song_response_model.dart';
import 'package:sonique/Domain/repository/song_data_repository.dart';

class SongService {
  final SongDataRepository repository;
  SongService(this.repository);

  Future<SongResponseModel> fetchSongs() => repository.getAllSongs();
  Future<SongResponseModel> fetchMoreSongs(String cursor) => repository.getMoreSongs(cursor);
   Future<List<GenreModel>> getGenre()=> repository.getGenre();
   Future<void> uploadSong(XFile audioFile,XFile coverImage,String genreId,String title)=> repository.uploadSong(audioFile, coverImage, genreId, title);
  Future<void> likeASong(String songId)=> repository.likeASong(songId);
  Future<void> unLikeASong(String songId)=> repository.unLikeASong(songId);
  Future<List<LikedSongModel>> loadLikedSongs()=> repository.loadLikedSongs();
  
}

