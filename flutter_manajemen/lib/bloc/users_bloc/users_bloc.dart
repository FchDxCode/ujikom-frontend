  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:luminova/data/models/users_models.dart';
  import '../../data/repositories/users_repositories.dart';
  import 'users_event.dart';
  import 'users_state.dart';

  class UsersBloc extends Bloc<UsersEvent, UsersState> {
    final UserRepository userRepository;

    UsersBloc(this.userRepository) : super(UsersInitial()) {
      on<FetchUsers>(_onFetchUsers);
      on<CreateUser>(_onCreateUser);
      on<UpdateUser>(_onUpdateUser);
      on<DeleteUser>(_onDeleteUser);
      on<RestructureUserIDs>(_onRestructureUserIDs);
    }

    Future<void> _onFetchUsers(FetchUsers event, Emitter<UsersState> emit) async {
      emit(UsersLoading());
      try {
        final users = await userRepository.fetchUsers();
        emit(UsersLoaded(users));
      } catch (e) {
        emit(UsersError(e.toString()));
      }
    }

    Future<void> _onCreateUser(CreateUser event, Emitter<UsersState> emit) async {
      emit(UsersLoading());
      try {
        await userRepository.createUser(event.user, event.password);
        await _refreshUsers(emit);
      } catch (e) {
        emit(UsersError(e.toString()));
      }
    }

    Future<void> _onUpdateUser(UpdateUser event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final updatedUser = await userRepository.updateUser(event.user, event.password);
      final currentState = state;
      if (currentState is UsersLoaded) {
        final updatedUsers = currentState.users.map((user) {
          return user.id == updatedUser.id ? updatedUser : user;
        }).toList();
        emit(UsersLoaded(updatedUsers));
      } else {
        await _refreshUsers(emit);
      }
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }


    Future<void> _onDeleteUser(DeleteUser event, Emitter<UsersState> emit) async {
      emit(UsersLoading());
      try {
        await userRepository.deleteUser(event.id);
        await _refreshUsers(emit);
      } catch (e) {
        emit(UsersError(e.toString()));
      }
    }

    Future<void> _onRestructureUserIDs(RestructureUserIDs event, Emitter<UsersState> emit) async {
      final currentState = state;
      if (currentState is UsersLoaded) {
        List<User> updatedUsers = List.from(currentState.users);
        for (int i = 0; i < updatedUsers.length; i++) {
          updatedUsers[i] = updatedUsers[i].copyWith(id: i + 1);
        }
        emit(UsersLoaded(updatedUsers));
      }
    }

    Future<void> _refreshUsers(Emitter<UsersState> emit) async {
      try {
        final users = await userRepository.fetchUsers();
        emit(UsersLoaded(users));
      } catch (e) {
        emit(UsersError(e.toString()));
      }
    }
  }