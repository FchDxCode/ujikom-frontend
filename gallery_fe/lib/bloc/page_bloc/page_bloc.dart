import 'package:bloc/bloc.dart';
import '../../data/repositories/page_repositories.dart';
import 'page_event.dart';
import 'page_state.dart';

class PageBloc extends Bloc<PageEvent, PageState> {
  final PageRepository pageRepository;

  PageBloc(this.pageRepository) : super(PageLoading()) {
    on<FetchPages>(_onFetchPages);
    on<CreatePage>(_onCreatePage);
    on<UpdatePage>(_onUpdatePage);
    on<DeletePageRequested>(_onDeletePageRequested);
    on<RefreshPage>(_onRefreshPage); // Event untuk refresh page
  }

  Future<void> _onFetchPages(FetchPages event, Emitter<PageState> emit) async {
    emit(PageLoading());
    try {
      final pages = await pageRepository.fetchPages();
      emit(PageLoaded(pages));
    } catch (e) {
      emit(const PageError('Failed to fetch pages'));
    }
  }

  Future<void> _onCreatePage(CreatePage event, Emitter<PageState> emit) async {
    emit(PageLoading());
    try {
      await pageRepository.createPage(event.page);
      await _refreshPages(emit); // Panggil refresh setelah membuat page
    } catch (e) {
      emit(const PageError('Failed to create page'));
    }
  }

  Future<void> _onUpdatePage(UpdatePage event, Emitter<PageState> emit) async {
    try {
      await pageRepository.updatePage(event.page);
      
      // Perbarui state tanpa memuat ulang jika state saat ini adalah PageLoaded
      final currentState = state;
      if (currentState is PageLoaded) {
        final updatedPages = currentState.pages.map((page) {
          return page.id == event.page.id ? event.page : page;
        }).toList();
        emit(PageLoaded(updatedPages));
      } else {
        await _refreshPages(emit); // Refresh jika state tidak dalam keadaan PageLoaded
      }
    } catch (e) {
      emit(const PageError('Failed to update page'));
    }
  }

  Future<void> _onDeletePageRequested(
    DeletePageRequested event,
    Emitter<PageState> emit,
  ) async {
    emit(PageDeleting());
    try {
      await pageRepository.deletePage(event.id);
      emit(PageDeleted());
      
      // Refresh data setelah penghapusan berhasil
      emit(PageLoading());
      final updatedPages = await pageRepository.fetchPages();
      emit(PageLoaded(updatedPages));
    } catch (e) {
      emit(PageError('Failed to delete page: ${e.toString()}'));
    }
  }

  // Handler untuk event RefreshPage
  Future<void> _onRefreshPage(RefreshPage event, Emitter<PageState> emit) async {
    await _refreshPages(emit);
  }

  // Fungsi untuk refresh page data
  Future<void> _refreshPages(Emitter<PageState> emit) async {
    try {
      final pages = await pageRepository.fetchPages();
      emit(PageLoaded(pages));
    } catch (e) {
      emit(const PageError('Failed to refresh pages'));
    }
  }
}
