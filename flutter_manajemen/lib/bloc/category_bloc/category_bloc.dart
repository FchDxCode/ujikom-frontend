// category_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';
import '../../data/repositories/category_repositories.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc(this.categoryRepository) : super(CategoryInitial()) {
    on<FetchCategories>(_onFetchCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onFetchCategories(
    FetchCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await categoryRepository.fetchCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('Failed to load categories'));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await categoryRepository.createCategory(event.category);
      // Refresh categories after successful creation
      add(FetchCategories());
    } catch (e) {
      emit(CategoryError('Failed to create category'));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await categoryRepository.updateCategory(event.category);
      // Refresh categories after successful update
      add(FetchCategories());
    } catch (e) {
      emit(CategoryError('Failed to update category'));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await categoryRepository.deleteCategory(event.categoryId);
      // Refresh categories after successful deletion
      add(FetchCategories());
    } catch (e) {
      emit(CategoryError('Failed to delete category'));
    }
  }
}
