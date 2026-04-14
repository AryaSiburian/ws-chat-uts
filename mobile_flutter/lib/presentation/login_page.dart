import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';

const kSignalBlue  = Color(0xFF2C6BED);
const kBackground  = Color(0xFFFFFFFF);
const kTextDark    = Color(0xFF1B1B1B);
const kTextGrey    = Color(0xFF8696A0);
const kInputBorder = Color(0xFFD1D7DB);

// URL backend — sesuai docker-compose port 8080
const kBaseUrl = 'http://localhost:8080';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool    _hidePwd = true;
  bool    _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Validasi sederhana
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      // POST /api/auth/login — sesuai routes.go temanmu
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email':    _emailCtrl.text.trim(),
          'password': _passwordCtrl.text,
        }),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        // Simpan token JWT ke local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token'] ?? '');

        if (!mounted) return;
        // TODO: ganti ke halaman dashboard nanti
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil!'),
            backgroundColor: kSignalBlue,
          ),
        );
      } else {
        // Tampilkan pesan error dari backend
        setState(() => _error = data['Message'] ?? data['message'] ?? 'Login gagal');
      }
    } catch (e) {
      setState(() => _error = 'Terjadi Kesalahan Koneksi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 72, height: 72,
                  decoration: const BoxDecoration(
                    color: kSignalBlue, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_rounded,
                      color: Colors.white, size: 38),
                ),
                const SizedBox(height: 20),

                const Text('Signal', style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w700, color: kTextDark)),
                const SizedBox(height: 8),
                const Text('Masuk ke akun kamu', style: TextStyle(
                    fontSize: 14, color: kTextGrey)),
                const SizedBox(height: 36),

                // Input email
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputStyle('Email'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // Input password
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _hidePwd,
                  decoration: _inputStyle('Password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_hidePwd
                          ? Icons.visibility_off : Icons.visibility,
                          color: kTextGrey),
                      onPressed: () => setState(() => _hidePwd = !_hidePwd),
                    ),
                  ),
                  onSubmitted: (_) => _login(),
                ),

                // Error
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!,
                          style: const TextStyle(color: Colors.red, fontSize: 13))),
                    ]),
                  ),
                ],
                const SizedBox(height: 24),

                // Tombol masuk
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSignalBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Masuk', style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),

                // Link ke Register
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Belum punya akun? ',
                      style: TextStyle(color: kTextGrey)),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegisterPage())),
                    child: const Text('Daftar', style: TextStyle(
                        color: kSignalBlue, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: kTextGrey),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kInputBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kInputBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kSignalBlue, width: 1.5)),
    );
  }
}