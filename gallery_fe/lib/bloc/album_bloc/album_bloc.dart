import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/data/repositories/category_repositories.dart';
import 'album_event.dart';
import 'album_state.dart';
import '../../data/repositories/album_repositories.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final AlbumRepository albumRepository;
  final CategoryRepository categoryRepository;

  AlbumBloc(this.albumRepository, this.categoryRepository) : super(AlbumInitial()) {
    on<FetchAlbums>(_onFetchAlbums);
    on<CreateAlbum>(_onCreateAlbum);
    on<UpdateAlbum>(_onUpdateAlbum);
    on<DeleteAlbum>(_onDeleteAlbum);
    on<FetchAlbumByCategory>(_onFetchAlbumByCategory);
  }

  Future<void> _onFetchAlbums(
    FetchAlbums event,
    Emitter<AlbumState> emit,
  ) async {
    await _handleLoadingAndError(emit, () async {
      final albums = await albumRepository.fetchAlbums();
      emit(AlbumLoaded(albums));
    });
  }

  Future<void> _onCreateAlbum(
    CreateAlbum event,
    Emitter<AlbumState> emit,
  ) async {
    await _handleLoadingAndError(emit, () async {
      final album = await albumRepository.createAlbum(event.album);
      emit(AlbumCreated(album));
      // Refresh albums after successful creation
      add(FetchAlbums());
    });
  }

  Future<void> _onUpdateAlbum(
    UpdateAlbum event,
    Emitter<AlbumState> emit,
  ) async {
    await _handleLoadingAndError(emit, () async {
      final updatedAlbum = await albumRepository.updateAlbum(event.album);
      emit(AlbumUpdated(updatedAlbum));
      // Refresh albums after successful update
      add(FetchAlbums());
    });
  }

  Future<void> _onDeleteAlbum(
    DeleteAlbum event,
    Emitter<AlbumState> emit,
  ) async {
    await _handleLoadingAndError(emit, () async {
      await albumRepository.deleteAlbum(event.albumId);
      emit(AlbumDeleted());
      // Refresh albums after successful deletion
      add(FetchAlbums());
    });
  }

  Future<void> _onFetchAlbumByCategory(
    FetchAlbumByCategory event,
    Emitter<AlbumState> emit,
  ) async {
    emit(AlbumLoading());
    try {
      final albums = await albumRepository.fetchAlbumsByCategory(event.categoryId);
      emit(AlbumLoaded(albums));
    } catch (e) {
      emit(AlbumError('Failed to load albums by category: ${e.toString()}'));
    }
  }

  Future<void> _handleLoadingAndError(
    Emitter<AlbumState> emit,
    Future<void> Function() action,
  ) async {
    emit(AlbumLoading());
    try {
      await action();
    } catch (e) {
      emit(AlbumError('An error occurred: ${e.toString()}'));
    }
  }
}
