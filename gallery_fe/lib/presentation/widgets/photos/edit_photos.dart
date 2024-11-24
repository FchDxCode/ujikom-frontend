import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/photo_bloc/photo_bloc.dart';
import 'package:gallery_fe/bloc/photo_bloc/photo_event.dart';
import 'package:gallery_fe/data/models/photo_models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_fe/bloc/album_bloc/album_bloc.dart';
import 'package:gallery_fe/bloc/album_bloc/album_event.dart';
import 'package:gallery_fe/bloc/album_bloc/album_state.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditPhotoDialog extends StatefulWidget {
  final Photo photo;
  final VoidCallback onPhotoUpdated;

  const EditPhotoDialog(
      {super.key, required this.photo, required this.onPhotoUpdated});

  @override
  _EditPhotoDialogState createState() => _EditPhotoDialogState();
}

class _EditPhotoDialogState extends State<EditPhotoDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  XFile? newImageFile;
  int? selectedAlbumId;
  bool _isLoading = false;
  Uint8List? newImageBytes;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.photo.title);
    descriptionController =
        TextEditingController(text: widget.photo.description);
    selectedAlbumId = widget.photo.album;
    context.read<AlbumBloc>().add(FetchAlbums());
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickNewImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Baca bytes untuk preview
        final bytes = await pickedFile.readAsBytes();
        
        // Validasi ukuran file
        if (bytes.length > 10 * 1024 * 1024) { // 5MB limit
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File terlalu besar. Maksimal 10MB.')),
            );
          }
          return;
        }
        
        // Validasi tipe file
        final extension = pickedFile.name.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png'].contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File harus berformat JPG atau PNG.')),
            );
          }
          return;
        }

        setState(() {
          newImageFile = pickedFile;
          newImageBytes = bytes;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memilih gambar. Silakan coba lagi.')),
        );
      }
    }
  }

  Widget _buildAlbumDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Album',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.shadow,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<AlbumBloc, AlbumState>(
          builder: (context, state) {
            if (state is AlbumLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is AlbumLoaded) {
              final albums = state.albums;

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.slate),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<int>(
                  value: selectedAlbumId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.album, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    hintText: 'Pilih Album',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.slate,
                    ),
                  ),
                  items: albums.map((album) {
                    return DropdownMenuItem<int>(
                      value: album.id,
                      child: Text(
                        album.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAlbumId = value;
                    });
                  },
                  isExpanded: true,
                  menuMaxHeight: 200,
                  icon: const Padding(
                    padding: EdgeInsets.only(top: 8),
                  ),
                  iconEnabledColor: AppColors.slate,
                  dropdownColor: AppColors.stoneground,
                ),
              );
            }

            if (state is AlbumError) {
              return Text(
                'Gagal memuat album: ${state.message}',
                style: GoogleFonts.poppins(color: AppColors.red),
              );
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.stoneground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.slate.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Foto',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.shadow,
              ),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        controller: titleController,
                        label: 'Judul',
                        prefixIcon: Icons.title,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: descriptionController,
                        label: 'Deskripsi',
                        prefixIcon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildAlbumDropdown(),
                      const SizedBox(height: 16),
                      _buildImageUploadSection(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.shadow,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.slate,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.slate,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.doctor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.stoneground,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gambar',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.shadow,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickNewImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.slate),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImagePreview(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (newImageBytes != null) {
      return Image.memory(
        newImageBytes!,
        fit: BoxFit.cover,
      );
    } else if (newImageFile != null && !kIsWeb) {
      return Image.file(
        File(newImageFile!.path),
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        widget.photo.photo,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.error_outline,
              color: AppColors.red,
              size: 40,
            ),
          );
        },
      );
    }
  }

  void _handleSubmit() {
    if (selectedAlbumId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih album')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final updatedPhoto = Photo(
      id: widget.photo.id,
      title: titleController.text.isEmpty ? null : titleController.text,
      description: descriptionController.text.isEmpty ? null : descriptionController.text,
      photo: widget.photo.photo,
      album: selectedAlbumId!,
      uploadedAt: widget.photo.uploadedAt,
      uploadedBy: widget.photo.uploadedBy,
      sequenceNumber: widget.photo.sequenceNumber,
    );

    final photoBloc = context.read<PhotoBloc>();
    photoBloc.add(UpdatePhoto(updatedPhoto, imageFile: newImageFile));
    Navigator.of(context).pop();

    Future.delayed(const Duration(milliseconds: 500), () {
      photoBloc.add(RefreshPhotos());
      setState(() => _isLoading = false);
    });
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Batal",
            style: GoogleFonts.poppins(
              color: AppColors.shadow,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: AppColors.shadow,
            foregroundColor: AppColors.stoneground,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.stoneground),
                  ),
                )
              : Text(
                  "Simpan",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.stoneground,
                  ),
                ),
        ),
      ],
    );
  }
}
