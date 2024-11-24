import 'package:json_annotation/json_annotation.dart';
import '../repositories/env.dart';

part 'album_models.g.dart';

@JsonSerializable()
class Album {
  final int id;
  final String title; 
  final String description;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final int category;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  final bool isActive;
  final String? folderPath;
  @JsonKey(name: 'sequence_number')
  final int sequenceNumber;
  @JsonKey(name: 'cover_photo_url')
  final String? _coverPhotoUrl;

  String? get coverPhotoUrl => _coverPhotoUrl != null 
      ? Env.getMediaUrl(_coverPhotoUrl)
      : null;

  Album({
    required this.id,
    required this.title,
    required this.description,
    this.createdAt,
    this.category = 0,
    this.createdBy,
    this.isActive = false,
    this.folderPath,
    this.sequenceNumber = 0,
    String? coverPhotoUrl,
  }) : _coverPhotoUrl = coverPhotoUrl;

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      createdAt: json['created_at'],
      category: json['category'] ?? 0,
      createdBy: json['created_by'],
      isActive: json['is_active'] ?? false,
      folderPath: json['folder_path'],
      sequenceNumber: json['sequence_number'] ?? 0,
      coverPhotoUrl: json['cover_photo_url'],
    );
  }

  Map<String, dynamic> toJson() => _$AlbumToJson(this);
}
