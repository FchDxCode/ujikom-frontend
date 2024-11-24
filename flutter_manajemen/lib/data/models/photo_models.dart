import 'package:json_annotation/json_annotation.dart';

part 'photo_models.g.dart';

@JsonSerializable()
class Photo {
  final int id;
  final String? title;
  final String? description;
  final String photo;
  final int album;
  @JsonKey(name: 'uploaded_at')
  final String uploadedAt;
  @JsonKey(name: 'uploaded_by')
  final String? uploadedBy;
  @JsonKey(name: 'sequence_number')
  final int sequenceNumber; 
  final int? likes;

  Photo({
    required this.id,
    this.title,
    this.description,
    required this.photo,
    required this.album,
    required this.uploadedAt,
    this.uploadedBy,
    required this.sequenceNumber,
    this.likes,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      photo: json['photo'] as String,
      album: json['album'] as int,
      uploadedAt: json['uploaded_at'] as String,
      uploadedBy: json['uploaded_by'] as String?,
      sequenceNumber: json['sequence_number'] as int,
      likes: json['likes'] as int?,
    );
  }

  Map<String, dynamic> toJson() => _$PhotoToJson(this);
}
