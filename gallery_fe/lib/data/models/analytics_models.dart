import 'package:json_annotation/json_annotation.dart';

part 'analytics_models.g.dart';

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
class AnalyticsArchive {
  final String name;
  final int size;
  final DateTime created;

  AnalyticsArchive({
    required this.name,
    required this.size,
    required this.created,
  });

  factory AnalyticsArchive.fromJson(Map<String, dynamic> json) => 
      AnalyticsArchive(
        name: json['name'] as String,
        size: json['size'] as int,
        created: DateTime.parse(json['created'] as String),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'size': size,
        'created': created.toIso8601String(),
      };
}
