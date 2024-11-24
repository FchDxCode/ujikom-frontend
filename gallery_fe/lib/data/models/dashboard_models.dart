import 'package:json_annotation/json_annotation.dart';

part 'dashboard_models.g.dart';

@JsonSerializable()
class ModelStats {
  final int total;
  final int? active;
  final int? inactive;

  ModelStats({
    required this.total,
    this.active,
    this.inactive,
  });

  factory ModelStats.fromJson(Map<String, dynamic> json) => 
      _$ModelStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ModelStatsToJson(this);
}

@JsonSerializable()
class UserStats {
  final int total;
  final int admin;
  final int petugas;

  UserStats({
    required this.total,
    required this.admin,
    required this.petugas,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => 
      _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}

@JsonSerializable()
class AnalyticsStats {
  @JsonKey(name: 'total_views')
  final int totalViews;
  
  @JsonKey(name: 'recent_views')
  final int recentViews;
  
  @JsonKey(name: 'unique_visitors')
  final int uniqueVisitors;
  
  @JsonKey(name: 'successful_requests')
  final int successfulRequests;
  
  @JsonKey(name: 'period_days')
  final int periodDays;

  AnalyticsStats({
    required this.totalViews,
    required this.recentViews,
    required this.uniqueVisitors,
    required this.successfulRequests,
    required this.periodDays,
  });

  factory AnalyticsStats.fromJson(Map<String, dynamic> json) => 
      _$AnalyticsStatsFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsStatsToJson(this);
}

@JsonSerializable()
class DashboardStats {
  final UserStats users;
  final ModelStats categories;
  final ModelStats albums;
  final ModelStats photos;
  final ModelStats pages;
  
  @JsonKey(name: 'content_blocks')
  final ModelStats contentBlocks;
  final AnalyticsStats analytics;

  DashboardStats({
    required this.users,
    required this.categories,
    required this.albums,
    required this.photos,
    required this.pages,
    required this.contentBlocks,
    required this.analytics,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => 
      _$DashboardStatsFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardStatsToJson(this);
}
