// lib/widgets/custom_text_form_field.dart
import 'package:flutter/material.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFormField extends StatefulWidget {
  final String labelText;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextEditingController controller;

  const CustomTextFormField({
    super.key,
    required this.labelText,
    this.isPassword = false,
    this.validator,
    required this.controller,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isPasswordVisible = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: widget.isPassword && !_isPasswordVisible,
          focusNode: _focusNode,
          onChanged: (value) {},
          onTap: () {},
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: GoogleFonts.poppins(
              color: _isFocused ? AppColors.shadow : AppColors.slate,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              widget.isPassword ? Icons.lock_outline : Icons.person_outline,
              color: _isFocused ? AppColors.shadow : AppColors.slate,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.slate,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.slate),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.shadow),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.red),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.red),
            ),
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
