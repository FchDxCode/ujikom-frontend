import 'package:equatable/equatable.dart';
import '../../data/models/contentblock_models.dart';

abstract class ContentBlockState extends Equatable {
  const ContentBlockState();

  @override
  List<Object> get props => [];
}

class ContentBlockLoading extends ContentBlockState {}

class ContentBlockLoaded extends ContentBlockState {
  final List<ContentBlockModel> contentBlocks;

  const ContentBlockLoaded(this.contentBlocks);

  @override
  List<Object> get props => [contentBlocks];
}

class ContentBlockError extends ContentBlockState {
  final String error;

  const ContentBlockError(this.error);

  @override
  List<Object> get props => [error];
}
