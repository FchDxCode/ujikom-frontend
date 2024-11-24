import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/page_bloc/page_bloc.dart';
import 'package:gallery_fe/bloc/page_bloc/page_event.dart';
import 'package:gallery_fe/data/models/page_models.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:gallery_fe/presentation/widgets/alert_custom.dart';
import 'package:google_fonts/google_fonts.dart';

class EditPage extends StatefulWidget {
  final PageModel page;

  const EditPage({super.key, required this.page});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController contentController;
  bool? isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.page.title);
    contentController = TextEditingController(text: widget.page.content);
    isActive = widget.page.isActive;
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
        child: Scrollbar(
          thickness: 0,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit Halaman",
                      style: GoogleFonts.leagueSpartan(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        controller: titleController,
                        label: 'Judul',
                        prefixIcon: Icons.title,
                        validator: (value) => _validateNoSpecialCharacters(
                            value, fieldName: 'title'),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: contentController,
                        label: 'Konten',
                        prefixIcon: Icons.description,
                        maxLines: 5,
                      ),
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
      if (isActive != null) {
        setState(() => _isLoading = true);

        final updatedPage = PageModel(
          id: widget.page.id,
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          slug: widget.page.slug,
          isActive: isActive!,
          sequenceNumber: widget.page.sequenceNumber,
          createdAt: widget.page.createdAt,
          updatedAt: DateTime.now(),
        );

        context.read<PageBloc>().add(UpdatePage(updatedPage));

        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() => _isLoading = false);
          Navigator.pop(context);
          context.showEnhancedModernAlert(
            type: AlertType.success,
            title: 'Sukses',
            message: 'Halaman "${updatedPage.title}" berhasil diperbarui.',
            duration: const Duration(seconds: 1),
            style: AlertStyle.toast,
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tolong isi semua field, termasuk Aktif/Non Aktif'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _validateNoSpecialCharacters(String? value, {required String fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Tolong isi $fieldName';
    }

    // Regex yang lebih fleksibel untuk teks normal
    final validCharacters = RegExp(r'^[a-zA-Z0-9\s,.\!\?\(\)\|\@\#\~\;\:\{\}\&\/\=\+\-\[\]]*$');

    if (!validCharacters.hasMatch(value)) {
      return '$fieldName mengandung karakter yang tidak diperbolehkan';
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
          hint: Text(
            'Pilih Status',
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          items: [
            DropdownMenuItem(
              value: true,
              child: Text(
                'Aktif',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
            DropdownMenuItem(
              value: false,
              child: Text(
                'Non Aktif',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
          ],
          onChanged: (bool? value) {
            setState(() {
              isActive = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Tolong pilih status';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
