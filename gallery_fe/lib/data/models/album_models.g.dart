// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Album _$AlbumFromJson(Map<String, dynamic> json) => Album(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: json['created_at'] as String?,
      category: (json['category'] as num?)?.toInt() ?? 0,
      createdBy: json['created_by'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      folderPath: json['folderPath'] as String?,
      sequenceNumber: (json['sequence_number'] as num?)?.toInt() ?? 0,
      coverPhotoUrl: json['coverPhotoUrl'] as String?,
    );

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'created_at': instance.createdAt,
      'category': instance.category,
      'created_by': instance.createdBy,
      'isActive': instance.isActive,
      'folderPath': instance.folderPath,
      'sequence_number': instance.sequenceNumber,
      'coverPhotoUrl': instance.coverPhotoUrl,
    };
