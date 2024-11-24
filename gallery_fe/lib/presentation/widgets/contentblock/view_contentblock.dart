import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/contentBlok_bloc/contentblock_bloc.dart';
import 'package:gallery_fe/bloc/contentBlok_bloc/contentblock_event.dart';
import 'package:gallery_fe/bloc/contentBlok_bloc/contentblock_state.dart';
import 'package:gallery_fe/bloc/page_bloc/page_bloc.dart';
import 'package:gallery_fe/bloc/page_bloc/page_state.dart';
import 'package:gallery_fe/data/models/contentblock_models.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:gallery_fe/presentation/widgets/contentblock/add_contentblock.dart';
import 'package:gallery_fe/presentation/widgets/contentblock/delete_contentblock.dart';
import 'package:gallery_fe/presentation/widgets/contentblock/detail_contentblock.dart';
import 'package:gallery_fe/presentation/widgets/contentblock/edit_contentblock.dart';
import 'package:gallery_fe/presentation/widgets/header_view.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

class ViewContentBlock extends StatefulWidget {
  const ViewContentBlock({super.key});

  @override
  _ViewContentBlockState createState() => _ViewContentBlockState();
}

class _ViewContentBlockState extends State<ViewContentBlock> {
  int? selectedPageId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final bool _showHeader = true;

  // Variabel untuk Pagination
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  late final PageController _pageControllerPagination = PageController(
    viewportFraction: 1.0,
    keepPage: true,
  );

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageControllerPagination.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    // Initialize BLoC
    context.read<ContentBlockBloc>().add(FetchContentBlocks());
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _onPageSelected(int? value) {
    setState(() {
      selectedPageId = value;
    });
    if (value == null) {
      context.read<ContentBlockBloc>().add(FetchContentBlocks());
    } else {
      context.read<ContentBlockBloc>().add(FetchContentBlocksByPage(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _showHeader ? null : 0,
            child: HeaderView(
              title: 'Konten Blok',
              onAddContentBlock: () {
                showModal(
                  context: context,
                  configuration: const FadeScaleTransitionConfiguration(
                    barrierDismissible: true,
                    transitionDuration: Duration(milliseconds: 300),
                    reverseTransitionDuration: Duration(milliseconds: 200),
                  ),
                  builder: (BuildContext context) => const AddContentBlock(),
                );
              },
              searchController: _searchController,
              searchQuery: _searchQuery,
              selectedPageId: selectedPageId,
              onSearchChanged: _onSearchChanged,
              onPageSelected: _onPageSelected,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildContentBlockGrid(context, constraints);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBlockGrid(
      BuildContext context, BoxConstraints constraints) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return BlocConsumer<ContentBlockBloc, ContentBlockState>(
      listener: (context, state) {
        if (state is ContentBlockError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        if (state is ContentBlockLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ContentBlockLoaded) {
          final contentBlocks = state.contentBlocks;
          final filteredBlocks = _getFilteredContentBlocks(contentBlocks);
          final totalPages = (filteredBlocks.length / _itemsPerPage).ceil();
          final List<List<ContentBlockModel>> pageGroups =
              List.generate(totalPages, (pageIndex) {
            final startIndex = pageIndex * _itemsPerPage;
            final endIndex =
                (startIndex + _itemsPerPage).clamp(0, filteredBlocks.length);
            return filteredBlocks.sublist(startIndex, endIndex);
          });

          return Column(
            children: [
              if (filteredBlocks.length > 1)
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
                  controller: _pageControllerPagination,
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
                    final blocksOnCurrentPage = pageGroups[pageIndex];
                    return ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(24.0),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 350,
                          mainAxisExtent: isMobile ? 320 : 350,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                        itemCount: blocksOnCurrentPage.length,
                        itemBuilder: (context, index) {
                          final contentBlock = blocksOnCurrentPage[index];
                          return _buildContentBlockCard(context, contentBlock);
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
        return Center(
            child: Text(
          'Tidak ada content block yang tersedia.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.slate,
          ),
        ));
      },
    );
  }

  Widget _buildContentBlockCard(
      BuildContext context, ContentBlockModel contentBlock) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 900;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showContentBlockDetails(context, contentBlock),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  child: contentBlock.image.isNotEmpty
                      ? Image.network(
                          contentBlock.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, color: AppColors.red);
                          },
                        )
                      : const Icon(Icons.image_not_supported, color: AppColors.slate),
                ),

                // Action Buttons
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      _buildActionButtonWithTooltip(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit Content Block',
                        onPressed: () => _showEditDialog(context, contentBlock),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButtonWithTooltip(
                        icon: Icons.delete_outline,
                        tooltip: 'Hapus Content Block',
                        onPressed: () => _showDeleteConfirmationDialog(
                            context, contentBlock),
                      ),
                    ],
                  ),
                ),

                // Page Badge
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 12,
                        vertical: isMobile ? 4 : 6),
                    decoration: BoxDecoration(
                      color: AppColors.stoneground.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.bark.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bookmark_outlined,
                          size: isMobile ? 14 : 16,
                          color: AppColors.bark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Page ${contentBlock.page}',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 12 : 13,
                            color: AppColors.shadow,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Prevent overflow
                children: [
                  // Title
                  Text(
                    contentBlock.title,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 14 : (isTablet ? 16 : 18),
                      fontWeight: FontWeight.w500,
                      color: AppColors.shadow,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Page Description
                  BlocBuilder<PageBloc, PageState>(
                    builder: (context, state) {
                      final pageTitle = state is PageLoaded
                          ? state.pages
                                  .where((p) => p.id == contentBlock.page)
                                  .map((p) => p.title)
                                  .firstOrNull ??
                              'Page: ${contentBlock.page}'
                          : 'Page: ${contentBlock.page}';

                      return Text(
                        pageTitle,
                        style: GoogleFonts.poppins(
                          color: AppColors.slate,
                          fontSize: isMobile ? 12 : 13,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: isMobile ? 12 : 14,
                        color: AppColors.slate,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(contentBlock.updated_at),
                        style: GoogleFonts.poppins(
                          color: AppColors.slate,
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk action button
  Widget _buildActionButtonWithTooltip({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.stoneground.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.bark.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                color: AppColors.shadow,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showContentBlockDetails(
      BuildContext context, ContentBlockModel contentBlock) {
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
        return ContentBlockDetailDialog(contentBlock: contentBlock);
      },
    );
  }

  void _showEditDialog(BuildContext context, dynamic contentBlock) {
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
        return EditContentBlock(contentBlock: contentBlock);
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, dynamic contentBlock) {
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
        return DeleteContentBlockDialog(
          contentBlockId: contentBlock.id,
          contentBlockTitle: contentBlock.title,
        );
      },
    );
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '-';
    
    try {
      if (dateTime is String) {
        dateTime = DateTime.parse(dateTime);
      }
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  List<ContentBlockModel> _getFilteredContentBlocks(
      List<ContentBlockModel> contentBlocks) {
    if (_searchQuery.isEmpty) {
      return contentBlocks;
    } else {
      return contentBlocks
          .where((contentBlock) =>
              contentBlock.title
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              contentBlock.description!
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }
}
