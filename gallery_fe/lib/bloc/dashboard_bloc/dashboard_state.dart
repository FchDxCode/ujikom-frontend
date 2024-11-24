// lib/bloc/dashboard_bloc/dashboard_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/dashboard_models.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;

  DashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}