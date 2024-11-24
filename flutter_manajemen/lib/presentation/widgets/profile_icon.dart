import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../bloc/auth_bloc/auth_event.dart';
import '../../bloc/auth_bloc/auth_state.dart';
import 'package:google_fonts/google_fonts.dart';

enum Menu { profile, signOut }

class ProfileIcon extends StatefulWidget {
  const ProfileIcon({super.key});

  static void showProfileModal(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _showProfileModalContent(
        context, 
        authState.username ?? 'Unknown', 
        authState.role
      );
    }
  }

  static void _showProfileModalContent(BuildContext context, String username, String role) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.stoneground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.doctor,
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 40,
                      color: AppColors.stoneground,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Nama: ${username.length > 15 ? '${username.substring(0, 15)}...' : username}",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.shadow,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.stoneground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Role: $role",
                    style: GoogleFonts.poppins(
                      color: AppColors.shadow,
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: AppColors.shadow,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.stoneground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Konfirmasi Logout',
            style: GoogleFonts.poppins(
              color: AppColors.shadow,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar?',
            style: GoogleFonts.poppins(
              color: AppColors.shadow,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Tidak',
                style: GoogleFonts.poppins(
                  color: AppColors.shadow,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', 
                  (Route<dynamic> route) => false
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Ya, Keluar',
                style: GoogleFonts.poppins(
                  color: AppColors.stoneground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void onSelected(Menu item, BuildContext context) {
    switch (item) {
      case Menu.profile:
        showProfileModal(context);
        break;
      case Menu.signOut:
        showLogoutConfirmation(context);
        break;
    }
  }

  @override
  State<ProfileIcon> createState() => _ProfileIconState();
}

class _ProfileIconState extends State<ProfileIcon> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String username = '';
        if (state is AuthAuthenticated) {
          username = state.username ?? 'Unknown';
        }

        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              Navigator.of(context).pushReplacementNamed('/');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: PopupMenuButton<Menu>(
            iconSize: 40,
            icon: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.stoneground,
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.shadow,
                ),
              ),
            ),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Colors.white,
            onSelected: (Menu item) {
              switch (item) {
                case Menu.profile:
                  ProfileIcon.showProfileModal(context);
                  break;
                case Menu.signOut:
                  ProfileIcon.showLogoutConfirmation(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              PopupMenuItem<Menu>(
                value: Menu.profile,
                child: ListTile(
                  leading:
                      const Icon(Icons.person_outline, color: Colors.black),
                  title: Text(
                    'Profil',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.signOut,
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.black),
                  title: Text(
                    'Keluar',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
