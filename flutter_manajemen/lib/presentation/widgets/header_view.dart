import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/bloc/page_bloc/page_bloc.dart';
import 'package:luminova/bloc/page_bloc/page_state.dart';
import 'package:luminova/bloc/category_bloc/category_bloc.dart';
import 'package:luminova/bloc/category_bloc/category_state.dart';
import 'package:luminova/bloc/album_bloc/album_bloc.dart';
import 'package:luminova/bloc/album_bloc/album_state.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderView extends StatelessWidget {
  final String title;
  final VoidCallback onAddContentBlock;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final String searchHintText;
  final bool showAddButton;
  final bool showSearchBar;

  //page
  final int? selectedPageId;
  final Function(int?)? onPageSelected;
  final bool showPageDropdown;

  //category
  final bool showCategoryDropdown;
  final int? selectedCategoryId;
  final Function(int?)? onCategorySelected;

  //album
  final bool showAlbumDropdown;
  final int? selectedAlbumId;
  final Function(int?)? onAlbumSelected;

  const HeaderView({
    super.key,
    required this.title,
    required this.onAddContentBlock,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    this.searchHintText = 'Cari...',
    this.showAddButton = true,
    this.showSearchBar = true,
    this.selectedPageId,
    this.onPageSelected,
    this.showPageDropdown = false,
    this.showCategoryDropdown = false,
    this.selectedCategoryId,
    this.onCategorySelected,
    this.showAlbumDropdown = false,
    this.selectedAlbumId,
    this.onAlbumSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildMobileHeader(context);
          } else {
            return _buildDesktopHeader(context);
          }
        },
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        color: AppColors.shadow,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border:const Border(
          bottom: BorderSide(
            color: AppColors.slate,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: AppColors.stoneground,
                  ),
                ),
              ),
              IconButton(
                onPressed: onAddContentBlock,
                icon: const Icon(Icons.add_box_rounded),
                color: AppColors.stoneground,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
          if (showCategoryDropdown) ...[
            const SizedBox(height: 10),
            _buildCategoryDropdown(context),
          ],
          if (showPageDropdown) ...[
            const SizedBox(height: 10),
            _buildPageDropdown(context),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.shadow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: const Border(
          bottom: BorderSide(
            color: AppColors.slate,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.stoneground,
                  ),
                ),
              ),
              _buildAddContentBlockButton(context),
            ],
          ),
          const SizedBox(height: 24),
          _buildSearchAndFilterRow(context),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildSearchBar(),
        ),
        if (showCategoryDropdown) ...[
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _buildCategoryDropdown(context),
          ),
        ],
        if (showAlbumDropdown) ...[
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _buildAlbumDropdown(context),
          ),
        ],
        if (showPageDropdown) ...[
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _buildPageDropdown(context),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchBar() {
    if (!showSearchBar) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(
        minHeight: 48,
        maxHeight: 56,
      ),
      decoration: BoxDecoration(
        color: AppColors.stoneground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.slate,
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: searchHintText,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.slate,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.slate,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: AppColors.slate,
                  ),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: AppColors.shadow,
        ),
      ),
    );
  }

  Widget _buildPageDropdown(BuildContext context) {
    return BlocBuilder<PageBloc, PageState>(
      builder: (context, state) {
        if (state is PageLoaded) {
          return Container(
            constraints: const BoxConstraints(
              minHeight: 48,
              maxHeight: 56,
            ),
            decoration: BoxDecoration(
              color: AppColors.stoneground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.slate,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                isExpanded: true,
                hint: Text(
                  'Pilih Halaman',
                  style: GoogleFonts.poppins(
                    color: AppColors.slate,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                value: selectedPageId,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.slate),
                style: GoogleFonts.poppins(
                  color: AppColors.slate,
                  fontSize: 14,
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'Semua Halaman',
                      style: GoogleFonts.poppins(
                        color: AppColors.shadow,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ...state.pages.map((page) {
                    final displayTitle = page.title.length > 20
                        ? '${page.title.substring(0, 20)}...'
                        : page.title;
                    return DropdownMenuItem<int?>(
                      value: page.id,
                      child: Text(
                        displayTitle,
                        style: GoogleFonts.poppins(
                          color: AppColors.shadow,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: onPageSelected,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoaded) {
          return Container(
            constraints: const BoxConstraints(
              minHeight: 48,
              maxHeight: 56,
            ),
            decoration: BoxDecoration(
              color: AppColors.stoneground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.slate,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                isExpanded: true,
                hint: Text(
                  'Pilih Kategori',
                  style: GoogleFonts.poppins(
                    color: AppColors.slate,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                value: selectedCategoryId,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.slate),
                style: GoogleFonts.poppins(
                  color: AppColors.slate,
                  fontSize: 14,
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'Semua Kategori',
                      style: GoogleFonts.poppins(
                        color: AppColors.shadow,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ...state.categories.map((category) {
                    return DropdownMenuItem<int?>(
                      value: category.id,
                      child: Text(
                        category.name,
                        style: GoogleFonts.poppins(
                          color: AppColors.shadow,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: onCategorySelected,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAlbumDropdown(BuildContext context) {
    return BlocBuilder<AlbumBloc, AlbumState>(
      builder: (context, state) {
        if (state is AlbumLoaded) {
          return Container(
            constraints: const BoxConstraints(
              minHeight: 48,
              maxHeight: 56,
            ),
            decoration: BoxDecoration(
              color: AppColors.stoneground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.slate,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                isExpanded: true,
                hint: Text(
                  'Pilih Album',
                  style: GoogleFonts.poppins(
                    color: AppColors.slate,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                value: selectedAlbumId,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.slate),
                style: GoogleFonts.poppins(
                  color: AppColors.slate,
                  fontSize: 14,
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'Semua Album',
                      style: GoogleFonts.poppins(
                        color: AppColors.shadow,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ...state.albums.map((album) {
                    return DropdownMenuItem<int?>(
                      value: album.id,
                      child: Text(
                        album.title,
                        style: GoogleFonts.poppins(
                          color: AppColors.shadow,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: onAlbumSelected,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAddContentBlockButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onAddContentBlock,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor: AppColors.stoneground,
        foregroundColor: AppColors.shadow,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.bark.withOpacity(0.2);
            }
            return null;
          },
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.add_box_outlined,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Tambah',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
