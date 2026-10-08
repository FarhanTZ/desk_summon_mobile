import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants/app_colors.dart';
import 'core/services/supabase_service.dart';
import 'features/tasks/pages/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load environment variables securely from .env (with fallback)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: Could not load .env file: $e");
  }

  // 2. Initialize Supabase via Service
  try {
    await SupabaseService.init();
  } catch (e) {
    debugPrint("Warning: Could not initialize Supabase: $e");
  }

  runApp(const DeskSummonApp());
}

// Global Custom Smooth Scroll Behavior for natural 60-120Hz physics
class SmoothScrollBehavior extends MaterialScrollBehavior {
  const SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}

class DeskSummonApp extends StatelessWidget {
  const DeskSummonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desk Summon',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const SmoothScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        splashFactory: InkSparkle.splashFactory,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryBlue,
          onPrimary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.titleText,
        ),
        // Smooth Predictive Page Transitions for Android and iOS
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          },
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
