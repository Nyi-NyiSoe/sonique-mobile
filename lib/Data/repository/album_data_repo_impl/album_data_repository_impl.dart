import 'package:image_picker/image_picker.dart';
import 'package:sonique/Data/models/album_detail_model.dart';
import 'package:sonique/Data/models/album_model.dart';
import 'package:sonique/Data/source/album_data_repo/album_remote_data.dart';
import 'package:sonique/Domain/repository/album_repository.dart';

class AlbumDataRepositoryImpl implements AlbumRepository {
  final AlbumRemoteData albumRemoteData;
  AlbumDataRepositoryImpl({required this.albumRemoteData});
  @override
  Future<List<AlbumModel>> getAllAlbums() async {
    try {
      final res = await albumRemoteData.getAllAlbums();

      return res;
    } catch (e) {
      throw Exception('Failed to get all albums');
    }
  }

  @override
  Future<AlbumDetailModel> getAlbumDetail(int albumId) async {
    try {
      final res = await albumRemoteData.getAlbumDetail(albumId);
      return res;
    } catch (e) {
      throw Exception('Failed to get album details!');
    }
  }

  @override
  Future<List<AlbumModel>> getAlbumByArtistId(int artistId) async {
    try {
      final res = await albumRemoteData.getAlbumByArtistId(artistId);
      return res;
    } catch (e) {
      throw Exception('Failed to get album details!');
    }
  }

  @override
  Future<void> createAlbum(String name, XFile coverImage,String description) async {
    try {
      await albumRemoteData.createAlbum(name.toString(), coverImage,description);
    } catch (e) {
      throw Exception('Failed to get album details!');
    }
  }

  @override
  Future<void> addSongsToAlbum(Set<String> songIds,int albumId)async{
    try{
      await albumRemoteData.addSongsToAlbum(songIds, albumId);

    }catch(e){
      throw Exception('Failed to add songs to album!');
    }
  }
}
