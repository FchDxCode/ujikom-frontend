import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/bloc/category_bloc/category_bloc.dart';
import 'package:luminova/bloc/category_bloc/category_event.dart';
import 'package:luminova/data/models/category_models.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luminova/presentation/widgets/alert_custom.dart';

class AddCategory extends StatefulWidget {
  final VoidCallback onCategoryAdded; // Callback for refresh

  const AddCategory({super.key, required this.onCategoryAdded}); // Initialize the callback

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final category = Category(
        id: 0, // ID akan di-generate backend
        name: _nameController.text,
        description: _descriptionController.text,
        sequenceNumber: 0,
      );

      // Trigger the create category event
      context.read<CategoryBloc>().add(CreateCategory(category));

      // Close the dialog after a short delay and refresh data
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() => _isLoading = false);
        _clearForm();
        widget.onCategoryAdded(); // Call the callback to refresh data
        Navigator.pop(context);
        
        // Menampilkan custom alert
        context.showEnhancedModernAlert(
          type: AlertType.success,
          title: 'Berhasil',
          message: 'Kategori "${category.name}" berhasil dibuat.',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tambah Kategori",
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
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      controller: _nameController,
                      label: 'Nama Kategori',
                      prefixIcon: Icons.category_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tolong isi nama kategori';
                        }
                        if (value.length < 3) {
                          return 'Nama kategori harus lebih dari 3 karakter';
                        }
                        if (!RegExp('').hasMatch(value)) {
                          return 'Nama kategori tidak boleh mengandung spesial karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _descriptionController,
                      label: 'Deskripsi Kategori',
                      prefixIcon: Icons.description_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tolong isi deskripsi kategori';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
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
    String? Function(String?)? validator,
    bool isPassword = false,
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
          obscureText: isPassword,
          validator: validator,
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
                  "Tambah",
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
