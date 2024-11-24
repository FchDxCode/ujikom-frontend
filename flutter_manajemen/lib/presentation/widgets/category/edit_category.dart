import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/bloc/category_bloc/category_bloc.dart';
import 'package:luminova/bloc/category_bloc/category_event.dart';
import 'package:luminova/data/models/category_models.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luminova/presentation/widgets/alert_custom.dart';

class EditCategoryDialog extends StatefulWidget {
  final Category category;

  const EditCategoryDialog(this.category, {super.key});

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.category.name);
    descriptionController = TextEditingController(text: widget.category.description);
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
                  "Edit Kategori",
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
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      controller: nameController,
                      label: 'Nama Kategori',
                      prefixIcon: Icons.category_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tolong isi nama kategori';
                        }
                        if (value.length < 3) {
                          return 'Nama kategori harus lebih dari 3 karakter';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                          return 'Nama kategori tidak boleh mengandung spesial karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: descriptionController,
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
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
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
              : Text(
                  "Simpan",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final updatedCategory = Category(
        id: widget.category.id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        sequenceNumber: widget.category.sequenceNumber,
      );

      context.read<CategoryBloc>().add(UpdateCategory(updatedCategory));

      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        
        // Menampilkan custom alert
        context.showEnhancedModernAlert(
          type: AlertType.success,
          title: 'Berhasil',
          message: 'Kategori "${updatedCategory.name}" berhasil diperbarui.',
          duration: const Duration(seconds: 1),
          style: AlertStyle.toast,
        );
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
