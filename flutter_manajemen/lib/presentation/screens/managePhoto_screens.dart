import 'package:flutter/material.dart';
import 'package:luminova/bloc/photo_bloc/photo_bloc.dart';
import 'package:luminova/bloc/photo_bloc/photo_event.dart';
import 'package:luminova/bloc/photo_bloc/photo_state.dart';
import 'package:luminova/presentation/widgets/photos/view_photos.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:luminova/presentation/widgets/alert_custom.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagePhotoScreen extends StatefulWidget {
  const ManagePhotoScreen({super.key});

  @override
  _ManagePhotoScreenState createState() => _ManagePhotoScreenState();
}

class _ManagePhotoScreenState extends State<ManagePhotoScreen> {
  final RefreshController _refreshController = RefreshController();
  bool _isShowingAlert = false;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    context.read<PhotoBloc>().add(FetchPhotos());
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
      body: BlocListener<PhotoBloc, PhotoState>(
        listener: (context, state) {
          if (state is PhotoLoaded) {
            _refreshController.refreshCompleted();
            _showAlert('Data foto berhasil dimuat ulang!', AlertType.success);
          } else if (state is PhotoError) {
            _refreshController.refreshFailed();
            _showAlert('Gagal memuat ulang data foto.', AlertType.error);
          }
        },
        child: SmartRefresher(
          enablePullDown: true,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: const ViewPhoto(),
        ),
      ),
    );
  }
}
