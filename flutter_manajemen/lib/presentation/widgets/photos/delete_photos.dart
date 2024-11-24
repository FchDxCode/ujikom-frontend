import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/bloc/photo_bloc/photo_bloc.dart';
import 'package:luminova/bloc/photo_bloc/photo_event.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import 'package:luminova/presentation/widgets/alert_custom.dart';
import 'package:google_fonts/google_fonts.dart';

class DeletePhotosModal extends StatelessWidget {
  final int photoId;

  const DeletePhotosModal({super.key, required this.photoId});

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
                    'Hapus Foto',
                    style: GoogleFonts.leagueSpartan(
                      fontWeight: FontWeight.w600,
                      fontSize: 25,
                      color: AppColors.shadow,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Apakah anda yakin ingin menghapus foto ini? Aksi ini tidak dapat dibatalkan.',
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
                            context.read<PhotoBloc>().add(DeletePhoto(photoId));
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
      message: 'Foto berhasil di hapus.',
      duration: const Duration(seconds: 1),
      style: AlertStyle.toast,
    );
  }
}

void showDeleteConfirmationDialog(BuildContext context, int photoId) {
  showDialog(
    context: context,
    builder: (context) {
      return DeletePhotosModal(photoId: photoId);
    },
  );
}
