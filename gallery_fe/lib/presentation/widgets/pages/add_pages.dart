import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/page_bloc/page_bloc.dart';
import 'package:gallery_fe/bloc/page_bloc/page_event.dart';
import 'package:gallery_fe/data/models/page_models.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gallery_fe/presentation/widgets/alert_custom.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  bool _isLoading = false;
  bool? isActive;

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
                      "Buat Halaman Baru",
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
                          controller: titleController,
                          label: 'Judul',
                          prefixIcon: Icons.title,
                          validator: (value) => _validateNoSpecialCharacters(value,
                              fieldName: 'title'),
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
                  "Buat Halaman",
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
        // Check if isActive is not null
        setState(() => _isLoading = true);

        final newPage = PageModel(
          id: 0,
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          slug: '',
          isActive: isActive!, // Use isActive safely
          sequenceNumber: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Trigger the create page event
        context.read<PageBloc>().add(CreatePage(newPage));

        // Simulating a delay to show loading state
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() => _isLoading = false);

          // Fetch pages again to refresh the data after adding a new page
          context.read<PageBloc>().add(FetchPages());

          Navigator.pop(context);
        });
      } else {
        context.showEnhancedModernAlert(
          type: AlertType.warning,
          title: 'Peringatan',
          message: 'Tolong isi semua field, termasuk Aktif/Non Aktif',
          duration: const Duration(seconds: 1),
          style: AlertStyle.toast,
        );
      }
    }
  }

  String? _validateNoSpecialCharacters(String? value,
      {required String fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Tolong isi $fieldName';
    }

    // Regex untuk hanya memperbolehkan huruf, angka, spasi, dan tanda baca dasar (tanpa karakter spesial berbahaya)
    final validCharacters = RegExp(r'^[a-zA-Z0-9\s,.!?-]+$');

    if (!validCharacters.hasMatch(value)) {
      return ' $fieldName hanya boleh mengandung huruf, angka, spasi, dan tanda baca dasar';
    }

    return null;
  }

  // Add this method to create the dropdown for is_active
  Widget _buildIsActiveDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Status',
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
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          items: [
            DropdownMenuItem(
              value: true,
              child: Text(
                'Aktif',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            DropdownMenuItem(
              value: false,
              child: Text(
                'Non Aktif',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
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
