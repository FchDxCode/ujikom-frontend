import 'package:flutter/material.dart';
import 'package:gallery_fe/bloc/auth_bloc/auth_bloc.dart';
import 'package:gallery_fe/bloc/auth_bloc/auth_state.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:gallery_fe/presentation/screens/manageAlbum_screens.dart';
import 'package:gallery_fe/presentation/screens/managePhoto_screens.dart';
import 'package:gallery_fe/presentation/screens/manageCategory_screens.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/profile_icon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavbarScreensPetugas extends StatefulWidget {
  const NavbarScreensPetugas({super.key});

  @override
  _NavbarScreensPetugasState createState() => _NavbarScreensPetugasState();
}

class _NavbarScreensPetugasState extends State<NavbarScreensPetugas> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget _currentBody = const Center(child: Text("Selamat Datang Petugas"));
  String _currentRoute = '/petugas';

  @override
  void initState() {
    super.initState();
    _updateBody('/petugas');
  }

  void _updateBody(String route) {
    setState(() {
      _currentRoute = route;
      switch (route) {
        case '/petugas':
          _currentBody = const ManageCategoryScreens();
          break;
        case '/manageAlbum':
          _currentBody = const ManageAlbumScreens();
          break;
        case '/managePhoto':
          _currentBody = const ManagePhotoScreen();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 800;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: isLargeScreen
            ? null
            : AppBar(
                title: Text('Petugas Panel', 
                  style: GoogleFonts.poppins(color: AppColors.stoneground)
                ),
                backgroundColor: AppColors.shadow,
              ),
        drawer: isLargeScreen
            ? null
            : Drawer(
                child: _buildNavMenu(),
              ),
        body: Row(
          children: [
            if (isLargeScreen) ...[
              SizedBox(
                width: 250,
                child: Material(
                  elevation: 4,
                  child: _buildNavMenu(),
                ),
              ),
            ],
            Expanded(child: _currentBody),
          ],
        ),
      ),
    );
  }

  Widget _buildNavMenu() {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Manajemen Kategori', 'icon': Icons.category, 'route': '/petugas'},
      {'title': 'Manajemen Album', 'icon': Icons.album, 'route': '/manageAlbum'},
      {'title': 'Manajemen Foto', 'icon': Icons.photo, 'route': '/managePhoto'},
    ];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: AppColors.shadow),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.stoneground,
                child: Icon(Icons.person, size: 40, color: AppColors.shadow),
              ),
              const SizedBox(height: 16),
              Text(
                'Petugas Panel',
                style: GoogleFonts.poppins(
                  color: AppColors.stoneground,
                  fontSize: 20,
                  fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
        ...menuItems.map((item) {
          final bool isSelected = _currentRoute == item['route'];
          return ListTile(
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(item['icon'], 
                  color: isSelected ? Colors.blue : AppColors.cerramic
                ),
              ],
            ),
            title: Text(
              item['title'],
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.blue : AppColors.shadow,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            onTap: () => _updateBody(item['route'] as String),
          );
        }),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.person_outline, color: AppColors.cerramic),
          title: Text(
            'Profile',
            style: GoogleFonts.poppins(
              color: AppColors.shadow,
              fontWeight: FontWeight.normal,
            ),
          ),
          onTap: () {
            if (!MediaQuery.of(context).size.width.isFinite) {
              Navigator.pop(context);
            }
            ProfileIcon.showProfileModal(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.cerramic),
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(
              color: AppColors.shadow,
              fontWeight: FontWeight.normal,
            ),
          ),
          onTap: () {
            if (!MediaQuery.of(context).size.width.isFinite) {
              Navigator.pop(context);
            }
            ProfileIcon.showLogoutConfirmation(context);
          },
        ),
      ],
    );
  }
}