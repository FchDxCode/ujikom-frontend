import 'package:flutter/material.dart';
import 'package:gallery_fe/presentation/widgets/alert_custom.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/category_bloc/category_bloc.dart';
import 'package:gallery_fe/bloc/category_bloc/category_event.dart';
import 'package:gallery_fe/bloc/category_bloc/category_state.dart';
import '../widgets/category/view_category.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class ManageCategoryScreens extends StatefulWidget {
  const ManageCategoryScreens({super.key});

  @override
  _ManageCategoryScreensState createState() => _ManageCategoryScreensState();
}

class _ManageCategoryScreensState extends State<ManageCategoryScreens> {
  final RefreshController _refreshController = RefreshController();
  bool _isShowingAlert = false;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    context.read<CategoryBloc>().add(FetchCategories());
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
      body: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryLoaded) {
            _refreshController.refreshCompleted();
            _showAlert('Data kategori berhasil dimuat ulang!', AlertType.success);
          } else if (state is CategoryError) {
            _refreshController.refreshFailed();
            _showAlert('Gagal memuat ulang data kategori.', AlertType.error);
          }
        },
        child: SmartRefresher(
          enablePullDown: true,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: const ViewCategory(),
        ),
      ),
    );
  }
}
