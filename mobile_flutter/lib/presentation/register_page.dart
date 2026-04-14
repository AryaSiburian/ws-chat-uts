import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const kSignalBlue  = Color(0xFF2C6BED);
const kBackground  = Color(0xFFFFFFFF);
const kTextDark    = Color(0xFF1B1B1B);
const kTextGrey    = Color(0xFF8696A0);
const kInputBorder = Color(0xFFD1D7DB);
const kBaseUrl     = 'http://localhost:8080';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool    _hidePwd     = true;
  bool    _hideConfirm = true;
  bool    _loading     = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validasi
    if (_usernameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Username wajib diisi');
      return;
    }
    if (!_emailCtrl.text.contains('@')) {
      setState(() => _error = 'Format email tidak valid');
      return;
    }
    if (_passwordCtrl.text.length < 8) {
      setState(() => _error = 'Password minimal 8 karakter');
      return;
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Password tidak cocok');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      // POST /api/auth/register — sesuai routes.go temanmu
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameCtrl.text.trim(),
          'email':    _emailCtrl.text.trim(),
          'password': _passwordCtrl.text,
        }),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat! Silakan login.'),
            backgroundColor: kSignalBlue,
          ),
        );
        Navigator.pop(context); // kembali ke login
      } else {
        setState(() => _error = data['Message'] ?? data['message'] ?? 'Pendaftaran gagal');
      }
    } catch (e) {
      setState(() => _error = 'Tidak bisa terhubung ke server.\nPastikan Docker sudah berjalan.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: const BoxDecoration(
                    color: kSignalBlue, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add_rounded,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 20),

                const Text('Buat Akun', style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w700, color: kTextDark)),
                const SizedBox(height: 8),
                const Text('Daftar untuk mulai mengobrol',
                    style: TextStyle(fontSize: 14, color: kTextGrey)),
                const SizedBox(height: 36),

                // Username
                TextField(
                  controller: _usernameCtrl,
                  decoration: _inputStyle('Username'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // Email
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputStyle('Email'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // Password
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _hidePwd,
                  decoration: _inputStyle('Password (min. 8 karakter)').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_hidePwd
                          ? Icons.visibility_off : Icons.visibility,
                          color: kTextGrey),
                      onPressed: () => setState(() => _hidePwd = !_hidePwd),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // Konfirmasi password
                TextField(
                  controller: _confirmCtrl,
                  obscureText: _hideConfirm,
                  decoration: _inputStyle('Konfirmasi Password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_hideConfirm
                          ? Icons.visibility_off : Icons.visibility,
                          color: kTextGrey),
                      onPressed: () =>
                          setState(() => _hideConfirm = !_hideConfirm),
                    ),
                  ),
                  onSubmitted: (_) => _register(),
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

                // Tombol daftar
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
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
                        : const Text('Daftar', style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Sudah punya akun? ',
                      style: TextStyle(color: kTextGrey)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Masuk', style: TextStyle(
                        color: kSignalBlue, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 20),
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