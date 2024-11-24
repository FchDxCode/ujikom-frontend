import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repositories.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final auth = await authRepository.login(event.username, event.password);
        emit(AuthAuthenticated(
          auth.access,
          auth.role,
          username: event.username
        ));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.logout();
        emit(AuthLoggedOut());
      } catch (e) {
        emit(AuthLoggedOut());
      }
    });
  }
}