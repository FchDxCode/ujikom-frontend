import 'package:flutter/material.dart';
import 'package:luminova/bloc/contentBlok_bloc/contentblock_bloc.dart';
import 'package:luminova/bloc/contentBlok_bloc/contentblock_event.dart';
import 'package:luminova/bloc/contentBlok_bloc/contentblock_state.dart';
import 'package:luminova/presentation/widgets/alert_custom.dart';
import '../widgets/contentblock/view_contentblock.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageContentblockScreen extends StatefulWidget {
  const ManageContentblockScreen({super.key});

  @override
  _ManageContentblockScreenState createState() => _ManageContentblockScreenState();
}

class _ManageContentblockScreenState extends State<ManageContentblockScreen> {
  final RefreshController _refreshController = RefreshController();
  bool _isShowingAlert = false;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    context.read<ContentBlockBloc>().add(FetchContentBlocks());
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
      body: BlocListener<ContentBlockBloc, ContentBlockState>(
        listener: (context, state) {
          if (state is ContentBlockLoaded) {
            _refreshController.refreshCompleted();
            _showAlert('Data content block berhasil dimuat ulang!', AlertType.success, );
          } else if (state is ContentBlockError) {
            _refreshController.refreshFailed();
            _showAlert('Gagal memuat ulang data content block.', AlertType.error);
          }
        },
        child: SmartRefresher(
          enablePullDown: true,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: const ViewContentBlock(),
        ),
      ),
    );
  }
}
