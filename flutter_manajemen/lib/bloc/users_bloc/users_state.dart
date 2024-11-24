// users_state.dart
import '../../data/models/users_models.dart';

abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<User> users;
  UsersLoaded(this.users);
}

class UsersError extends UsersState {
  final String error;
  UsersError(this.error);
}

class UsersOperationSuccess extends UsersState {}
