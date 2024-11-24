// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      photo: json['photo'] as String,
      album: (json['album'] as num).toInt(),
      uploadedAt: json['uploaded_at'] as String,
      uploadedBy: json['uploaded_by'] as String?,
      sequenceNumber: (json['sequence_number'] as num).toInt(),
      likes: (json['likes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'photo': instance.photo,
      'album': instance.album,
      'uploaded_at': instance.uploadedAt,
      'uploaded_by': instance.uploadedBy,
      'sequence_number': instance.sequenceNumber,
      'likes': instance.likes,
    };
