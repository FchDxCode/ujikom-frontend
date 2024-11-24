// lib/bloc/analytics_bloc/analytics_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/analytics_repositories.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository repository;

  AnalyticsBloc({required this.repository}) : super(AnalyticsInitial()) {
    on<FetchAnalyticsStats>(_onFetchAnalyticsStats);
    on<RefreshAnalyticsStats>(_onRefreshAnalyticsStats);
    on<FetchAnalyticsArchives>(_onFetchAnalyticsArchives);
    on<DownloadAnalyticsArchive>(_onDownloadAnalyticsArchive);
  }

  Future<void> _onFetchAnalyticsStats(
    FetchAnalyticsStats event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(AnalyticsLoading());
      final stats = await repository.getAnalyticsStats(days: event.days);
      final archives = await repository.getArchives();
      emit(AnalyticsLoaded(stats, archives: archives));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onRefreshAnalyticsStats(
    RefreshAnalyticsStats event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AnalyticsLoaded) {
        emit(AnalyticsLoading());
      }
      final stats = await repository.getAnalyticsStats(days: event.days);
      emit(AnalyticsLoaded(stats));
    } on UnauthorizedException catch (e) {
      emit(AnalyticsError('Unauthorized: ${e.message}'));
    } on AnalyticsException catch (e) {
      emit(AnalyticsError(e.message));
    } catch (e) {
      emit(AnalyticsError('Failed to refresh analytics: $e'));
    }
  }

  Future<void> _onFetchAnalyticsArchives(
    FetchAnalyticsArchives event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      if (state is AnalyticsLoaded) {
        final currentState = state as AnalyticsLoaded;
        final archives = await repository.getArchives();
        emit(currentState.copyWith(archives: archives));
      }
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onDownloadAnalyticsArchive(
    DownloadAnalyticsArchive event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final currentState = state;
      emit(AnalyticsDownloading());
      
      await repository.downloadArchive(event.filename);
      emit(AnalyticsDownloadSuccess());
      
      await Future.delayed(const Duration(seconds: 2));
      
      if (currentState is AnalyticsLoaded) {
        final archives = await repository.getArchives();
        emit(AnalyticsLoaded(
          currentState.stats,
          archives: archives,
        ));
      }
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}
