import 'package:equatable/equatable.dart';
import '../../data/models/page_models.dart';

abstract class PageEvent extends Equatable {
  const PageEvent();
  @override
  List<Object> get props => [];
}

class FetchPages extends PageEvent {}

class CreatePage extends PageEvent {
  final PageModel page;
  const CreatePage(this.page);
}

class UpdatePage extends PageEvent {
  final PageModel page;
  const UpdatePage(this.page);
}

class DeletePageRequested extends PageEvent {
  final int id;

  const DeletePageRequested(this.id);

  @override
  List<Object> get props => [id];
}

class RefreshPage extends PageEvent {}