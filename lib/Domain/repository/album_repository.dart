import 'package:sonique/Data/models/album_detail_model.dart';
import 'package:sonique/Data/models/album_model.dart';

abstract class AlbumRepository {

  Future<List<AlbumModel>> getAllAlbums();
  Future<AlbumDetailModel> getAlbumDetail(int albumId);
}