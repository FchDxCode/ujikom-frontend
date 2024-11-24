// lib/presentation/screens/dashboard_screens.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../widgets/dashboard/view_dashboard.dart';
import '../widgets/alert_custom.dart';
import '../../bloc/dashboard_bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_bloc/dashboard_event.dart';
import '../../bloc/dashboard_bloc/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final RefreshController _refreshController = RefreshController();
  bool _isShowingAlert = false;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    context.read<DashboardBloc>().add(RefreshDashboardStats());
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
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchDashboardStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardLoaded) {
            _refreshController.refreshCompleted();
            _showAlert('Data dashboard berhasil dimuat ulang!', AlertType.success);
          } else if (state is DashboardError) {
            _refreshController.refreshFailed();
            _showAlert('Gagal memuat ulang data dashboard.', AlertType.error);
          }
        },
        child: SmartRefresher(
          enablePullDown: true,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: const ViewDashboard(),
        ),
      ),
    );
  }
}