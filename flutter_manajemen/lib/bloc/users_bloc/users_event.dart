// users_event.dart
import '../../data/models/users_models.dart';

abstract class UsersEvent {}

class FetchUsers extends UsersEvent {}

class CreateUser extends UsersEvent {
  final User user;
  final String password;
  CreateUser(this.user, this.password);
}

class UpdateUser extends UsersEvent {
  final User user;
  final String? password;
  UpdateUser(this.user, this.password);
}

class DeleteUser extends UsersEvent {
  final int id;
  DeleteUser(this.id);
}

class RestructureUserIDs extends UsersEvent {}

class RefreshUsers extends UsersEvent {}