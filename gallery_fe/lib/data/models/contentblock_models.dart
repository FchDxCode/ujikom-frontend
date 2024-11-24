import 'package:json_annotation/json_annotation.dart';

part 'contentblock_models.g.dart';

@JsonSerializable()
class ContentBlockModel {
  final int id;
  final int page;
  final String title;
  final String image;
  final String? description;
  @JsonKey(name: 'created_by')
  final String? created_by;
  @JsonKey(name: 'updated_at')
  final DateTime? updated_at;
  @JsonKey(name: 'sequence_number', defaultValue: 0)
  final int? sequence_number;

  ContentBlockModel({
    required this.id,
    required this.page,
    required this.title,
    required this.image,
    required this.description,
    this.created_by,
    this.updated_at,
    this.sequence_number,
  });

  factory ContentBlockModel.fromJson(Map<String, dynamic> json) =>
      _$ContentBlockModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContentBlockModelToJson(this);
}
