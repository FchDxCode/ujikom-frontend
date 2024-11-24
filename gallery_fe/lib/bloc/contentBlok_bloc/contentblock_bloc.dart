import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/contentblock_repositories.dart';
import 'contentblock_event.dart';
import 'contentblock_state.dart';

class ContentBlockBloc extends Bloc<ContentBlockEvent, ContentBlockState> {
  final ContentBlockRepository contentblockRepository;

  ContentBlockBloc(this.contentblockRepository) : super(ContentBlockLoading()) {
    on<FetchContentBlocks>(_onFetchContentBlocks);
    on<CreateContentBlock>(_onCreateContentBlock);
    on<UpdateContentBlock>(_onUpdateContentBlock);
    on<DeleteContentBlock>(_onDeleteContentBlock);
    on<FetchContentBlocksByPage>(_onFetchContentBlocksByPage);
    on<RefreshContentBlock>(_onRefreshContentBlock);
  }

  Future<void> _onFetchContentBlocks(
    FetchContentBlocks event,
    Emitter<ContentBlockState> emit,
  ) async {
    try {
      emit(ContentBlockLoading());
      final contentBlocks = await contentblockRepository.fetchContentBlocks();
      emit(ContentBlockLoaded(contentBlocks));
    } catch (e) {
      emit(ContentBlockError(e.toString()));
    }
  }

  Future<void> _onCreateContentBlock(
    CreateContentBlock event,
    Emitter<ContentBlockState> emit,
  ) async {
    emit(ContentBlockLoading());
    try {
      await contentblockRepository.createContentBlock(
        event.contentBlock,
        event.imageFile,
      );
      emit(ContentBlockLoaded(
        await contentblockRepository.fetchContentBlocks()
      ));
    } catch (e) {
      emit(ContentBlockError(e.toString()));
    }
  }

  Future<void> _onUpdateContentBlock(
    UpdateContentBlock event,
    Emitter<ContentBlockState> emit,
  ) async {
    try {
      emit(ContentBlockLoading());
      await contentblockRepository.updateContentBlock(
        event.contentBlock,
        imageFile: event.imageFile,
      );

      // Fetch updated data after successful update
      final contentBlocks = await contentblockRepository.fetchContentBlocks();
      emit(ContentBlockLoaded(contentBlocks));
    } catch (e) {
      emit(
          ContentBlockError('Failed to update content block: ${e.toString()}'));
      // Fetch data again even if update failed to maintain UI state
      try {
        final contentBlocks = await contentblockRepository.fetchContentBlocks();
        emit(ContentBlockLoaded(contentBlocks));
      } catch (e) {
        // If both update and fetch fail, keep the error state
        emit(ContentBlockError(
            'Failed to load content blocks: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteContentBlock(
    DeleteContentBlock event,
    Emitter<ContentBlockState> emit,
  ) async {
    emit(ContentBlockLoading());
    try {
      await contentblockRepository.deleteContentBlock(event.id);
      // Jika delete berhasil, muat ulang data
      add(FetchContentBlocks());
    } catch (e) {
      // Emit error jika delete gagal
      emit(
          ContentBlockError('Failed to delete content block: ${e.toString()}'));
    }
  }

  Future<void> _onFetchContentBlocksByPage(
    FetchContentBlocksByPage event,
    Emitter<ContentBlockState> emit,
  ) async {
    try {
      emit(ContentBlockLoading());
      final contentBlocks =
          await contentblockRepository.fetchContentBlocksByPage(event.pageId);
      emit(ContentBlockLoaded(contentBlocks));
    } catch (e) {
      emit(ContentBlockError(e.toString()));
    }
  }

  Future<void> _refreshContentBlocks(Emitter<ContentBlockState> emit) async {
    try {
      final contentBlocks = await contentblockRepository.fetchContentBlocks();
      emit(ContentBlockLoaded(contentBlocks));
    } catch (e) {
      emit(ContentBlockError(e.toString()));
    }
  }

  Future<void> _onRefreshContentBlock(
      RefreshContentBlock event, Emitter<ContentBlockState> emit) async {
    await _refreshContentBlocks(emit);
  }
}
