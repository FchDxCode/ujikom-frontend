// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsStats _$AnalyticsStatsFromJson(Map<String, dynamic> json) =>
    AnalyticsStats(
      totalViews: (json['total_views'] as num).toInt(),
      recentViews: (json['recent_views'] as num).toInt(),
      uniqueVisitors: (json['unique_visitors'] as num).toInt(),
      successfulRequests: (json['successful_requests'] as num).toInt(),
      periodDays: (json['period_days'] as num).toInt(),
    );

Map<String, dynamic> _$AnalyticsStatsToJson(AnalyticsStats instance) =>
    <String, dynamic>{
      'total_views': instance.totalViews,
      'recent_views': instance.recentViews,
      'unique_visitors': instance.uniqueVisitors,
      'successful_requests': instance.successfulRequests,
      'period_days': instance.periodDays,
    };

AnalyticsArchive _$AnalyticsArchiveFromJson(Map<String, dynamic> json) =>
    AnalyticsArchive(
      name: json['name'] as String,
      size: (json['size'] as num).toInt(),
      created: DateTime.parse(json['created'] as String),
    );

Map<String, dynamic> _$AnalyticsArchiveToJson(AnalyticsArchive instance) =>
    <String, dynamic>{
      'name': instance.name,
      'size': instance.size,
      'created': instance.created.toIso8601String(),
    };
