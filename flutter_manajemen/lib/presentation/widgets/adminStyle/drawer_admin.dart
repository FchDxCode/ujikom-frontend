import 'package:flutter/material.dart';
import 'package:luminova/bloc/auth_bloc/auth_bloc.dart';
import 'package:luminova/bloc/auth_bloc/auth_state.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import '../../constants/menuAdmin_items.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/auth_bloc/auth_event.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawerAdmin extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(String) onNavItemTapped;

  const CustomDrawerAdmin({
    super.key,
    required this.scaffoldKey,
    required this.onNavItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = '';
        String userRole = '';
        
        if (state is AuthAuthenticated) {
          userName = state.username ?? 'Unknown';
          userRole = state.role;
        }

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.stoneground,
                ),
                accountName: Text(
                  userName,
                  style: GoogleFonts.poppins(
                    color: AppColors.stoneground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                accountEmail: Text(
                  userRole,
                  style: GoogleFonts.poppins(
                    color: AppColors.stoneground.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppColors.stoneground,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 40,
                      color: AppColors.shadow,
                    ),
                  ),
                ),
              ),
              // Daftar menu
              ...menuItems.entries.map((entry) => ListTile(
                    leading: Icon(
                      _getIconForMenuItem(entry.key),
                      color: AppColors.slate,
                    ),
                    title: Text(
                      entry.key,
                      style: GoogleFonts.poppins(
                        color: AppColors.shadow,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onNavItemTapped(entry.value);
                    },
                  )),
              const Divider(),
              // Opsi Sign Out
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: AppColors.shadow,
                ),
                title: Text(
                  'Keluar',
                  style: GoogleFonts.poppins(
                    color: AppColors.shadow,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Tutup drawer
                  Navigator.pop(context);
                  
                  // Dispatch event logout
                  context.read<AuthBloc>().add(LogoutRequested());
                  
                  // Navigate ke halaman login
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',  // Sesuaikan dengan route login Anda
                    (route) => false,  // Hapus semua route sebelumnya
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForMenuItem(String menuItem) {
    // Pemetaan nama menu ke ikon
    switch (menuItem) {
      case 'Pengguna':
        return Icons.person_3_rounded;
      case 'Halaman':
        return Icons.pages_outlined;
      case 'Konten Blok':
        return Icons.image_rounded;
      // Tambahkan case lain sesuai kebutuhan
      default:
        return Icons.circle_rounded;
    }
  }
}
