import 'dart:ui';
import 'package:flutter/material.dart';

const kSignalBlue = Color(0xFF2C6BED);
const kBackground = Color(0xFFF4F7F6);
const kTextDark = Color(0xFF1B1B1B);
const kTextGrey = Color(0xFF5A6B75);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _hidePwd = true;
  bool _hideConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // Bagian fungsi untuk memvalidasi kelengkapan data pendaftaran sebelum memproses pembuatan akun
  Future<void> _register() async {
    if (_usernameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Username wajib diisi');
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter');
      return;
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Password tidak cocok');
      return;
    }

    setState(() { _loading = true; _error = null; });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Bagian background yang menempatkan bentuk lingkaran transparan di sudut berbeda dari halaman login agar tidak monoton
          Positioned(
            top: 100,
            right: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                color: kSignalBlue.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -80,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                color: kSignalBlue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Bagian kontainer form pendaftaran dengan BackdropFilter untuk menghasilkan blur kaca yang tembus pandang ke background
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
                          // Bagian header pendaftaran berisi icon tambah pengguna dan teks petunjuk
                          Container(
                            width: 64, height: 64,
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
                            child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 20),
                          const Text('Buat Akun',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kTextDark)),
                          const SizedBox(height: 8),
                          const Text('Daftar untuk mulai mengobrol',
                              style: TextStyle(fontSize: 14, color: kTextGrey)),
                          const SizedBox(height: 36),

                          // Bagian kolom input untuk memasukkan username dan konfirmasi kelayakan password
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
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _confirmCtrl,
                            obscureText: _hideConfirm,
                            decoration: _glassInputStyle('Konfirmasi Password', Icons.lock_reset_rounded).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_hideConfirm ? Icons.visibility_off : Icons.visibility, color: kTextGrey),
                                onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                              ),
                            ),
                            onSubmitted: (_) => _register(),
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                          ],
                          const SizedBox(height: 32),

                          // Bagian tombol untuk mensubmit pendaftaran akun ke sistem
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kSignalBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                shadowColor: kSignalBlue.withOpacity(0.5),
                              ),
                              child: _loading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
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

  // Bagian dekorasi input yang memastikan desain field pendaftaran sama persis dengan halaman login
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