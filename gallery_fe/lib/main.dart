import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_fe/bloc/album_bloc/album_bloc.dart';
import 'package:gallery_fe/bloc/album_bloc/album_event.dart';
import 'package:gallery_fe/bloc/category_bloc/category_bloc.dart';
import 'package:gallery_fe/bloc/category_bloc/category_event.dart';
import 'package:gallery_fe/bloc/contentBlok_bloc/contentblock_bloc.dart';
import 'package:gallery_fe/bloc/contentBlok_bloc/contentblock_event.dart';
import 'package:gallery_fe/bloc/page_bloc/page_bloc.dart';
import 'package:gallery_fe/bloc/page_bloc/page_event.dart';
import 'package:gallery_fe/bloc/photo_bloc/photo_bloc.dart';
import 'package:gallery_fe/bloc/photo_bloc/photo_event.dart';
import 'package:gallery_fe/bloc/users_bloc/users_bloc.dart';
import 'package:gallery_fe/bloc/users_bloc/users_event.dart';
import 'package:gallery_fe/data/repositories/album_repositories.dart';
import 'package:gallery_fe/data/repositories/category_repositories.dart';
import 'package:gallery_fe/data/repositories/contentblock_repositories.dart';
import 'package:gallery_fe/data/repositories/page_repositories.dart';
import 'package:gallery_fe/data/repositories/photo_repositories.dart';
import 'package:gallery_fe/data/repositories/users_repositories.dart';
import 'package:gallery_fe/data/repositories/analytics_repositories.dart';
import 'package:gallery_fe/bloc/analytics_bloc/analytics_bloc.dart';
import 'package:gallery_fe/bloc/analytics_bloc/analytics_event.dart';
import 'package:gallery_fe/data/repositories/dashboard_repositories.dart';
import 'package:gallery_fe/bloc/dashboard_bloc/dashboard_bloc.dart';
import 'package:gallery_fe/bloc/dashboard_bloc/dashboard_event.dart';
import 'package:gallery_fe/presentation/screens/NavbarAdmin_screens.dart';
import 'package:gallery_fe/presentation/screens/NavbarPetugas_screens.dart';
import 'package:gallery_fe/presentation/screens/SignIn_screens.dart';
import 'package:gallery_fe/presentation/screens/analytics_screen.dart';
import 'package:gallery_fe/presentation/screens/dashboard_screens.dart';
import 'package:gallery_fe/presentation/screens/manageAlbum_screens.dart';
import 'package:gallery_fe/presentation/screens/manage_Contentblock_screens.dart';
import 'package:gallery_fe/presentation/screens/managePhoto_screens.dart';
import 'package:gallery_fe/presentation/screens/managePages_screens.dart';
import 'bloc/auth_bloc/auth_bloc.dart';
import 'data/repositories/auth_repositories.dart';
import 'presentation/screens/ManageUser_screens.dart';
import 'presentation/screens/manageCategory_screens.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  final UserRepository userRepository = UserRepository();
  final AuthRepository authRepository = AuthRepository();
  final CategoryRepository categoryRepository = CategoryRepository();
  final AlbumRepository albumRepository = AlbumRepository();
  final PhotoRepository photoRepository = PhotoRepository();
  final PageRepository pageRepository = PageRepository();
  final ContentBlockRepository contentBlockRepository =
      ContentBlockRepository();
  final AnalyticsRepository analyticsRepository = AnalyticsRepository();
  final DashboardRepository dashboardRepository = DashboardRepository();

  runApp(MyApp(
    userRepository: userRepository,
    authRepository: authRepository,
    categoryRepository: categoryRepository,
    albumRepository: albumRepository,
    photoRepository: photoRepository,
    pageRepository: pageRepository,
    contentBlockRepository: contentBlockRepository,
    analyticsRepository: analyticsRepository,
    dashboardRepository: dashboardRepository,
  ));
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  final AuthRepository authRepository;
  final CategoryRepository categoryRepository;
  final AlbumRepository albumRepository;
  final PhotoRepository photoRepository;
  final PageRepository pageRepository;
  final ContentBlockRepository contentBlockRepository;
  final AnalyticsRepository analyticsRepository;
  final DashboardRepository dashboardRepository;
  const MyApp({
    super.key,
    required this.userRepository,
    required this.authRepository,
    required this.categoryRepository,
    required this.albumRepository,
    required this.photoRepository,
    required this.pageRepository,
    required this.contentBlockRepository,
    required this.analyticsRepository,
    required this.dashboardRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository),
        ),
        BlocProvider<UsersBloc>(
          create: (context) => UsersBloc(userRepository)..add(FetchUsers()),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) =>
              CategoryBloc(categoryRepository)..add(FetchCategories()),
        ),
        BlocProvider<AlbumBloc>(
          create: (context) => AlbumBloc(albumRepository, categoryRepository)
            ..add(FetchAlbums()),
        ),
        BlocProvider<PhotoBloc>(
          create: (context) =>  
              PhotoBloc(photoRepository, albumRepository)..add(FetchPhotos()),
        ),
        BlocProvider<PageBloc>(
          create: (context) => PageBloc(pageRepository)..add(FetchPages()),
        ),
        BlocProvider<ContentBlockBloc>(
          create: (context) => ContentBlockBloc(contentBlockRepository)
            ..add(FetchContentBlocks()),
        ),
        BlocProvider<AnalyticsBloc>(
          create: (context) => AnalyticsBloc(repository: analyticsRepository)
            ..add(FetchAnalyticsStats()), // Tambahkan ini
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(repository: dashboardRepository)
            ..add(FetchDashboardStats()), // Tambahkan ini
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gallery App',
        initialRoute: '/',
        routes: {
          '/': (context) => const SignInPage(),
          '/manageUsers': (context) => const ManageUsersScreen(),
          '/petugas': (context) => const ManageCategoryScreens(),
          '/manageAlbum': (context) => const ManageAlbumScreens(),
          '/managePhoto': (context) => const ManagePhotoScreen(),
          '/managePages': (context) => const ManagePagesScreen(),
          '/manageContentBlok': (context) => const ManageContentblockScreen(),
          '/analytics': (context) => const AnalyticsScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/navbarPetugas': (context) => const NavbarScreensPetugas(),
          '/navbarAdmin': (context) => const NavbaradminScreens(),
        },
      ),
    );
  }
}
