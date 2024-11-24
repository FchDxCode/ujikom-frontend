import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/album_bloc/album_bloc.dart';
import 'package:gallery_fe/bloc/album_bloc/album_event.dart';
import 'package:gallery_fe/data/models/album_models.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gallery_fe/presentation/widgets/alert_custom.dart';
import 'package:gallery_fe/bloc/category_bloc/category_bloc.dart';
import 'package:gallery_fe/bloc/category_bloc/category_event.dart';
import 'package:gallery_fe/bloc/category_bloc/category_state.dart';

class AddAlbumDialog extends StatelessWidget {
  final VoidCallback onAlbumAdded;

  const AddAlbumDialog({
    super.key, 
    required this.onAlbumAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          child: AddAlbumForm(onAlbumAdded: onAlbumAdded),
        ),
      ),
    );
  }
}

class AddAlbumForm extends StatefulWidget {
  final VoidCallback onAlbumAdded;

  const AddAlbumForm({super.key, required this.onAlbumAdded});

  @override
  State<AddAlbumForm> createState() => _AddAlbumFormState();
}

class _AddAlbumFormState extends State<AddAlbumForm> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  bool _isLoading = false;
  bool? isActive;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(FetchCategories());
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField(
                    controller: titleController,
                    label: 'Judul Album',
                    prefixIcon: Icons.title,
                    validator: (value) => _validateNoSpecialCharacters(value, fieldName: 'judul'),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: descriptionController,
                    label: 'Deskripsi',
                    prefixIcon: Icons.description,
                    maxLines: 5,
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
          ],
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
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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
              :  Text(
                  "Buat Album",
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
      if (isActive != null && selectedCategoryId != null) {
        setState(() => _isLoading = true);

        final newAlbum = Album(
          id: 0,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          isActive: isActive!,
          createdAt: DateTime.now().toIso8601String(),
          category: selectedCategoryId!,
          createdBy: null,
          folderPath: "",
          sequenceNumber: 0,
        );

        // Trigger the create page event
        context.read<AlbumBloc>().add(CreateAlbum(newAlbum));

        // Simulating a delay to show loading state
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() => _isLoading = false);

          // Fetch pages again to refresh the data after adding a new page
          context.read<AlbumBloc>().add(FetchAlbums());

          widget.onAlbumAdded();
          Navigator.pop(context);
        });
      } else {
        context.showEnhancedModernAlert(
          type: AlertType.warning,
          title: 'Peringatan',
          message: 'Tolong isi semua field, termasuk Category dan Active/Deactive',
          duration: const Duration(seconds: 1),
          style: AlertStyle.toast,
        );
      }
    }
  }

  String? _validateNoSpecialCharacters(String? value, {required String fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Silakan masukkan $fieldName';
    }

    // Regex untuk hanya memperbolehkan huruf, angka, spasi, dan tanda baca dasar (tanpa karakter spesial berbahaya)
    final validCharacters = RegExp(r'^[a-zA-Z0-9\s,.!?-]+$');

    if (!validCharacters.hasMatch(value)) {
      return '$fieldName mengandung karakter yang tidak valid';
    }

    return null;
  }

  // Add this method to create the dropdown for is_active
  Widget _buildIsActiveDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Aktif',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<bool>(
          value: isActive,
          decoration: InputDecoration(
            border: OutlineInputBorder(
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
          hint: const Text('Pilih Status'),
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
          onChanged: (bool? value) {
            setState(() {
              isActive = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Pilih status';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Replace the existing category input field with this new dropdown
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    hintText: 'Pilih Kategori',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.slate,
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Pilih Kategori';
                    }
                    return null;
                  },
                  items: categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(
                        category.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                      categoryController.text = value.toString();
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

            if (state is CategoryError) {
              return Text(
                'Gagal memuat kategori: ${state.message}',
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Buat Album Baru",
          style: GoogleFonts.leagueSpartan(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
