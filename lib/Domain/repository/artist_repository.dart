import 'package:sonique/Data/models/display_artist_model.dart';

abstract class ArtistRepository {

  Future<List<DisplayArtistModel>> getAllArtist();
}