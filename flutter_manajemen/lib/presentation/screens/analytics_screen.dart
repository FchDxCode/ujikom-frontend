// lib/presentation/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../widgets/analytics/view_analytics.dart';
import '../widgets/alert_custom.dart';
import '../../bloc/analytics_bloc/analytics_bloc.dart';
import '../../bloc/analytics_bloc/analytics_event.dart';
import '../../bloc/analytics_bloc/analytics_state.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final RefreshController _refreshController = RefreshController();
  bool _isShowingAlert = false;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    context.read<AnalyticsBloc>().add(RefreshAnalyticsStats());
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
    context.read<AnalyticsBloc>().add(FetchAnalyticsStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AnalyticsBloc, AnalyticsState>(
        listener: (context, state) {
          if (state is AnalyticsLoaded) {
            _refreshController.refreshCompleted();
            _showAlert('Data analytics berhasil dimuat ulang!', AlertType.success);
          } else if (state is AnalyticsError) {
            _refreshController.refreshFailed();
            _showAlert('Gagal memuat ulang data analytics.', AlertType.error);
          }
        },
        child: SmartRefresher(
          enablePullDown: true,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: const ViewAnalytics(),
        ),
      ),
    );
  }
}