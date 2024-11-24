// lib/bloc/dashboard_bloc/dashboard_event.dart
abstract class DashboardEvent {}

class FetchDashboardStats extends DashboardEvent {
  final bool refresh;
  
  FetchDashboardStats({this.refresh = false});
}

class RefreshDashboardStats extends DashboardEvent {}