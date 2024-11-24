import 'package:json_annotation/json_annotation.dart';

part 'users_models.g.dart';

@JsonSerializable()
class User {
  final int? id;
  final String username;
  final String? role;
  final String? password; // Tambahkan ini jika diperlukan untuk operasi create/update

  User({
    this.id,
    required this.username,
    this.role,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? username,
    String? role,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      password: password ?? this.password,
    );
  }
}
