//album_event.dart

import 'package:equatable/equatable.dart';
import '../../data/models/album_models.dart';

abstract class AlbumEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAlbums extends AlbumEvent {}

class CreateAlbum extends AlbumEvent {
  final Album album;

  CreateAlbum(this.album);

  @override
  List<Object?> get props => [album];
}

class UpdateAlbum extends AlbumEvent {
  final Album album;

  UpdateAlbum(this.album);

  @override
  List<Object?> get props => [album];
}

class DeleteAlbum extends AlbumEvent {
  final int albumId;

  DeleteAlbum(this.albumId);

  @override
  List<Object?> get props => [albumId];
}

class FetchAlbumByCategory extends AlbumEvent {
  final int categoryId;

  FetchAlbumByCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

