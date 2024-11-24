import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/album_bloc/album_bloc.dart';
import 'package:gallery_fe/bloc/album_bloc/album_event.dart';
import 'package:gallery_fe/bloc/photo_bloc/photo_bloc.dart';
import 'package:gallery_fe/bloc/photo_bloc/photo_event.dart';
import 'package:gallery_fe/bloc/photo_bloc/photo_state.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:gallery_fe/presentation/widgets/photos/add_photos.dart';
import 'package:gallery_fe/presentation/widgets/photos/delete_photos.dart';
import 'package:gallery_fe/presentation/widgets/photos/edit_photos.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:gallery_fe/presentation/widgets/header_view.dart';
import 'package:gallery_fe/presentation/widgets/photos/detail_photo.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';

class ViewPhoto extends StatefulWidget {
  const ViewPhoto({super.key});

  @override
  _ViewPhotoState createState() => _ViewPhotoState();
}

class _ViewPhotoState extends State<ViewPhoto> {
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _showHeader = true;
  int? selectedAlbumId;
  String _searchQuery = '';

  late final PageController _pageController = PageController(
    viewportFraction: 1.0,
    keepPage: true,
  );

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
    context.read<PhotoBloc>().add(FetchPhotos());
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
                child: _buildPhotoGrid(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return HeaderView(
      title: 'Manajemen Foto',
      onAddContentBlock: () {
        showModal(
          context: context,
          configuration: const FadeScaleTransitionConfiguration(
            barrierDismissible: true,
            transitionDuration: Duration(milliseconds: 300),
            reverseTransitionDuration: Duration(milliseconds: 200),
          ),
          builder: (context) {
            return AddPhotoDialog(
              onPhotosAdded: () {
                context.read<PhotoBloc>().add(FetchPhotos());
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
      showAlbumDropdown: true,
      selectedAlbumId: selectedAlbumId,
      onAlbumSelected: (value) {
        setState(() {
          selectedAlbumId = value;
        });
        if (value == null) {
          context.read<PhotoBloc>().add(FetchPhotos());
        } else {
          context.read<PhotoBloc>().add(FetchPhotosByAlbum(value));
        }
      },
    );
  }

  Widget _buildPhotoGrid(BuildContext context) {
    return BlocConsumer<PhotoBloc, PhotoState>(
      listener: (context, state) {
        if (state is PhotoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is PhotoLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PhotoLoaded) {
          final filteredPhotos = _getFilteredPhotos(state.photos);
          final totalPages = (filteredPhotos.length / 10).ceil();
          final List<List<dynamic>> photoGroups =
              List.generate(totalPages, (pageIndex) {
            final startIndex = pageIndex * 10;
            final endIndex = (startIndex + 10).clamp(0, filteredPhotos.length);
            return filteredPhotos.sublist(startIndex, endIndex);
          });

          return Column(
            children: [
              if (filteredPhotos.length > 1)
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
                    final photosOnCurrentPage = photoGroups[pageIndex];
                    final gridViewScrollController = ScrollController();
                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification) {
                          if (notification.metrics.pixels <= 0) {
                            if (!_showHeader) {
                              setState(() => _showHeader = true);
                            }
                          } else {
                            if (_showHeader) {
                              setState(() => _showHeader = false);
                            }
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
                        child: GridView.builder(
                          controller: gridViewScrollController,
                          padding: const EdgeInsets.all(24.0),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 350,
                            mainAxisExtent: 350,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                          ),
                          itemCount: photosOnCurrentPage.length,
                          itemBuilder: (context, index) {
                            final photo = photosOnCurrentPage[index];
                            final albumTitle = context
                                    .read<PhotoBloc>()
                                    .albumTitles[photo.album] ??
                                'Unknown Album';
                            return _buildPhotoCard(context, photo, albumTitle);
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
        return Center(
          child: Text(
            'Tidak Ada Foto Tersedia',
            style: GoogleFonts.leagueSpartan(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.slate,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoCard(
      BuildContext context, dynamic photo, String albumTitle) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showPhotoDetails(context, photo, albumTitle),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    photo.photo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, color: Colors.grey);
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      _buildActionButtonWithTooltip(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit Foto',
                        onPressed: () => _showEditPhotoDialog(context, photo),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButtonWithTooltip(
                        icon: Icons.delete_outline,
                        tooltip: 'Hapus Foto',
                        onPressed: () => _confirmDelete(context, photo.id),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 12,
                      vertical: isMobile ? 4 : 6,
                    ),
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
                          Icons.photo_album_outlined,
                          size: isMobile ? 14 : 16,
                          color: AppColors.bark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Album ${photo.album}',
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.title ?? 'Tidak Ada Judul',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    albumTitle,
                    style: GoogleFonts.poppins(
                      color: AppColors.slate,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
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
                        _formatDateTime(photo.uploadedAt),
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
                color: AppColors.bark,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPhotoDetails(
      BuildContext context, dynamic photo, String albumTitle) {
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
        return PhotoDetailDialog(
          photo: photo,
          albumTitle: albumTitle,
        );
      },
    );
  }

  void _showEditPhotoDialog(BuildContext context, dynamic photo) {
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
        return EditPhotoDialog(
          photo: photo,
          onPhotoUpdated: () {
            context.read<PhotoBloc>().add(RefreshPhotos());
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int photoId) {
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
        return DeletePhotosModal(photoId: photoId);
      },
    );
  }
  
  List<dynamic> _getFilteredPhotos(List<dynamic> photos) {
    if (_searchQuery.isEmpty && selectedAlbumId == null) {
      return photos;
    }
    return photos.where((photo) {
      final matchesSearch =
          photo.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesAlbum =
          selectedAlbumId == null || photo.album == selectedAlbumId;
      return matchesSearch && matchesAlbum;
    }).toList();
  }

  

  String _formatDateTime(dynamic dateTime) {
    if (dateTime is String) {
      dateTime = DateTime.parse(dateTime);
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
}
