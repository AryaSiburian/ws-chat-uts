import 'package:flutter/material.dart';
import 'presentation/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSystem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B263B), 
          brightness: Brightness.dark, // Agar UTS-mu terlihat modern dengan Dark Mode
        ),
        useMaterial3: true,
      ),
      // Halaman pertama yang dibuka adalah SplashPage
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const PlaceholderHomePage(),
      },
    );
  }
}

// Sementara pakai placeholder dulu, nanti ganti dengan halaman asli
class PlaceholderHomePage extends StatelessWidget {
  const PlaceholderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Center(
        child: Text(
          'Home Page',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}