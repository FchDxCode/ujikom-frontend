// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contentblock_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentBlockModel _$ContentBlockModelFromJson(Map<String, dynamic> json) =>
    ContentBlockModel(
      id: (json['id'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      title: json['title'] as String,
      image: json['image'] as String,
      description: json['description'] as String?,
      created_by: json['created_by'] as String?,
      updated_at: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      sequence_number: (json['sequence_number'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ContentBlockModelToJson(ContentBlockModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'page': instance.page,
      'title': instance.title,
      'image': instance.image,
      'description': instance.description,
      'created_by': instance.created_by,
      'updated_at': instance.updated_at?.toIso8601String(),
      'sequence_number': instance.sequence_number,
    };
