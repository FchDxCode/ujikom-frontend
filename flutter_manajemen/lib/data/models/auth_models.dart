import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class Auth {
  final String access;
  final String refresh;
  final String role;
  String? username;

  Auth({
    required this.access,
    required this.refresh,
    required this.role,
   this.username
  });

  factory Auth.fromJson(Map<String, dynamic> json) => _$AuthFromJson(json);

  Map<String, dynamic> toJson() => _$AuthToJson(this);
}
