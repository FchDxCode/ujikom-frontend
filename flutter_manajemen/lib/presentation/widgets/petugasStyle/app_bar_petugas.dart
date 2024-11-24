import 'package:flutter/material.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import 'navbar_items_petugas.dart';
import '../profile_icon.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(String) onNavItemTapped;

  const CustomAppBar({
    super.key,
    required this.scaffoldKey,
    required this.onNavItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Menentukan apakah layar berukuran besar atau kecil
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 768;

    return AppBar(
      backgroundColor: AppColors.abyssal,
      elevation: 0,
      titleSpacing: 0,
      leading: isLargeScreen
          ? null
          : IconButton(
              icon: const Icon(
                Icons.menu,
                color: AppColors.stoneground,
              ),
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
      title: Row(
        children: [
          const SizedBox(width: 16.0),
          Text(
            "SMKN 4 BOGOR",
            style: GoogleFonts.leagueSpartan(
                  color: AppColors.stoneground,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (isLargeScreen) ...[
            const Spacer(),
            NavBarItemsPetugas(onNavItemTapped: onNavItemTapped),
          ],
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: CircleAvatar(
              backgroundColor: AppColors.stoneground,
              child: ProfileIcon(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 0.5);
}
