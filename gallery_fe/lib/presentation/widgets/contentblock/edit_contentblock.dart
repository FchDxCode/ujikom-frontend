import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/contentBlok_bloc/contentblock_bloc.dart';
import 'package:gallery_fe/bloc/contentBlok_bloc/contentblock_event.dart';
import 'package:gallery_fe/bloc/page_bloc/page_bloc.dart';
import 'package:gallery_fe/bloc/page_bloc/page_event.dart';
import 'package:gallery_fe/bloc/page_bloc/page_state.dart';
import 'package:gallery_fe/data/models/contentblock_models.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:gallery_fe/presentation/widgets/alert_custom.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditContentBlock extends StatefulWidget {
  final ContentBlockModel contentBlock;

  const EditContentBlock({super.key, required this.contentBlock});

  @override
  _EditContentBlockState createState() => _EditContentBlockState();
}

class _EditContentBlockState extends State<EditContentBlock> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final pageController = TextEditingController();

  XFile? _selectedImage;
  bool _isLoading = false;
  int? selectedPageId;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.contentBlock.title;
    descriptionController.text = widget.contentBlock.description ?? '';
    pageController.text = widget.contentBlock.page.toString();
    selectedPageId = widget.contentBlock.page;
    context.read<PageBloc>().add(FetchPages());
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    
    try {
      final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
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
                        label: 'Title',
                        prefixIcon: Icons.title,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: descriptionController,
                        label: 'Deskripsi',
                        prefixIcon: Icons.description,
                      ),
                      const SizedBox(height: 16),
                      _buildPageDropdown(),
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

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Image',
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
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              if (_selectedImage != null)
                FutureBuilder<Uint8List>(
                  future: _selectedImage!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(child: Icon(Icons.error));
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        snapshot.data!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                )
              else if (widget.contentBlock.image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.contentBlock.image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: AppColors.slate.withOpacity(0.5),
                        ),
                      );
                    },
                  ),
                ),

              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.shadow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: AppColors.doctor.withOpacity(0.8),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ganti Image',
                              style: GoogleFonts.poppins(
                                color: AppColors.doctor.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDialogHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Edit Content Block',
          style: GoogleFonts.leagueSpartan(
            fontWeight: FontWeight.w600,
            fontSize: 20,
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
    TextInputType inputType = TextInputType.text,
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
          keyboardType: inputType,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Tolong masukkan $label';
            }
            return null;
          },
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

  Widget _buildPageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Page',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.shadow,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<PageBloc, PageState>(
          builder: (context, state) {
            if (state is PageLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (state is PageLoaded) {
              final pages = state.pages;
              
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.slate),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<int>(
                  value: selectedPageId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.pages, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    hintText: 'Pilih Page',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.slate,
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Tolong pilih page';
                    }
                    return null;
                  },
                  items: pages.map((page) {
                    return DropdownMenuItem<int>(
                      value: page.id,
                      child: Text(
                        page.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPageId = value;
                      pageController.text = value.toString();
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

            if (state is PageError) {
              return Text(
                'Gagal memuat page: ${state.message}',
                style: GoogleFonts.poppins(
                  color: AppColors.red,
                ),
              );
            }

            return const SizedBox();
          },
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.stoneground),
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

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedImage == null && widget.contentBlock.image.isEmpty) {
        context.showEnhancedModernAlert(
          type: AlertType.warning,
          title: 'Image Diperlukan',
          message: 'Tolong pilih image.',
          duration: const Duration(seconds: 1),
          style: AlertStyle.toast,
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final updatedContentBlock = ContentBlockModel(
          id: widget.contentBlock.id,
          page: selectedPageId!,
          title: titleController.text,
          image: widget.contentBlock.image,
          description: descriptionController.text,
          created_by: widget.contentBlock.created_by,
          updated_at: widget.contentBlock.updated_at,
          sequence_number: widget.contentBlock.sequence_number,
        );

        if (_selectedImage != null) {
          http.MultipartFile? imageFile;
          if (kIsWeb) {
            final bytes = await _selectedImage!.readAsBytes();
            imageFile = http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: _selectedImage!.name,
            );
          } else {
            imageFile = await http.MultipartFile.fromPath(
              'image',
              _selectedImage!.path,
              filename: _selectedImage!.name,
            );
          }

          context.read<ContentBlockBloc>().add(
            UpdateContentBlock(
              updatedContentBlock,
              imageFile: imageFile,
            ),
          );
        } else {
          context.read<ContentBlockBloc>().add(
            UpdateContentBlock(updatedContentBlock),
          );
        }

        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() => _isLoading = false);
          Navigator.pop(context);
          
          context.read<ContentBlockBloc>().add(FetchContentBlocks());
          
          context.showEnhancedModernAlert(
            type: AlertType.success,
            title: 'Berhasil',
            message: 'Content Block berhasil diperbarui.',
            duration: const Duration(seconds: 1),
            style: AlertStyle.toast,
          );
        });
      } catch (e) {
        setState(() => _isLoading = false);
        context.showEnhancedModernAlert(
          type: AlertType.error,
          title: 'Error',
          message: 'Gagal mengupdate Content Block: ${e.toString()}',
          duration: const Duration(seconds: 3),
          style: AlertStyle.toast,
        );
      }
    }
  }


  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    pageController.dispose();
    super.dispose();
  }
}
