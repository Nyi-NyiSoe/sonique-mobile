import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonique/Domain/repository/album_repository.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_event.dart';
import 'package:sonique/Representation/Bloc/album_bloc/album_crud_bloc/album_by_artist_bloc/album_by_artist_state.dart';

class AlbumByArtistBloc extends Bloc<AlbumByArtistEvent, AlbumByArtistState> {
  static const Duration _cacheDuration = Duration(minutes: 3);

  final AlbumRepository albumRepository;
  DateTime? _lastFetchedAt;
  int? _lastArtistId;

  AlbumByArtistBloc({required this.albumRepository})
    : super(AlbumByArtistInitial()) {
    on<FetchAlbumByArtistIdEvent>(_onFetchAlbumByArtistId);
  }

  Future<void> _onFetchAlbumByArtistId(
    FetchAlbumByArtistIdEvent event,
    Emitter<AlbumByArtistState> emit,
  ) async {
    final now = DateTime.now();
    final hasFreshCache =
        state is AlbumByArtistLoaded &&
        _lastArtistId == event.artistId &&
        _lastFetchedAt != null &&
        now.difference(_lastFetchedAt!) < _cacheDuration;

    if (hasFreshCache && !event.forceRefresh) {
      return;
    }

    if (state is! AlbumByArtistLoaded || _lastArtistId != event.artistId) {
      emit(AlbumByArtistLoading());
    }

    try {
      final albums = await albumRepository.getAlbumByArtistId(event.artistId);
      _lastArtistId = event.artistId;
      _lastFetchedAt = DateTime.now();
      emit(AlbumByArtistLoaded(albums));
    } catch (e) {
      emit(AlbumByArtistError(e.toString()));
    }
  }
}
