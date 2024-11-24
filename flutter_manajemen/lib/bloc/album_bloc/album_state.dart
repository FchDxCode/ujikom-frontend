
import 'package:equatable/equatable.dart';
import '../../data/models/album_models.dart';

abstract class AlbumState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AlbumInitial extends AlbumState {}

class AlbumLoading extends AlbumState {}

class AlbumLoaded extends AlbumState {
  final List<Album> albums;

  AlbumLoaded(this.albums);

  @override
  List<Object?> get props => [albums];
}

class AlbumCreated extends AlbumState {
  final Album album;

  AlbumCreated(this.album);

  @override
  List<Object?> get props => [album];
}

class AlbumUpdated extends AlbumState {
  final Album album;

  AlbumUpdated(this.album);

  @override
  List<Object?> get props => [album];
}

class AlbumDeleted extends AlbumState {}

class AlbumError extends AlbumState {
  final String message;

  AlbumError(this.message);

  @override
  List<Object?> get props => [message];
}
