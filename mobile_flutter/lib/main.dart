import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final loggedIn = await AuthService.isLoggedIn();
  runApp(ChatWaveApp(start: loggedIn ? '/dashboard' : '/login'));
}

class ChatWaveApp extends StatelessWidget {
  final String start;
  const ChatWaveApp({super.key, required this.start});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatWave',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: start,
      routes: {
        '/login':     (_) => const LoginPage(),
        '/dashboard': (_) => const DashboardPage(),
      },
    );
  }
}
