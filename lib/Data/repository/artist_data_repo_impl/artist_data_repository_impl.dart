import 'package:sonique/Data/models/display_artist_model.dart';
import 'package:sonique/Data/source/artist_data_repo/artist_remote_data.dart';
import 'package:sonique/Domain/repository/artist_repository.dart';

class ArtistDataRepositoryImpl implements ArtistRepository{
  final ArtistRemoteData artistRemoteData;
  ArtistDataRepositoryImpl({required this.artistRemoteData});

  @override 
  Future<List<DisplayArtistModel>> getAllArtist()async{
    try{
      final res = await artistRemoteData.getAllArtist();
      return res;
    }catch(e){
      throw Exception('Failed to get all artist');
    }
  }
}