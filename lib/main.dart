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

class DeskSummonApp extends StatelessWidget {
  const DeskSummonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desk Summon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Segoe UI',
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryBlue,
          onPrimary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.titleText,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
