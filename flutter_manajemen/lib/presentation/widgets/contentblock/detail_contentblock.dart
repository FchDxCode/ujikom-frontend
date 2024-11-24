import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/bloc/page_bloc/page_bloc.dart';
import 'package:luminova/bloc/page_bloc/page_state.dart';
import 'package:luminova/data/models/contentblock_models.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ContentBlockDetailDialog extends StatelessWidget {
  final ContentBlockModel contentBlock;

  const ContentBlockDetailDialog({super.key, required this.contentBlock});

  String _formatDateTime(dynamic dateTime) {
    if (dateTime is String) {
      dateTime = DateTime.parse(dateTime);
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

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
              // Content
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
              // Close button 1 positioned at the top
              Positioned(
                right: 16,
                top: 16,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Icon(Icons.close, size: 30, color: AppColors.shadow),
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
        contentBlock.title,
        style: GoogleFonts.leagueSpartan(
          fontSize: 25,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
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
              contentBlock.image,
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
                  contentBlock.description ?? 'Tidak ada deskripsi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    height: 1.6,
                    color: AppColors.shadow,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (contentBlock.description != null &&
                  contentBlock.description!.length > 150)
                IconButton(
                  icon: const Icon(Icons.fullscreen, size: 28, color: AppColors.bark),
                  onPressed: () => _showFullDescription(context),
                  tooltip: 'Tampilkan deskripsi penuh',
                ),
            ],
          ),
          const SizedBox(height: 24),

          BlocBuilder<PageBloc, PageState>(
            builder: (context, state) {
              if (state is PageLoaded) {
                final pageTitle = state.pages
                        .where((p) => p.id == contentBlock.page)
                        .map((p) => p.title)
                        .firstOrNull ?? 
                    'Halaman Tidak Diketahui';

                return Column(
                  children: [
                    ..._buildDetailItem('Halaman', pageTitle),
                    ..._buildDetailItem('ID Halaman', contentBlock.page.toString()),
                  ],
                );
              }
              return Column(
                children: [
                  ..._buildDetailItem('ID Halaman', contentBlock.page.toString()),
                ],
              );
            },
          ),
          ..._buildDetailItem('Dibuat oleh', contentBlock.created_by ?? 'Tidak diketahui'),
          ..._buildDetailItem('Nomor Urut', contentBlock.sequence_number.toString()),
          ..._buildDetailItem('Terakhir Diperbarui', _formatDateTime(contentBlock.updated_at)),
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
                            color: AppColors.shadow.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Divider
                  const Divider(),
                  const SizedBox(height: 16),
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          contentBlock.description ?? 'Tidak ada deskripsi',
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
}
