import 'package:json_annotation/json_annotation.dart';

part 'page_models.g.dart';  

@JsonSerializable()
class PageModel {
  final int id;
  final String title;
  final String slug;
  final String content;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  @JsonKey(name: 'sequence_number')
  final int? sequenceNumber;

  PageModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.sequenceNumber,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'No Title',
      slug: json['slug'] as String? ?? 'No Slug',
      content: json['content'] as String? ?? 'No Content',
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      sequenceNumber: (json['sequence_number'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => _$PageModelToJson(this);
}
