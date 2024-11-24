import 'package:flutter/material.dart';
import 'package:luminova/presentation/widgets/users/view_users.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:luminova/presentation/widgets/alert_custom.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/bloc/users_bloc/users_bloc.dart';
import 'package:luminova/bloc/users_bloc/users_event.dart';
import 'package:luminova/bloc/users_bloc/users_state.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});
  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final RefreshController _refreshController = RefreshController();
  bool _isShowingAlert = false;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    context.read<UsersBloc>().add(FetchUsers());
  }

  void _showAlert(String message, AlertType type) {
    if (!mounted || _isShowingAlert) return;

    setState(() {
      _isShowingAlert = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.showEnhancedModernAlert(
          message: message,
          type: type,
          style: AlertStyle.toast,
          duration: const Duration(seconds: 1),
        ).then((_) {
          if (mounted) {
            setState(() {
              _isShowingAlert = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UsersLoaded) {
            _refreshController.refreshCompleted();
            _showAlert('Data pengguna berhasil dimuat ulang!', AlertType.success);
          } else if (state is UsersError) {
            _refreshController.refreshFailed();
            _showAlert('Gagal memuat ulang data pengguna.', AlertType.error);
          }
        },
        child: SmartRefresher(
          enablePullDown: true,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: const ViewUsers(),
        ),
      ),
    );
  }
}
