// lib/bloc/analytics_bloc/analytics_event.dart
abstract class AnalyticsEvent {}

class FetchAnalyticsStats extends AnalyticsEvent {
  final int days;
  
  FetchAnalyticsStats({this.days = 30});
}

class RefreshAnalyticsStats extends AnalyticsEvent {
  final int days;
  
  RefreshAnalyticsStats({this.days = 30});
}

class FetchAnalyticsArchives extends AnalyticsEvent {}

class DownloadAnalyticsArchive extends AnalyticsEvent {
  final String filename;
  
  DownloadAnalyticsArchive(this.filename);
}
