abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String accessToken;
  final String role; 
  final String? username;

  AuthAuthenticated(this.accessToken, this.role, {this.username});
}

class AuthError extends AuthState {
  final String error;

  AuthError(this.error);
}

class AuthLoggedOut extends AuthState {}
