import 'package:flutter/material.dart';
import 'package:gallery_fe/data/models/page_models.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PageDetailDialog extends StatelessWidget {
  final PageModel page;

  const PageDetailDialog({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: AppColors.stoneground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient background
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.shadow,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        page.title,
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: AppColors.stoneground,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.stoneground),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.stoneground.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta information cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            'ID',
                            page.id.toString(),
                            Icons.tag,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            'Slug',
                            page.slug,
                            Icons.link,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: page.isActive
                            ? AppColors.green.withOpacity(0.1)
                            : AppColors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            page.isActive ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: page.isActive ? AppColors.green : AppColors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            page.isActive ? 'Aktif' : 'Non Aktif',
                            style: GoogleFonts.poppins(
                              color: page.isActive ? AppColors.green : AppColors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Content section
                    Text(
                      'Konten',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.stoneground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.slate.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              page.content,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                height: 1.6,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (page.content.length > 100)
                            IconButton(
                              icon: const Icon(
                                Icons.fullscreen,
                                color: AppColors.bark,
                                size: 25,
                              ),
                              onPressed: () => _showFullContent(context),
                              tooltip: 'Tampilkan konten penuh',
                            ),
                        ],
                      ),
                    ),
                    
                    // Timestamps
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Jika lebar kurang dari 400, gunakan layout vertikal
                        if (constraints.maxWidth < 400) {
                          return Column(
                            children: [
                              _buildTimeCard(
                                context,
                                'Dibuat',
                                page.createdAt,
                                Icons.access_time,
                              ),
                              const SizedBox(height: 12),
                              _buildTimeCard(
                                context,
                                'Diperbarui',
                                page.updatedAt,
                                Icons.update,
                              ),
                            ],
                          );
                        }
                        // Jika lebar cukup, gunakan layout horizontal
                        return Row(
                          children: [
                            Expanded(
                              child: _buildTimeCard(
                                context,
                                'Dibuat',
                                page.createdAt,
                                Icons.access_time,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTimeCard(
                                context,
                                'Diperbarui',
                                page.updatedAt,
                                Icons.update,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slate.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.slate.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.doctor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.slate,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.shadow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(
    BuildContext context,
    String label,
    DateTime? dateTime,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slate.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.slate.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.doctor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.slate,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDateTime(dateTime),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.shadow,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  void _showFullContent(BuildContext context) {
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
                          'Content',
                          style: GoogleFonts.poppins(
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.bold,
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
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          page.content,
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
                  // Footer with close button
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
                        backgroundColor: AppColors.bark.withOpacity(0.1),
                      ),
                      child: Text(
                        'Tutup',
                        style: GoogleFonts.poppins(
                          color: AppColors.shadow,
                          fontWeight: FontWeight.w500,
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
}