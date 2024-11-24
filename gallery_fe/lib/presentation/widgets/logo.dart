// lib/widgets/logo.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/contentBlok_bloc/contentblock_bloc.dart';
import 'package:gallery_fe/bloc/contentBlok_bloc/contentblock_event.dart';
import 'package:gallery_fe/bloc/contentBlok_bloc/contentblock_state.dart';
import 'package:gallery_fe/bloc/page_bloc/page_bloc.dart';
import 'package:gallery_fe/bloc/page_bloc/page_event.dart';
import 'package:gallery_fe/bloc/page_bloc/page_state.dart';
import 'package:gallery_fe/data/models/page_models.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';

class Logo extends StatefulWidget {
  const Logo({super.key});

  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<Logo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 800)
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    
    // Fetch pages to get logo page
    context.read<PageBloc>().add(FetchPages());
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return BlocBuilder<PageBloc, PageState>(
      builder: (context, pageState) {
        if (pageState is PageLoaded) {
          // Find logo page
          final logoPage = pageState.pages.firstWhere(
            (page) => page.slug == 'logo-flutter',
            orElse: () => PageModel(
              id: 0,
              title: '',
              slug: '',
              content: '',
              isActive: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          if (logoPage.id != 0) {
            // Fetch content blocks for logo page
            context.read<ContentBlockBloc>().add(
              FetchContentBlocksByPage(logoPage.id)
            );

            return BlocBuilder<ContentBlockBloc, ContentBlockState>(
              builder: (context, contentState) {
                if (contentState is ContentBlockLoaded) {
                  // Filter contentblocks untuk memastikan hanya milik page logo-flutter
                  final logoContents = contentState.contentBlocks
                      .where((content) => content.page == logoPage.id)
                      .toList();
                  
                  if (logoContents.isNotEmpty) {
                    final logoContent = logoContents.first;
                    
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.network(
                            logoContent.image,
                            width: isSmallScreen ? 100 : 150,
                            height: isSmallScreen ? 100 : 150,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 50,
                              );
                            },
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
                  }
                }
                return const SizedBox.shrink();
              },
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
