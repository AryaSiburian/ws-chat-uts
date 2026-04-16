import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/splash_screen.dart';
import 'theme/theme_controller.dart';
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.init(); // baca tema tersimpan dari SharedPreferences
  await ApiClient().init(); // Inisialisasi Cookie Manager
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Signal',
          debugShowCheckedModeBanner: false,
          themeMode: mode,

          // ── LIGHT THEME ──────────────────────────────────────────
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2C6BED),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFFFFFFF),
            textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
          ),

          // ── DARK THEME ───────────────────────────────────────────
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2C6BED),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}