import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/theme_config.dart'; // IMPORT INI
import 'register_page.dart';

const kSignalBlue = Color(0xFF2C6BED);
const kBaseUrl = 'http://localhost:8080';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _hidePwd = true;
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailCtrl.text.trim(), 'password': _passwordCtrl.text}),
      );
      if (response.statusCode == 200) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Berhasil!')));
      } else {
        setState(() => _error = 'Login gagal');
      }
    } catch (e) {
      setState(() => _error = 'Gagal terhubung ke server');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, dark, child) {
        return Scaffold(
          body: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: dark 
                      ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
                      : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                right: 20,
                child: IconButton(
                  icon: Icon(dark ? Icons.light_mode : Icons.dark_mode, 
                        color: dark ? Colors.orangeAccent : Colors.indigo, size: 30),
                  onPressed: () => isDarkMode.value = !isDarkMode.value,
                ),
              ),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: dark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('CHAT UTS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
                          const SizedBox(height: 30),
                          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                          const SizedBox(height: 10),
                          _buildTextField(_emailCtrl, 'Email', Icons.email, dark),
                          const SizedBox(height: 20),
                          _buildTextField(_passwordCtrl, 'Password', Icons.lock, dark, obscure: _hidePwd),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(backgroundColor: kSignalBlue),
                              child: const Text('LOG IN', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                            child: Text('Register Account', style: TextStyle(color: dark ? Colors.cyanAccent : Colors.blue.shade900)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, bool dark, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: TextStyle(color: dark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: dark ? Colors.white70 : Colors.black54),
        hintText: label,
        hintStyle: TextStyle(color: dark ? Colors.white38 : Colors.black38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.cyanAccent)),
      ),
    );
  }
}