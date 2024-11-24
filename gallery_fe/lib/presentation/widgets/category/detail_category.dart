import 'package:flutter/material.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryDetail extends StatelessWidget {
  final dynamic category;

  const CategoryDetail({super.key, required this.category});

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
                  color: AppColors.doctor,
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
                        category.name,
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
                            category.id.toString(),
                            Icons.tag,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            'Urutan',
                            category.sequenceNumber.toString(),
                            Icons.sort,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Content section
                    _buildContent(context),
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

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Create TextSpan to measure if text is truncated
                    final textSpan = TextSpan(
                      text: category.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.6,
                      ),
                    );
                    final textPainter = TextPainter(
                      text: textSpan,
                      maxLines: 3,
                      textDirection: TextDirection.ltr,
                    );
                    textPainter.layout(maxWidth: constraints.maxWidth);

                    // Show icon if text is truncated
                    final isTextTruncated = textPainter.didExceedMaxLines;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            category.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              height: 1.6,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isTextTruncated)
                          IconButton(
                            icon: const Icon(
                              Icons.fullscreen,
                              color: AppColors.bark,
                              size: 28,
                            ),
                            onPressed: () => _showFullContent(context),
                            tooltip: 'Tampilkan deskripsi penuh',
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Deskripsi',
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
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          category.description,
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