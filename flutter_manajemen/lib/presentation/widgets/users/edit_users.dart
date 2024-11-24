import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/bloc/users_bloc/users_event.dart';
import 'package:luminova/data/models/users_models.dart';
import 'package:luminova/bloc/users_bloc/users_bloc.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import 'package:luminova/presentation/widgets/alert_custom.dart';
import 'package:google_fonts/google_fonts.dart';

class EditUserDialog extends StatefulWidget {
  final User user;

  const EditUserDialog(this.user, {super.key});

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late String selectedRole;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.user.username);
    passwordController = TextEditingController();
    selectedRole = widget.user.role ?? 'petugas';
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
                  "Edit Pengguna",
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      controller: usernameController,
                      label: 'Nama',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tolong isi nama';
                        }
                        if (value.length < 3) {
                          return 'Nama harus lebih dari 3 karakter';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                          return 'Nama tidak boleh mengandung spesial karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 16),
                    _buildRoleDropdown(),
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
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
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

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedRole,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.slate,
              ),
            ),
            filled: true,
            fillColor: AppColors.stoneground,
            contentPadding: const EdgeInsets.all(16),
          ),
          items: [
            DropdownMenuItem(
                value: 'petugas',
                child: Text(
                  'Petugas',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500, fontSize: 14),
                )),
            DropdownMenuItem(
                value: 'admin',
                child: Text(
                  'Admin',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500, fontSize: 14),
                )),
          ],
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedRole = newValue;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Tolong pilih role';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return _buildInputField(
      controller: passwordController,
      label: 'Password (opsional)',
      prefixIcon: Icons.lock_outline,
      isPassword: true,
      validator: (value) {
        if (value != null && value.isNotEmpty && value.length < 8) {
          return 'Password harus lebih dari 8 karakter';
        }
        return null;
      },
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

      final updatedUser = User(
        id: widget.user.id,
        username: usernameController.text.trim(),
        role: selectedRole.isNotEmpty ? selectedRole : null,
      );

      final password =
          passwordController.text.isNotEmpty ? passwordController.text : null;

      context.read<UsersBloc>().add(UpdateUser(updatedUser, password));

      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() => _isLoading = false);
        Navigator.pop(context);

        // Menampilkan custom alert
        context.showEnhancedModernAlert(
          type: AlertType.success,
          title: 'Sukses',
          message: 'Pengguna "${updatedUser.username}" berhasil diubah.',
          duration: const Duration(seconds: 1),
          style: AlertStyle.toast,
        );
      });
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
