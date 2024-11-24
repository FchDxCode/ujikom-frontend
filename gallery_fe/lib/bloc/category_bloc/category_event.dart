// category_event.dart
import 'package:equatable/equatable.dart';
import '../../data/models/category_models.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchCategories extends CategoryEvent {}

class CreateCategory extends CategoryEvent {
  final Category category;

  CreateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategory extends CategoryEvent {
  final Category category;

  UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final int categoryId;

  DeleteCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
