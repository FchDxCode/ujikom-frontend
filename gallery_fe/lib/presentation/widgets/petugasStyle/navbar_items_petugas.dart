import 'package:flutter/material.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import '../../constants/menuPetugas_items.dart';
import 'package:google_fonts/google_fonts.dart';

class NavBarItemsPetugas extends StatelessWidget {
  final Function(String) onNavItemTapped;

  const NavBarItemsPetugas({super.key, required this.onNavItemTapped});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: menuItems.entries.map(
        (entry) => InkWell(
          onTap: () => onNavItemTapped(entry.value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20),
            child: Text(
              entry.key,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                color: AppColors.stoneground,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ).toList(),
    );
  }
}