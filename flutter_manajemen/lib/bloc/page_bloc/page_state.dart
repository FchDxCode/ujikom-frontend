import 'package:equatable/equatable.dart';
import '../../data/models/page_models.dart';

abstract class PageState extends Equatable {
  const PageState();
  
  @override
  List<Object> get props => [];
}

class PageInitial extends PageState {}

class PageLoading extends PageState {}

class PageLoaded extends PageState {
  final List<PageModel> pages;
  const PageLoaded(this.pages);

  @override
  List<Object> get props => [pages];
}

class PageError extends PageState {
  final String message;
  const PageError(this.message);

  @override
  List<Object> get props => [message];
}

class PageDeleting extends PageState {}

class PageDeleted extends PageState {}
