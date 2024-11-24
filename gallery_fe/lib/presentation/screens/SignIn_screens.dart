// lib/pages/sign_in_page.dart
import 'package:flutter/material.dart';
import 'package:gallery_fe/presentation/widgets/signInForm.dart';
import '../widgets/logo.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile Layout
            return const SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Logo(),
                  SizedBox(height: 40),
                  SignInForm(),
                ],
              ),
            );
          } else {
            // Desktop Layout
            return Center(
              child: Container(
                padding: const EdgeInsets.all(48.0),
                constraints: const BoxConstraints(maxWidth: 1000),
                child: const Row(
                  children: [
                    Expanded(
                      child: Logo(),
                    ),
                    SizedBox(width: 60),
                    Expanded(
                      child: SignInForm(),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
