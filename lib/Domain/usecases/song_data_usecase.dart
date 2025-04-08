import 'package:sonique/Data/models/song_response_model.dart';
import 'package:sonique/Domain/repository/song_data_repository.dart';

class SongDataUsecase {
  final SongDataRepository songDataRepository;
  SongDataUsecase({required this.songDataRepository});

  Future<SongResponseModel> getAllSongs() async {
    try {
      final songResponse = await songDataRepository.getAllSongs();
      return songResponse;
    } catch (e) {
      throw Exception('Failed to fetch songs: $e');
    }
  }

  Future<SongResponseModel> getMoreSongs(String cursor) async {
    try {
      final songResponse = await songDataRepository.getMoreSongs(cursor);
      return songResponse;
    } catch (e) {
      throw Exception('Failed to fetch more songs: $e');
    }
  }
}
