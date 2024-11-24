import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/bloc/contentBlok_bloc/contentblock_bloc.dart';
import 'package:luminova/bloc/contentBlok_bloc/contentblock_event.dart';
import 'package:luminova/bloc/page_bloc/page_bloc.dart';
import 'package:luminova/bloc/page_bloc/page_event.dart';
import 'package:luminova/bloc/page_bloc/page_state.dart';
import 'package:luminova/data/models/contentblock_models.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import 'package:luminova/presentation/widgets/alert_custom.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AddContentBlock extends StatefulWidget {
  const AddContentBlock({super.key});

  @override
  _AddContentBlockState createState() => _AddContentBlockState();
}

class _AddContentBlockState extends State<AddContentBlock> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final pageController = TextEditingController();

  XFile? _selectedImage;
  bool _isLoading = false;
  final int _maxImages = 1;
  int? selectedPageId;

  @override
  void initState() {
    super.initState();
    context.read<PageBloc>().add(FetchPages());
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      context.showEnhancedModernAlert(
        type: AlertType.error,
        title: 'Error',
        message: 'Gagal memilih gambar: ${e.toString()}',
        duration: const Duration(seconds: 3),
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

  Widget _buildImagePreview() {
    if (_selectedImage == null) {
      return Center(
        child: TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.add_photo_alternate),
          label: Text(
            'Tambah Gambar',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, fontSize: 14),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.doctor,
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: kIsWeb
              ? FutureBuilder<Uint8List>(
                  future: _selectedImage!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(child: Icon(Icons.error));
                    }
                    return Image.memory(
                      snapshot.data!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : FutureBuilder<Uint8List>(
                  future: _selectedImage!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(child: Icon(Icons.error));
                    }
                    return Image.memory(
                      snapshot.data!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.stoneground.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete, color: AppColors.red, size: 20),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                });
              },
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: const EdgeInsets.all(6),
            ),
          ),
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
              'Gambar (${_selectedImage != null ? 1 : 0}/$_maxImages)',
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
          child: _buildImagePreview(),
        ),
      ],
    );
  }

  Widget _buildDialogHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Buat Content Block',
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
              return 'Tolong isi $label';
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
          'Halaman',
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    hintText: 'Pilih Halaman',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.slate,
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Tolong pilih halaman';
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
                'Error loading halaman: ${state.message}',
                style: GoogleFonts.poppins(color: AppColors.red),
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
                  "Buat",
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
      if (_selectedImage == null) {
        context.showEnhancedModernAlert(
          type: AlertType.warning,
          title: 'Gambar Diperlukan',
          message: 'Tolong pilih gambar.',
          duration: const Duration(seconds: 3),
          style: AlertStyle.toast,
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Prepare image file
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

        // Create content block model
        final newContentBlock = ContentBlockModel(
          id: 0,
          page: selectedPageId!,
          title: titleController.text,
          image: '', // Server will handle the image path
          description: descriptionController.text,
        );

        // Dispatch create event
        context.read<ContentBlockBloc>().add(
          CreateContentBlock(
            contentBlock: newContentBlock,
            imageFile: imageFile,
          ),
        );

        // Handle success
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() => _isLoading = false);
          Navigator.pop(context);
          
          // Refresh content blocks after creation
          context.read<ContentBlockBloc>().add(FetchContentBlocks());
          
          context.showEnhancedModernAlert(
            type: AlertType.success,
            title: 'Berhasil',
            message: 'Content Block berhasil dibuat.',
            duration: const Duration(seconds: 1),
            style: AlertStyle.toast,
          );
        });
      } catch (e) {
        setState(() => _isLoading = false);
        context.showEnhancedModernAlert(
          type: AlertType.error,
          title: 'Error',
          message: 'Gagal membuat Content Block: ${e.toString()}',
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
