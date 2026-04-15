import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/theme_config.dart'; // IMPORT INI UNTUK FIX ERROR

const kBaseUrl = 'http://localhost:8080';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _userCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'password': _passCtrl.text,
        }),
      );
      if (response.statusCode == 201) {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      debugPrint(e.toString());
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
                      ? [const Color(0xFF232526), const Color(0xFF414345)]
                      : [const Color(0xFFFFFFFF), const Color(0xFFECE9E6)],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: 400,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: dark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Join Us', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
                            const SizedBox(height: 25),
                            _buildField(_userCtrl, 'Username', Icons.person, dark),
                            const SizedBox(height: 15),
                            _buildField(_emailCtrl, 'Email', Icons.email, dark),
                            const SizedBox(height: 15),
                            _buildField(_passCtrl, 'Password', Icons.lock, dark, obscure: true),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _register,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan.shade700),
                                child: _loading 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('CREATE ACCOUNT', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Back to Login', style: TextStyle(color: dark ? Colors.cyanAccent : Colors.indigo)),
                            ),
                          ],
                        ),
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

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, bool dark, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: TextStyle(color: dark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: dark ? Colors.white70 : Colors.black54),
        hintText: label,
        hintStyle: TextStyle(color: dark ? Colors.white38 : Colors.black38),
        filled: true,
        fillColor: dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: dark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.cyan)),
      ),
    );
  }
}