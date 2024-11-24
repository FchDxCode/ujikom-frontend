import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/bloc/page_bloc/page_bloc.dart';
import 'package:luminova/bloc/page_bloc/page_event.dart';
import 'package:luminova/bloc/page_bloc/page_state.dart';
import 'package:luminova/data/models/page_models.dart';
import 'package:luminova/presentation/widgets/pages/add_pages.dart';
import 'package:luminova/presentation/widgets/pages/delete_pages.dart';
import 'package:luminova/presentation/widgets/pages/edit_pages.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:luminova/presentation/widgets/pages/detail_pages.dart';
import 'package:luminova/presentation/widgets/header_view.dart';

class ViewPages extends StatefulWidget {
  const ViewPages({super.key});

  @override
  _ViewPagesState createState() => _ViewPagesState();
}

class _ViewPagesState extends State<ViewPages> {
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController();

  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _showHeader = true;

  late final PageController _pageController = PageController(
    viewportFraction: 1.0,
    keepPage: true,
  );

  @override
  void initState() {
    super.initState();
    context.read<PageBloc>().add(FetchPages());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Widget _buildHeader(BuildContext context) {
    return HeaderView(
      title: 'Manajemen Halaman',
      onAddContentBlock: () {
        showModal(
          context: context,
          configuration: const FadeScaleTransitionConfiguration(
            barrierDismissible: true,
            transitionDuration: Duration(milliseconds: 300),
            reverseTransitionDuration: Duration(milliseconds: 200),
          ),
          builder: (BuildContext context) => const AddPage(),
        );
      },
      searchController: _searchController,
      searchQuery: _searchController.text,
      onSearchChanged: (value) {
        setState(() {});
      },
      showPageDropdown: false,
    );
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
                child: SizedBox(
                  width: double.infinity,
                  child: _buildHeader(context),
                ),
              ),
              Expanded(
                child: BlocBuilder<PageBloc, PageState>(
                  builder: (context, state) {
                    if (state is PageLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PageLoaded) {
                      final filteredPages = state.pages.where((page) {
                        return page.title
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase());
                      }).toList();
                      return LayoutBuilder(
                        builder: (context, constraints) => Column(
                          children: [
                            Expanded(
                              child: _buildPageGrid(
                                  context, filteredPages, constraints),
                            ),
                          ],
                        ),
                      );
                    } else if (state is PageError) {
                      return Center(child: Text(state.message));
                    } else {
                      return Center(
                          child: Text(
                        'Tidak ada halaman',
                        style: GoogleFonts.leagueSpartan(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate),
                      ));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageGrid(
      BuildContext context, List<PageModel> pages, BoxConstraints constraints) {
    final totalPages = (pages.length / 10).ceil();
    final List<List<PageModel>> pageGroups =
        List.generate(totalPages, (pageIndex) {
      final startIndex = pageIndex * 10;
      final endIndex = (startIndex + 10).clamp(0, pages.length);
      return pages.sublist(startIndex, endIndex);
    });

    return Column(
      children: [
        if (pages.length > 10)
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
              final pagesOnCurrentPage = pageGroups[pageIndex];
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
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: pagesOnCurrentPage.length + 1, // Add 1 for spacer
                  itemBuilder: (context, index) {
                    if (index < pagesOnCurrentPage.length) {
                      final page = pagesOnCurrentPage[index];
                      return RepaintBoundary(
                        child: _buildPageCard(context, page),
                      );
                    } else {
                      // Add spacer for extra scrollable space
                      final remainingHeight = constraints.maxHeight -
                          (pagesOnCurrentPage.length *
                              80); // Approx item height
                      return remainingHeight > 0
                          ? SizedBox(height: remainingHeight)
                          : const SizedBox.shrink();
                    }
                  },
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

  Widget _buildPageCard(BuildContext context, PageModel page) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.stoneground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate
                .withOpacity(0.3), // Adjust the color and opacity
            spreadRadius: 2, // Adjust the spread radius
            blurRadius: 5, // Adjust the blur radius
            offset: const Offset(0, 3), // Adjust the offset
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showPageDetails(context, page),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                // Leading icon atau avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.shadow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      page.title[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.stoneground,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        page.title,
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
                        page.content.length > 50
                            ? '${page.content.substring(0, 50)}...'
                            : page.content,
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

                // Trailing information and action buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Action Buttons
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.bark),
                          onPressed: () => _showEditDialog(context, page),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.red),
                          onPressed: () => _showDeleteDialog(context, page),
                          tooltip: 'Hapus',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: ${page.id}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.slate,
                        fontWeight: FontWeight.w500,
                      ),
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

  void _showPageDetails(BuildContext context, PageModel page) {
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
        return PageDetailDialog(page: page);
      },
    );
  }

  void _showDeleteDialog(BuildContext context, PageModel page) {
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
        return DeletePageDialog(page);
      },
    );
  }

  void _showEditDialog(BuildContext context, PageModel page) {
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
        return EditPage(page: page);
      },
    );
  }
}
