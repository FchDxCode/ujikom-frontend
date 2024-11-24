import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/bloc/album_bloc/album_bloc.dart';
import 'package:luminova/bloc/album_bloc/album_event.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import 'package:luminova/presentation/widgets/alert_custom.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteAlbumDialog extends StatelessWidget {
  final String albumTitle;
  final int albumId;
  final VoidCallback onDeleteConfirmed; // Callback for refresh

  const DeleteAlbumDialog({
    super.key,
    required this.albumTitle,
    required this.albumId,
    required this.onDeleteConfirmed, // Initialize the callback
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.stoneground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.slate.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with warning icon
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppColors.red,
                size: 48,
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Hapus Album',
                    style: GoogleFonts.leagueSpartan(
                      fontWeight: FontWeight.w600,
                      fontSize: 25,
                      color: AppColors.shadow,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Apakah Anda yakin ingin menghapus album "$albumTitle"? Aksi ini tidak dapat dibatalkan.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColors.slate,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.shadow,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<AlbumBloc>().add(DeleteAlbum(albumId));
                            onDeleteConfirmed(); // Call the callback to refresh data
                            Navigator.pop(context);
                            showCustomSnackBar(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            foregroundColor: AppColors.stoneground,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Hapus',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
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

  void showCustomSnackBar(BuildContext context) {
    context.showEnhancedModernAlert(
      type: AlertType.success,
      title: 'Berhasil',
      message: 'Album "$albumTitle" berhasil dihapus.',
      duration: const Duration(seconds: 1),
      style: AlertStyle.toast,
    );
  }
}
