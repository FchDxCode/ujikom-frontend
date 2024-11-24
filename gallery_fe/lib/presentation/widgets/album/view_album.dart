import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/album_bloc/album_bloc.dart';
import 'package:gallery_fe/bloc/album_bloc/album_event.dart';
import 'package:gallery_fe/bloc/album_bloc/album_state.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:gallery_fe/presentation/widgets/album/add_album.dart';
import 'package:gallery_fe/presentation/widgets/album/edit_album.dart';
import 'delete_album.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:gallery_fe/presentation/widgets/header_view.dart';
import 'package:gallery_fe/presentation/widgets/album/detail_album.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ViewAlbum extends StatefulWidget {
  const ViewAlbum({super.key});

  @override
  _ViewAlbumState createState() => _ViewAlbumState();
}

class _ViewAlbumState extends State<ViewAlbum> {
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _showHeader = true;
  late final PageController _pageController = PageController(
    viewportFraction: 1.0,
    keepPage: true,
  );
  int? selectedCategoryId;
  String _searchQuery = '';
  final int _itemsPerPage = 10;

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<AlbumBloc>().add(FetchAlbums());
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
                child: BlocBuilder<AlbumBloc, AlbumState>(
                  builder: (context, state) {
                    if (state is AlbumLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AlbumLoaded) {
                      final filteredAlbums = state.albums.where((album) {
                        return album.title
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase());
                      }).toList();
                      return _buildAlbumGrid(context, filteredAlbums);
                    } else if (state is AlbumError) {
                      return Center(child: Text(state.message));
                    }
                    return Center(
                      child: Text(
                        'Tidak ada album tersedia',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return HeaderView(
      title: 'Manajemen Album',
      onAddContentBlock: () {
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
            return AddAlbumDialog(
              onAlbumAdded: () {
                context.read<AlbumBloc>().add(FetchAlbums());
              },
            );
          },
        );
      },
      searchController: _searchController,
      searchQuery: _searchQuery,
      onSearchChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      showPageDropdown: false,
      showCategoryDropdown: true,
      selectedCategoryId: selectedCategoryId,
      onCategorySelected: (value) {
        setState(() {
          selectedCategoryId = value;
        });
      },
    );
  }

  Widget _buildAlbumGrid(BuildContext context, List<dynamic> albums) {
    final filteredAlbums = _getFilteredAlbums(albums);
    final totalPages = (filteredAlbums.length / _itemsPerPage).ceil();
    final List<List<dynamic>> albumGroups = List.generate(totalPages, (pageIndex) {
      final startIndex = pageIndex * _itemsPerPage;
      final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredAlbums.length);
      return filteredAlbums.sublist(startIndex, endIndex);
    });

    return Column(
      children: [
        if (albums.length > 1)
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
              final albumsOnCurrentPage = albumGroups[pageIndex];
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
                    itemCount: albumsOnCurrentPage.length,
                    cacheExtent: 1000,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemBuilder: (context, index) {
                      final album = albumsOnCurrentPage[index];
                      return RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            return _buildAlbumCard(context, album);
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

  Widget _buildAlbumCard(BuildContext context, dynamic album) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.stoneground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showAlbumDetails(context, album),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.shadow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: album.coverPhotoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: album.coverPhotoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.slate,
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              print('Error loading image: $error');
                              return Center(
                                child: Text(
                                  album.title.isNotEmpty 
                                      ? album.title[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.shadow,
                                  ),
                                ),
                              );
                            },
                            memCacheWidth: 96,
                            memCacheHeight: 96,
                            httpHeaders: const {
                              'Cache-Control': 'max-age=3600',
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            album.title.isNotEmpty 
                                ? album.title[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.poppins(
                              fontSize: 25,
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
                        album.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.shadow,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kategori ${album.category ?? "Tidak Dikategorikan"}',
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
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.bark),
                          onPressed: () => _showEditDialog(context, album),
                          tooltip: 'Edit Album',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.red),
                          onPressed: () => _showDeleteDialog(context, album),
                          tooltip: 'Hapus Album',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: ${album.id}',
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

  void _showAlbumDetails(BuildContext context, dynamic album) {
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
        return AlbumDetailDialog(album: album);
      },
    );
  }

  void _showEditDialog(BuildContext context, dynamic album) {
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
        return EditAlbumModal(album: album);
      },
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic album) {
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
        return DeleteAlbumDialog(
          albumTitle: album.title ?? 'Album Tidak Diberi Judul',
          albumId: album.id,
          onDeleteConfirmed: () {
            context.read<AlbumBloc>().add(FetchAlbums());
          },
        );
      },
    );
  }

  List<dynamic> _getFilteredAlbums(List<dynamic> albums) {
    return albums.where((album) {
      final matchesSearch = album.title
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesCategory = selectedCategoryId == null || 
          album.category == selectedCategoryId;
      return matchesSearch && matchesCategory;
    }).toList();
  }
}
