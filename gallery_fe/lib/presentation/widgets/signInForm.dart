// lib/widgets/sign_in_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/presentation/widgets/signInTextForm.dart';
import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../bloc/auth_bloc/auth_event.dart';
import '../../bloc/auth_bloc/auth_state.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Button Animation Controller
    _buttonController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _buttonScaleAnimation =
        Tween<double>(begin: 1.0, end: 0.95).animate(_buttonController);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _onButtonPressed() async {
    await _buttonController.forward();
    await _buttonController.reverse();

    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text;
      final password = _passwordController.text;
      BlocProvider.of<AuthBloc>(context).add(
        LoginRequested(username, password),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.role == 'admin') {
            Navigator.pushReplacementNamed(context, '/navbarAdmin');
          } else if (state.role == 'petugas') {
            Navigator.pushReplacementNamed(context, '/navbarPetugas');
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFormField(
                    controller: _usernameController,
                    labelText: 'Username',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    controller: _passwordController,
                    labelText: 'Password',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password wajib diisi';
                      }
                      if (value.trim().length < 6) {
                        return 'Minimum 6 karakter yang diperlukan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 100),
                  ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: AppColors.shadow,
                          elevation: 0,
                        ),
                        onPressed: _onButtonPressed,
                        child: Text(
                          'Masuk',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.stoneground),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
