import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Domain/repository/artist_repository.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_event.dart';
import 'package:sonique/Representation/Bloc/artist_bloc/artist_state.dart';

class ArtistBloc extends Bloc<ArtistEvent,ArtistState>{
  final ArtistRepository artistRepository;
  ArtistBloc({required this.artistRepository}):super(ArtistInitial()){
    on<FetchArtistsEvent>(_onFetchArtist);
  }

  Future<void> _onFetchArtist(
    FetchArtistsEvent event,Emitter<ArtistState> emit
  )async{
    emit(ArtistLoading());
    try{
      final res = await artistRepository.getAllArtist();
      emit(ArtistLoaded(artists: res));
    }catch(e){
      emit(ArtistError(error: e.toString()));
    }
  }
}