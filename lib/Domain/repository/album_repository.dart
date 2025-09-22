import 'package:image_picker/image_picker.dart';
import 'package:sonique/Data/models/album_detail_model.dart';
import 'package:sonique/Data/models/album_model.dart';

abstract class AlbumRepository {

  Future<List<AlbumModel>> getAllAlbums();
  Future<AlbumDetailModel> getAlbumDetail(int albumId);
  Future<List<AlbumModel>> getAlbumByArtistId(int artistId);

  Future<void> createAlbum(String name,XFile coverImage,String description);
}