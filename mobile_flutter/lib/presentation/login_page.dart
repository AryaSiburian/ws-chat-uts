import 'dart:ui';
import 'package:flutter/material.dart';
import 'register_page.dart';

const kSignalBlue = Color(0xFF2C6BED);
const kBackground = Color(0xFFF4F7F6);
const kTextDark = Color(0xFF1B1B1B);
const kTextGrey = Color(0xFF5A6B75);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _hidePwd = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Bagian fungsi untuk memvalidasi input dan menjalankan proses login
  Future<void> _login() async {
    if (_usernameCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Username dan password wajib diisi');
      return;
    }
    setState(() { _loading = true; _error = null; });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // Bagian background yang berisi dua lingkaran biru transparan untuk memberikan efek warna pantulan di belakang kaca form
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                color: kSignalBlue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                color: kSignalBlue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Bagian kontainer utama yang menerapkan efek kaca buram (glassmorphism) pada form menggunakan BackdropFilter
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 24,
                            spreadRadius: -5,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bagian header form yang menampilkan logo aplikasi dan teks sapaan login
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              color: kSignalBlue.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: kSignalBlue.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            ),
                            child: const Icon(Icons.chat_rounded, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 20),
                          const Text('Signal',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kTextDark)),
                          const SizedBox(height: 8),
                          const Text('Masuk ke akun kamu',
                              style: TextStyle(fontSize: 14, color: kTextGrey)),
                          const SizedBox(height: 36),

                          // Bagian input text field untuk mengisi username dan password pengguna
                          TextField(
                            controller: _usernameCtrl,
                            decoration: _glassInputStyle('Username', Icons.person_outline),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordCtrl,
                            obscureText: _hidePwd,
                            decoration: _glassInputStyle('Password', Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_hidePwd ? Icons.visibility_off : Icons.visibility, color: kTextGrey),
                                onPressed: () => setState(() => _hidePwd = !_hidePwd),
                              ),
                            ),
                            onSubmitted: (_) => _login(),
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                          ],
                          const SizedBox(height: 32),

                          // Bagian eksekusi utama berisi tombol login dan navigasi pindah ke halaman pendaftaran
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kSignalBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                shadowColor: kSignalBlue.withOpacity(0.5),
                              ),
                              child: _loading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Belum punya akun? ', style: TextStyle(color: kTextGrey)),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                                child: const Text('Daftar', style: TextStyle(color: kSignalBlue, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  // Bagian dekorasi kustom untuk memastikan semua TextField memiliki tampilan kaca transparan yang seragam
  InputDecoration _glassInputStyle(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: kTextGrey),
      prefixIcon: Icon(icon, color: kTextGrey, size: 22),
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kSignalBlue, width: 1.5),
      ),
    );
  }
}