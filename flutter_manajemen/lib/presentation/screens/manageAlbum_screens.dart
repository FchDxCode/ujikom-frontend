import 'package:flutter/material.dart';
import 'package:luminova/bloc/album_bloc/album_bloc.dart';
import 'package:luminova/bloc/album_bloc/album_event.dart';
import 'package:luminova/bloc/album_bloc/album_state.dart';
import '../widgets/album/view_album.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:luminova/presentation/widgets/alert_custom.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageAlbumScreens extends StatefulWidget {
  const ManageAlbumScreens({super.key});

  @override
  _ManageAlbumScreensState createState() => _ManageAlbumScreensState();
}

class _ManageAlbumScreensState extends State<ManageAlbumScreens> {
  final RefreshController _refreshController = RefreshController();
  bool _isShowingAlert = false;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    context.read<AlbumBloc>().add(FetchAlbums());
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
      body: BlocListener<AlbumBloc, AlbumState>(
        listener: (context, state) {
          if (state is AlbumLoaded) {
            _refreshController.refreshCompleted();
            _showAlert('Data album berhasil dimuat ulang!', AlertType.success);
          } else if (state is AlbumError) {
            _refreshController.refreshFailed();
            _showAlert('Gagal memuat ulang data album.', AlertType.error);
          }
        },
        child: SmartRefresher(
          enablePullDown: true,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: const ViewAlbum(),
        ),
      ),
    );
  }
}
