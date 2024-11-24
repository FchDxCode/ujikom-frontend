// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageModel _$PageModelFromJson(Map<String, dynamic> json) => PageModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      slug: json['slug'] as String,
      content: json['content'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sequenceNumber: (json['sequence_number'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PageModelToJson(PageModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'content': instance.content,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'sequence_number': instance.sequenceNumber,
    };
