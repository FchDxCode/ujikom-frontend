import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:luminova/data/models/contentblock_models.dart';
import 'package:luminova/data/repositories/logo_repositories.dart';
import 'package:luminova/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';

class Logo extends StatefulWidget {
  const Logo({super.key});

  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<Logo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final LogoRepository _logoRepository = LogoRepository();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  Widget _buildStaticLogo(bool isSmallScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/luminova.png',
            width: isSmallScreen ? 100 : 150,
            height: isSmallScreen ? 100 : 150,
          ),
          const SizedBox(height: 16),
          Text(
            'Server Sedang Tidak Tersedia',  // Ganti dengan nama aplikasi statis
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 24 : 32,
              fontWeight: FontWeight.w600,
              color: AppColors.doctor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return FutureBuilder<List<ContentBlockModel>>(
      future: _logoRepository.fetchLogoContent(),
      builder: (context, snapshot) {
        // Tambahkan timeout handling
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tunggu sebentar, jika masih loading tampilkan static UI
          return FutureBuilder(
            future: Future.delayed(const Duration(seconds: 3)),
            builder: (context, timeoutSnapshot) {
              if (timeoutSnapshot.connectionState == ConnectionState.done) {
                return _buildStaticLogo(isSmallScreen);
              }
              return const Center(child: CircularProgressIndicator());
            },
          );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          // Langsung tampilkan static UI jika ada error atau data kosong
          return _buildStaticLogo(isSmallScreen);
        }

        // Jika berhasil dapat data dari server, tampilkan data dinamis
        final logoContent = snapshot.data!.first;
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: logoContent.image,
                width: isSmallScreen ? 100 : 150,
                height: isSmallScreen ? 100 : 150,
                fit: BoxFit.contain,
                placeholder: (context, url) => const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/luminova.png',
                  width: isSmallScreen ? 100 : 150,
                  height: isSmallScreen ? 100 : 150,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                logoContent.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 24 : 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.doctor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
