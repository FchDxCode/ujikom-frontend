// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Auth _$AuthFromJson(Map<String, dynamic> json) => Auth(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      role: json['role'] as String,
      username: json['username'] as String?,
    );

Map<String, dynamic> _$AuthToJson(Auth instance) => <String, dynamic>{
      'access': instance.access,
      'refresh': instance.refresh,
      'role': instance.role,
      'username': instance.username,
    };
