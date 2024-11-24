// category_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/category_models.dart';

abstract class CategoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;

  CategoryLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CategoryCreated extends CategoryState {
  final Category category;

  CategoryCreated(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryUpdated extends CategoryState {
  final Category category;

  CategoryUpdated(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryDeleted extends CategoryState {}

class CategoryError extends CategoryState {
  final String message;

  CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
