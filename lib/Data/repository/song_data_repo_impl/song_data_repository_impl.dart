import 'package:image_picker/image_picker.dart';
import 'package:sonique/Data/models/genre_model.dart';
import 'package:sonique/Data/models/song_response_model.dart';
import 'package:sonique/Data/source/song_data_repo/song_remote_data.dart';
import 'package:sonique/Domain/repository/song_data_repository.dart';

class SongDataRepositoryImpl implements SongDataRepository {
  final SongRemoteData songRemoteData;

  SongDataRepositoryImpl({required this.songRemoteData});

  @override
  Future<SongResponseModel> getAllSongs() async {
    try {
      return await songRemoteData.getAllSongs();
    } catch (e) {
      throw Exception('Failed to fetch songs: $e');
    }
  }

  @override
  Future<SongResponseModel> getMoreSongs(String cursor) async {
    try {
      return await songRemoteData.getMoreSongs(cursor);
    } catch (e) {
      throw Exception('Failed to fetch more songs: $e');
    }
  }

  @override 
  Future<List<GenreModel>> getGenre() async{
    try{
      return await songRemoteData.getGenre();

    }catch(e){
      throw Exception('Failed to fetch genre : $e');
    }
  }

  @override 
  Future<void> uploadGenre(String genreName)async{
    try{
      return await songRemoteData.uploadSongGenre(genreName);

    }catch(e){
      throw Exception('Failed to fetch genre : $e');
    }
  }

  @override
  Future<void> uploadSong(XFile audioFile,XFile coverImage,String genreId,String title)async{
    try{
      return await songRemoteData.uploadSong(audioFile, coverImage, genreId, title);
    }catch(e){
      throw Exception('Failed to upload Song: $e');
    }
  }

}
