// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelStats _$ModelStatsFromJson(Map<String, dynamic> json) => ModelStats(
      total: (json['total'] as num).toInt(),
      active: (json['active'] as num?)?.toInt(),
      inactive: (json['inactive'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ModelStatsToJson(ModelStats instance) =>
    <String, dynamic>{
      'total': instance.total,
      'active': instance.active,
      'inactive': instance.inactive,
    };

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      total: (json['total'] as num).toInt(),
      admin: (json['admin'] as num).toInt(),
      petugas: (json['petugas'] as num).toInt(),
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'total': instance.total,
      'admin': instance.admin,
      'petugas': instance.petugas,
    };

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

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    DashboardStats(
      users: UserStats.fromJson(json['users'] as Map<String, dynamic>),
      categories:
          ModelStats.fromJson(json['categories'] as Map<String, dynamic>),
      albums: ModelStats.fromJson(json['albums'] as Map<String, dynamic>),
      photos: ModelStats.fromJson(json['photos'] as Map<String, dynamic>),
      pages: ModelStats.fromJson(json['pages'] as Map<String, dynamic>),
      contentBlocks:
          ModelStats.fromJson(json['content_blocks'] as Map<String, dynamic>),
      analytics:
          AnalyticsStats.fromJson(json['analytics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DashboardStatsToJson(DashboardStats instance) =>
    <String, dynamic>{
      'users': instance.users,
      'categories': instance.categories,
      'albums': instance.albums,
      'photos': instance.photos,
      'pages': instance.pages,
      'content_blocks': instance.contentBlocks,
      'analytics': instance.analytics,
    };
