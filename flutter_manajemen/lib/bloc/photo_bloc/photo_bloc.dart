import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/data/repositories/album_repositories.dart';
import 'photo_event.dart';
import 'photo_state.dart';
import '../../data/repositories/photo_repositories.dart';

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  final PhotoRepository photoRepository;
  final AlbumRepository albumRepository;
  Map<int, String> albumTitles = {};

  PhotoBloc(this.photoRepository, this.albumRepository)
      : super(PhotoInitial()) {
    on<FetchPhotos>(_onFetchPhotos);
    on<FetchPhotosByAlbum>(_onFetchPhotosByAlbum);
    on<CreatePhoto>(_onCreatePhoto);
    on<UpdatePhoto>(_onUpdatePhoto);
    on<DeletePhoto>(_onDeletePhoto);
    on<RefreshPhotos>(_onRefreshPhotos);
  }

  Future<void> _onFetchPhotos(
      FetchPhotos event, Emitter<PhotoState> emit) async {
    try {
      emit(PhotoLoading());
      albumTitles = await albumRepository.getAlbumPhotos();
      final photos = await photoRepository.fetchPhotos();
      if (photos.isEmpty) {
        emit(const PhotoError('No photos available.'));
      } else {
        emit(PhotoLoaded(photos));
      }
    } catch (e) {
      emit(PhotoError('Failed to load photos: ${e.toString()}'));
    }
  }

  Future<void> _onFetchPhotosByAlbum(
      FetchPhotosByAlbum event, Emitter<PhotoState> emit) async {
    try {
      emit(PhotoLoading());
      final photos = await photoRepository.fetchPhotosByAlbum(event.albumId);
      emit(PhotoLoaded(photos));
    } catch (e) {
      emit(PhotoError("failed to load photos by album ${event.albumId}"));
    }
  }

  Future<void> _onCreatePhoto(
      CreatePhoto event, Emitter<PhotoState> emit) async {
    try {
      emit(PhotoLoading());
      final photo = await photoRepository.createPhoto(event.photo, event.imageFile);
      emit(PhotoCreated(photo));

      // Refresh the photos after successful creation
      add(RefreshPhotos());
    } catch (e) {
      emit(PhotoError('Failed to create photo: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePhoto(
      UpdatePhoto event, Emitter<PhotoState> emit) async {
    try {
      emit(PhotoLoading());
      final updatedPhoto = await photoRepository.updatePhoto(event.photo,
          imageFile: event.imageFile);
      emit(PhotoUpdated(updatedPhoto));

      // Refresh photos setelah update
      final photos = await photoRepository.fetchPhotos();
      emit(PhotoLoaded(photos));
    } catch (e) {
      // Jangan emit PhotoError, tetapi refresh photos
      final photos = await photoRepository.fetchPhotos();
      if (photos.isEmpty) {
        emit(const PhotoError('No photos available.'));
      } else {
        emit(PhotoLoaded(photos));
      }
    }
  }

  Future<void> _onDeletePhoto(
      DeletePhoto event, Emitter<PhotoState> emit) async {
    try {
      emit(PhotoLoading());
      await photoRepository.deletePhoto(event.id);
      emit(PhotoDeleted());
      // Refresh the photos after successful deletion
      add(RefreshPhotos());
    } catch (e) {
      emit(const PhotoError('Failed to delete photo'));
    }
  }

  Future<void> _onRefreshPhotos(
      RefreshPhotos event, Emitter<PhotoState> emit) async {
    try {
      emit(PhotoLoading());
      albumTitles = await albumRepository.getAlbumPhotos();
      final photos = await photoRepository.fetchPhotos();
      emit(PhotoLoaded(photos));
    } catch (e) {
      emit(PhotoError('Failed to refresh photos: ${e.toString()}'));
    }
  }
}
