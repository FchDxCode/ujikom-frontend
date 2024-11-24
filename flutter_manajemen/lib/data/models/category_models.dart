// category_models.dart
import 'package:json_annotation/json_annotation.dart';

part 'category_models.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String description;
  @JsonKey(name: 'sequence_number')
  final int sequenceNumber;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.sequenceNumber,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
