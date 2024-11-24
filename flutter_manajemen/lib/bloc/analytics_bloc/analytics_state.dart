// lib/bloc/analytics_bloc/analytics_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/analytics_models.dart';

abstract class AnalyticsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsStats stats;
  final List<AnalyticsArchive>? archives;

  AnalyticsLoaded(this.stats, {this.archives});

  @override
  List<Object?> get props => [stats, archives];

  AnalyticsLoaded copyWith({
    AnalyticsStats? stats,
    List<AnalyticsArchive>? archives,
  }) {
    return AnalyticsLoaded(
      stats ?? this.stats,
      archives: archives ?? this.archives,
    );
  }
}

class AnalyticsError extends AnalyticsState {
  final String message;

  AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AnalyticsDownloading extends AnalyticsState {}

class AnalyticsDownloadSuccess extends AnalyticsState {}