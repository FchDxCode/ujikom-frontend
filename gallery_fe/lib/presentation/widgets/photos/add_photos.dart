import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/photo_bloc/photo_bloc.dart';
import 'package:gallery_fe/bloc/photo_bloc/photo_event.dart';
import 'package:gallery_fe/data/models/photo_models.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:gallery_fe/presentation/widgets/alert_custom.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_fe/bloc/album_bloc/album_bloc.dart';
import 'package:gallery_fe/bloc/album_bloc/album_event.dart';
import 'package:gallery_fe/bloc/album_bloc/album_state.dart';

class SelectedImage {
  final XFile xfile;
  final Uint8List bytes;

  SelectedImage({required this.xfile, required this.bytes});
}

class AddPhotoDialog extends StatefulWidget {
  final VoidCallback onPhotosAdded;

  const AddPhotoDialog({super.key, required this.onPhotosAdded});

  @override
  _AddPhotoDialogState createState() => _AddPhotoDialogState();
}

class _AddPhotoDialogState extends State<AddPhotoDialog> {
  final _formKey = GlobalKey<FormState>();
  List<SelectedImage> _selectedImages = [];
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final albumIdController = TextEditingController();
  bool _isLoading = false;
  int? selectedAlbumId;

  @override
  void initState() {
    super.initState();
    context.read<AlbumBloc>().add(FetchAlbums());
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    try {
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        List<SelectedImage> newImages = [];
        for (var xfile in pickedFiles) {
          // Baca bytes untuk preview
          Uint8List bytes = await xfile.readAsBytes();
          
          // Validasi ukuran file (opsional)
          if (bytes.length > 10 * 1024 * 1024) { // 5MB limit
            context.showEnhancedModernAlert(
              type: AlertType.warning,
              message: 'File ${xfile.name} terlalu besar. Maksimal 10MB.',
              duration: const Duration(seconds: 2),
              style: AlertStyle.toast,
            );
            continue;
          }
          
          // Validasi tipe file
          final extension = xfile.name.split('.').last.toLowerCase();
          if (!['jpg', 'jpeg', 'png'].contains(extension)) {
            context.showEnhancedModernAlert(
              type: AlertType.warning,
              message: 'File ${xfile.name} harus berformat JPG atau PNG.',
              duration: const Duration(seconds: 2),
              style: AlertStyle.toast,
            );
            continue;
          }

          newImages.add(SelectedImage(xfile: xfile, bytes: bytes));
        }
        
        setState(() {
          if (_selectedImages.length + newImages.length > 7) {
            context.showEnhancedModernAlert(
              type: AlertType.warning,
              message: 'Anda hanya dapat memilih hingga 7 gambar.',
              duration: const Duration(seconds: 2),
              style: AlertStyle.toast,
            );
            _selectedImages = _selectedImages.sublist(0, 7 - newImages.length);
          }
          _selectedImages.addAll(newImages);
        });
      }
    } catch (e) {
      print('Error picking images: $e');
      context.showEnhancedModernAlert(
        type: AlertType.error,
        message: 'Gagal memilih gambar. Silakan coba lagi.',
        duration: const Duration(seconds: 2),
        style: AlertStyle.toast,
      );
    }
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
            _buildDialogHeader(),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
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

  Widget _buildDialogHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tambah Gambar',
          style: GoogleFonts.leagueSpartan(
            fontWeight: FontWeight.w600,
            fontSize: 25,
            color: AppColors.shadow,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Silakan masukkan $label';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.doctor, width: 2),
            ),
            filled: true,
            fillColor: AppColors.stoneground,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
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
                  validator: (value) {
                    if (value == null) {
                      return 'Silakan pilih album';
                    }
                    return null;
                  },
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
                      albumIdController.text = value.toString();
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

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gambar (${_selectedImages.length}/7)',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.shadow,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              TextButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Pilih Gambar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.doctor,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
              if (_selectedImages.isNotEmpty) ...[
                const Divider(height: 1),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _selectedImages[index].bytes,
                            height: 84,
                            width: 84,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
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
                  "Unggah",
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

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedImages.isEmpty) {
        context.showEnhancedModernAlert(
          type: AlertType.warning,
          message: 'Silakan pilih setidaknya satu gambar.',
          duration: const Duration(seconds: 2),
          style: AlertStyle.toast,
        );
        return;
      }

      if (selectedAlbumId == null) {
        context.showEnhancedModernAlert(
          type: AlertType.warning,
          message: 'Silakan pilih album.',
          duration: const Duration(seconds: 2),
          style: AlertStyle.toast,
        );
        return;
      }

      setState(() => _isLoading = true);

      for (var image in _selectedImages) {
        final newPhoto = Photo(
          id: 0,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          photo: image.xfile.path,
          album: selectedAlbumId!,
          uploadedAt: '',
          uploadedBy: null,
          sequenceNumber: 0,
        );

        context.read<PhotoBloc>().add(CreatePhoto(newPhoto, image.xfile));
      }

      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() => _isLoading = false);
        widget.onPhotosAdded();
        Navigator.pop(context);
        context.showEnhancedModernAlert(
          type: AlertType.success,
          message: 'Gambar berhasil diunggah.',
          duration: const Duration(seconds: 2),
          style: AlertStyle.toast,
        );
      });
    }
  }


  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    albumIdController.dispose();
    super.dispose();
  }
}
