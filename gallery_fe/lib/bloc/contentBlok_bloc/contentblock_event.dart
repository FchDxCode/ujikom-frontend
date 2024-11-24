import 'package:equatable/equatable.dart';
import '../../data/models/contentblock_models.dart';
import 'package:http/http.dart' as http;

abstract class ContentBlockEvent extends Equatable {
  const ContentBlockEvent();

  @override
  List<Object> get props => [];
}

class FetchContentBlocks extends ContentBlockEvent {}

class CreateContentBlock extends ContentBlockEvent {
  final ContentBlockModel contentBlock;
  final http.MultipartFile imageFile;  // Ubah tipe dari File ke MultipartFile

  const CreateContentBlock({
    required this.contentBlock,
    required this.imageFile,
  });

  @override
  List<Object> get props => [contentBlock, imageFile];
}

class UpdateContentBlock extends ContentBlockEvent {
  final ContentBlockModel contentBlock;
  final dynamic imageFile; // Ubah tipe dari File? ke dynamic

  const UpdateContentBlock(this.contentBlock, {this.imageFile});

  @override
  List<Object> get props => [contentBlock, imageFile ?? ''];
}

class DeleteContentBlock extends ContentBlockEvent {
  final int id;

  const DeleteContentBlock(this.id);

  @override
  List<Object> get props => [id];
}

class FetchContentBlocksByPage extends ContentBlockEvent {
    final int pageId;

    const FetchContentBlocksByPage(this.pageId);

    @override
    List<Object> get props => [pageId];
}

class RefreshContentBlock extends ContentBlockEvent {}

