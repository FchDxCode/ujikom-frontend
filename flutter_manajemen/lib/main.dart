import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import Bloc dan Repository
import 'package:luminova/bloc/album_bloc/album_bloc.dart';
import 'package:luminova/bloc/category_bloc/category_bloc.dart';
import 'package:luminova/bloc/contentBlok_bloc/contentblock_bloc.dart';
import 'package:luminova/bloc/page_bloc/page_bloc.dart';
import 'package:luminova/bloc/photo_bloc/photo_bloc.dart';
import 'package:luminova/bloc/users_bloc/users_bloc.dart';
import 'package:luminova/bloc/analytics_bloc/analytics_bloc.dart';
import 'package:luminova/bloc/dashboard_bloc/dashboard_bloc.dart';
import 'package:luminova/bloc/auth_bloc/auth_bloc.dart';

// Import Repositories
import 'package:luminova/data/repositories/album_repositories.dart';
import 'package:luminova/data/repositories/category_repositories.dart';
import 'package:luminova/data/repositories/contentblock_repositories.dart';
import 'package:luminova/data/repositories/page_repositories.dart';
import 'package:luminova/data/repositories/photo_repositories.dart';
import 'package:luminova/data/repositories/users_repositories.dart';
import 'package:luminova/data/repositories/analytics_repositories.dart';
import 'package:luminova/data/repositories/dashboard_repositories.dart';
import 'package:luminova/data/repositories/auth_repositories.dart';

// Import Screens
import 'package:luminova/presentation/screens/NavbarAdmin_screens.dart';
import 'package:luminova/presentation/screens/NavbarPetugas_screens.dart';
import 'package:luminova/presentation/screens/SignIn_screens.dart';
import 'package:luminova/presentation/screens/analytics_screen.dart';
import 'package:luminova/presentation/screens/dashboard_screens.dart';
import 'package:luminova/presentation/screens/manageAlbum_screens.dart';
import 'package:luminova/presentation/screens/manage_Contentblock_screens.dart';
import 'package:luminova/presentation/screens/managePhoto_screens.dart';
import 'package:luminova/presentation/screens/managePages_screens.dart';
import 'package:luminova/presentation/screens/ManageUser_screens.dart';
import 'package:luminova/presentation/screens/manageCategory_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi file .env dengan error handling
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(AuthRepository()),
        ),
        BlocProvider<UsersBloc>(
          create: (context) => UsersBloc(UserRepository()), 
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(CategoryRepository()),
        ),
        BlocProvider<AlbumBloc>(
          create: (context) =>
              AlbumBloc(AlbumRepository(), CategoryRepository()),
        ),
        BlocProvider<PhotoBloc>(
          create: (context) =>
              PhotoBloc(PhotoRepository(), AlbumRepository()),
        ),
        BlocProvider<PageBloc>(
          create: (context) => PageBloc(PageRepository()),
        ),
        BlocProvider<ContentBlockBloc>(
          create: (context) => ContentBlockBloc(ContentBlockRepository()),
        ),
        BlocProvider<AnalyticsBloc>(
          create: (context) => AnalyticsBloc(repository: AnalyticsRepository()),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) =>
              DashboardBloc(repository: DashboardRepository()),
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
