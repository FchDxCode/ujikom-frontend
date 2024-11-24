import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/bloc/album_bloc/album_bloc.dart';
import 'package:luminova/bloc/album_bloc/album_event.dart';
import 'package:luminova/data/models/album_models.dart';
import 'package:luminova/bloc/category_bloc/category_bloc.dart';
import 'package:luminova/bloc/category_bloc/category_event.dart';
import 'package:luminova/bloc/category_bloc/category_state.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import 'package:luminova/presentation/widgets/alert_custom.dart';
import 'package:google_fonts/google_fonts.dart';

class EditAlbumModal extends StatefulWidget {
  final Album album;

  const EditAlbumModal({super.key, required this.album});

  @override
  _EditAlbumModalState createState() => _EditAlbumModalState();
}

class _EditAlbumModalState extends State<EditAlbumModal> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  int? selectedCategoryId;
  bool isActive = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.album.title;
    descriptionController.text = widget.album.description;
    selectedCategoryId = widget.album.category;
    isActive = widget.album.isActive;
    context.read<CategoryBloc>().add(FetchCategories());
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.shadow,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (state is CategoryLoaded) {
              final categories = state.categories;
              
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.slate),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.category, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintText: 'Pilih Kategori',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.slate,
                    ),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(
                        category.name,
                        style: GoogleFonts.poppins(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Silakan pilih kategori';
                    }
                    return null;
                  },
                  isExpanded: true,
                  dropdownColor: AppColors.stoneground,
                ),
              );
            }

            if (state is CategoryError) {
              return Text(
                'Gagal memuat kategori: ${state.message}',
                style: GoogleFonts.poppins(color: AppColors.red),
              );
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildIsActiveDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Aktif',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.shadow,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<bool>(
            value: isActive,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.toggle_on_outlined, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: 'Pilih Status',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.slate,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: true,
                child: Text('Aktif'),
              ),
              DropdownMenuItem(
                value: false,
                child: Text('Non Aktif'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                isActive = value!;
              });
            },
            isExpanded: true,
            dropdownColor: AppColors.stoneground,
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
                  "Perbarui",
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
      setState(() => _isLoading = true);

      final updatedAlbum = Album(
        id: widget.album.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: selectedCategoryId!,
        isActive: isActive,
        createdAt: widget.album.createdAt,
        createdBy: widget.album.createdBy,
        folderPath: widget.album.folderPath,
        sequenceNumber: widget.album.sequenceNumber,
      );

      context.read<AlbumBloc>().add(UpdateAlbum(updatedAlbum));

      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        context.showEnhancedModernAlert(
          type: AlertType.success,
          message: 'Album "${updatedAlbum.title}" berhasil diperbarui.',
          duration: const Duration(seconds: 1),
          style: AlertStyle.toast,
        );
      });
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
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
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
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Album",
                    style: GoogleFonts.leagueSpartan(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Silakan masukkan judul';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: descriptionController,
                          label: 'Deskripsi',
                          prefixIcon: Icons.description,
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Silakan masukkan deskripsi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildCategoryDropdown(),
                        const SizedBox(height: 16),
                        _buildIsActiveDropdown(),
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
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    String? Function(String?)? validator,
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
          validator: validator,
          maxLines: maxLines,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.red,
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

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
