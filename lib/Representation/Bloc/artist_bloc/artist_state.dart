import 'package:sonique/Data/models/display_artist_model.dart';

abstract class ArtistState {}

class ArtistInitial extends ArtistState {}

class ArtistLoading extends ArtistState {}

class ArtistLoaded extends ArtistState {
  final List<DisplayArtistModel> artists;
  ArtistLoaded({required this.artists});
}

class ArtistError extends ArtistState {
  final String error;
  ArtistError({required this.error});
}
