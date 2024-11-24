import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/category_bloc/category_bloc.dart';
import 'package:gallery_fe/bloc/category_bloc/category_event.dart';
import 'package:gallery_fe/bloc/category_bloc/category_state.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:gallery_fe/presentation/widgets/category/add_category.dart';
import 'package:gallery_fe/presentation/widgets/category/edit_category.dart';
import 'package:gallery_fe/presentation/widgets/category/detail_category.dart';
import 'delete_category.dart';
import 'package:gallery_fe/presentation/widgets/header_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:animations/animations.dart';

class ViewCategory extends StatefulWidget {
  const ViewCategory({super.key});

  @override
  _ViewCategoryState createState() => _ViewCategoryState();
}

class _ViewCategoryState extends State<ViewCategory> {
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 0;
  String _searchQuery = '';
  bool _showHeader = true;

  late final PageController _pageController = PageController(
    viewportFraction: 1.0,
    keepPage: true,
  );

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(FetchCategories());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.marble,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _showHeader ? null : 0,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(),
                  child: HeaderView(
                    title: 'Manajemen Kategori',
                    onAddContentBlock: () {
                      showModal(
                        context: context,
                        configuration: const FadeScaleTransitionConfiguration(
                          barrierDismissible: true,
                          transitionDuration: Duration(milliseconds: 300),
                          reverseTransitionDuration:
                              Duration(milliseconds: 200),
                        ),
                        builder: (BuildContext context) => AddCategory(
                          onCategoryAdded: () {
                            context.read<CategoryBloc>().add(FetchCategories());
                          },
                        ),
                      );
                    },
                    searchController: _searchController,
                    searchQuery: _searchQuery,
                    searchHintText: 'Cari kategori...',
                    onSearchChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    showPageDropdown: false,
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) =>
                      BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoaded) {
                        return _buildCategoryGrid(
                            context, state.categories, constraints);
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<dynamic> categories,
      BoxConstraints constraints) {
    final filteredCategories = _getFilteredCategories(categories);
    final totalPages = (filteredCategories.length / 10).ceil();
    final List<List<dynamic>> pageGroups =
        List.generate(totalPages, (pageIndex) {
      final startIndex = pageIndex * 10;
      final endIndex = (startIndex + 10).clamp(0, filteredCategories.length);
      return filteredCategories.sublist(startIndex, endIndex);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Halaman ${_currentPage + 1} dari $totalPages',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, pageIndex) {
              final categoriesOnCurrentPage = pageGroups[pageIndex];

              final listViewScrollController = ScrollController();

              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    if (notification.metrics.pixels <= 0) {
                      if (!_showHeader) setState(() => _showHeader = true);
                    } else {
                      if (_showHeader) setState(() => _showHeader = false);
                    }
                  }
                  return false;
                },
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                  ),
                  child: ListView.builder(
                    controller: listViewScrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: categoriesOnCurrentPage.length,
                    cacheExtent: 1000,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemBuilder: (context, index) {
                      final category = categoriesOnCurrentPage[index];
                      return RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            return _buildCategoryCard(context, category);
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalPages, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentPage == index ? 12.0 : 8.0,
                  height: _currentPage == index ? 12.0 : 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColors.shadow
                        : AppColors.slate,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  List<dynamic> _getFilteredCategories(List<dynamic> categories) {
    if (_searchQuery.isEmpty) {
      return categories;
    }

    final searchLower = _searchQuery.toLowerCase();
    return categories.where((category) {
      final nameLower = category.name.toLowerCase();
      return nameLower.contains(searchLower);
    }).toList();
  }

  Widget _buildCategoryCard(BuildContext context, dynamic category) {
    return Hero(
      tag: 'category-${category.id}',
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: '',
              transitionDuration: const Duration(milliseconds: 300),
              transitionBuilder: (context, animation, secondaryAnimation, child) {
                return FadeScaleTransition(
                  animation: animation,
                  child: child,
                );
              },
              pageBuilder: (context, animation, secondaryAnimation) {
                return CategoryDetail(category: category);
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.doctor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      category.name.isNotEmpty
                          ? category.name[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.stoneground,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${category.id}',
                        style: GoogleFonts.poppins(
                          color: AppColors.slate,
                          fontSize: 14,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.edit,
                          color: AppColors.bark,
                          onPressed: () => _showEditDialog(context, category),
                          tooltip: 'Edit Kategori',
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.delete,
                          color: AppColors.red,
                          onPressed: () =>
                              _showDeleteConfirmation(context, category),
                          tooltip: 'Hapus Kategori',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 25),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic category) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(
          animation: animation,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditCategoryDialog(category);
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic category) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(
          animation: animation,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return DeleteCategoryDialog(
          categoryName: category.name,
          categoryId: category.id,
          onDeleteConfirmed: () {
            context.read<CategoryBloc>().add(FetchCategories());
          },
        );
      },
    );
  }
}
