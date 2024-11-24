// lib/bloc/dashboard_bloc/dashboard_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/dashboard_repositories.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(DashboardInitial()) {
    on<FetchDashboardStats>(_onFetchDashboardStats);
    on<RefreshDashboardStats>(_onRefreshDashboardStats);
  }

  Future<void> _onFetchDashboardStats(
    FetchDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(DashboardLoading());
      final stats = await repository.getDashboardStats(refresh: event.refresh);
      emit(DashboardLoaded(stats));
    } on UnauthorizedException catch (e) {
      emit(DashboardError('Unauthorized: ${e.message}'));
    } on DashboardException catch (e) {
      emit(DashboardError(e.message));
    } catch (e) {
      emit(DashboardError('Failed to fetch dashboard: $e'));
    }
  }

  Future<void> _onRefreshDashboardStats(
    RefreshDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is DashboardLoaded) {
        emit(DashboardLoading());
      }
      final stats = await repository.getDashboardStats(refresh: true);
      emit(DashboardLoaded(stats));
    } on UnauthorizedException catch (e) {
      emit(DashboardError('Unauthorized: ${e.message}'));
    } on DashboardException catch (e) {
      emit(DashboardError(e.message));
    } catch (e) {
      emit(DashboardError('Failed to refresh dashboard: $e'));
    }
  }
}