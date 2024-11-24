import 'package:flutter/material.dart';
import 'package:gallery_fe/bloc/page_bloc/page_bloc.dart';
import 'package:gallery_fe/bloc/page_bloc/page_event.dart';
import 'package:gallery_fe/bloc/page_bloc/page_state.dart';
import 'package:gallery_fe/presentation/widgets/pages/view_pages.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:gallery_fe/presentation/widgets/alert_custom.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagePagesScreen extends StatefulWidget {
  const ManagePagesScreen({super.key});
  
  @override
  _ManagePagesScreenState createState() => _ManagePagesScreenState();
}

class _ManagePagesScreenState extends State<ManagePagesScreen> {
  final RefreshController _refreshController = RefreshController();
  bool _isShowingAlert = false;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    context.read<PageBloc>().add(FetchPages());
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
      body: BlocListener<PageBloc, PageState>(
        listener: (context, state) {
          if (state is PageLoaded) {
            _refreshController.refreshCompleted();
            _showAlert('Data halaman berhasil dimuat ulang!', AlertType.success);
          } else if (state is PageError) {
            _refreshController.refreshFailed();
            _showAlert('Gagal memuat ulang data halaman.', AlertType.error);
          }
        },
        child: SmartRefresher(
          enablePullDown: true,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: const ViewPages(),
        ),
      ),
    );
  }
}
