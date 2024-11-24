// photo_event.dart
import 'package:equatable/equatable.dart';
import '../../data/models/photo_models.dart';
import 'package:image_picker/image_picker.dart'; // Tambahkan ini

abstract class PhotoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPhotos extends PhotoEvent {}

class CreatePhoto extends PhotoEvent {
  final Photo photo;
  final XFile imageFile; // Ubah File menjadi XFile

  CreatePhoto(this.photo, this.imageFile);

  @override
  List<Object?> get props => [photo, imageFile];
}

class UpdatePhoto extends PhotoEvent {
  final Photo photo;
  final XFile? imageFile; // Ubah File? menjadi XFile?

  UpdatePhoto(this.photo, {this.imageFile});

  @override
  List<Object?> get props => [photo, imageFile];
}

class DeletePhoto extends PhotoEvent {
  final int id;

  DeletePhoto(this.id);

  @override
  List<Object?> get props => [id];
}

class FetchPhotosByAlbum extends PhotoEvent {
  final int albumId;

  FetchPhotosByAlbum(this.albumId);

  @override
  List<Object?> get props => [albumId];
}

class RefreshPhotos extends PhotoEvent {}
