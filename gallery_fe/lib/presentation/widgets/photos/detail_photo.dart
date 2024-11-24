import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';

class PhotoDetailDialog extends StatelessWidget {
  final dynamic photo;
  final String albumTitle;

  const PhotoDetailDialog({
    super.key,
    required this.photo,
    required this.albumTitle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Dialog(
      backgroundColor: AppColors.stoneground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 900 : size.width * 0.9,
          maxHeight: isDesktop ? 600 : size.height * 0.9,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isDesktop) ...[
                      _buildHeader(),
                      _buildImage(),
                      _buildContent(context),
                    ] else
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildImage(),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(),
                                  _buildContent(context),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                top: 16,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Icon(Icons.close,
                      size: 25, color: AppColors.shadow),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        photo.title ?? 'Detail Foto',
        style: GoogleFonts.leagueSpartan(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 250,
        maxHeight: 400,
      ),
      child: ClipRRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              photo.photo,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: AppColors.red,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.shadow.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  photo.description ?? 'Tidak Ada Deskripsi',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.shadow,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (photo.description != null && photo.description.length > 100)
                IconButton(
                  icon: const Icon(Icons.fullscreen,
                      size: 25, color: AppColors.shadow),
                  onPressed: () => _showFullDescription(context),
                  tooltip: 'Tampilkan Deskripsi Lengkap',
                ),
            ],
          ),
          const SizedBox(height: 24),
          ..._buildDetailItem('ID', photo.id.toString()),
          ..._buildDetailItem('Album', albumTitle),
          ..._buildDetailItem(
              'Dibuat Oleh', photo.uploadedBy ?? 'Tidak Diketahui'),
          ..._buildDetailItem('Dibuat Pada', _formatDateTime(photo.uploadedAt)),
          ..._buildDetailItem('Likes', '${photo.likes}'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showFullDescription(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 600 : size.width * 0.9,
              maxHeight: isDesktop ? size.height * 0.8 : size.height * 0.9,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Deskripsi',
                          style: GoogleFonts.poppins(
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.slate.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          photo.description ?? 'Tidak Ada Deskripsi',
                          style: GoogleFonts.poppins(
                            fontSize: isDesktop ? 16 : 14,
                            height: 1.6,
                            color: AppColors.shadow,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: AppColors.shadow.withOpacity(0.1),
                      ),
                      child: Text(
                        'Tutup',
                        style: GoogleFonts.poppins(
                          color: AppColors.shadow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDetailItem(String label, String value) {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.shadow,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.shadow,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
    ];
  }

  String _formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
}
