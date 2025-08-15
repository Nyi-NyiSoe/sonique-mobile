import 'package:sonique/Data/models/genre_model.dart';
import 'package:sonique/Data/models/song_response_model.dart';
import 'package:sonique/Domain/repository/song_data_repository.dart';

class SongService {
  final SongDataRepository repository;
  SongService(this.repository);

  Future<SongResponseModel> fetchSongs() => repository.getAllSongs();
  Future<SongResponseModel> fetchMoreSongs(String cursor) => repository.getMoreSongs(cursor);
   Future<List<GenreModel>> getGenre()=> repository.getGenre();
  
}

