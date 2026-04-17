import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_flutter/theme/theme_controller.dart';
import 'package:mobile_flutter/services/api_client.dart';
import 'package:dio/dio.dart';
import 'auth/login_page.dart';

const _kBlue = Color(0xFF2C6BED);

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _email = '';
  String _userId = '';
  String _username = 'Signal User';
  String _bio = 'Belum ada bio';
  String _avatar = '';
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email') ?? 'pengguna@signal.com';
      _userId = prefs.getString('user_id') ?? '';
      _isDark = ThemeController.isDark;
    });
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await ApiClient().dio.get('/api/profile/me');
      if (response.statusCode == 200) {
        setState(() {
          _username = response.data['username'] ?? _username;
          _bio = response.data['bio'] ?? _bio;
          _avatar = response.data['avatar'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Gagal load profil: $e");
    }
  }

  Future<void> _updateProfile(String newUsername, String newBio, String newAvatar) async {
    if (_userId.isEmpty) return;

    try {
      final standaloneDio = Dio(BaseOptions(
        baseUrl: "http://localhost:8080/",
        connectTimeout: const Duration(seconds: 5),
      ));

      Map<String, dynamic> dataUpdate = {
        'username': newUsername,
        'bio': newBio,
        'avatar': newAvatar,
      };

      final response = await standaloneDio.patch(
        'patch/update/$_userId',
        data: dataUpdate,
      );

      if (response.statusCode == 200) {
        setState(() {
          _username = newUsername;
          _bio = newBio;
          _avatar = newAvatar;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  void _showEditDialog() {
    final usernameCtrl = TextEditingController(text: _username);
    final bioCtrl = TextEditingController(text: _bio);
    final avatarCtrl = TextEditingController(text: _avatar);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Profil'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: usernameCtrl,
                        maxLength: 25,
                        onChanged: (val) => setDialogState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Username',
                          counterText: "${usernameCtrl.text.length}/25",
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: bioCtrl,
                        maxLength: 25,
                        onChanged: (val) => setDialogState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          counterText: "${bioCtrl.text.length}/25",
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: avatarCtrl,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          labelText: 'URL Avatar (JPG/PNG)',
                          hintText: "https://example.com/image.png",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _kBlue),
                  onPressed: () {
                    _updateProfile(usernameCtrl.text, bioCtrl.text, avatarCtrl.text);
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subColor = isDark ? Colors.white54 : const Color(0xFF8696A0);
    final initial = _username.isNotEmpty ? _username[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        title: Text('Settings', style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 20)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Profil', subColor),
            _card(
              cardBg: cardBg,
              child: Column(
                children: [
                  Row(
                    children: [
                      // --- PERBAIKAN: HANDLING GAMBAR TRANSPARAN ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          width: 64, height: 64,
                          // Background BIRU hanya muncul jika tidak ada foto (untuk inisial nama)
                          // Jika ada foto, background dibuat TRANSPARAN agar PNG terlihat rapi
                          decoration: BoxDecoration(
                            color: _avatar.isEmpty ? _kBlue : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: _avatar.isEmpty 
                            ? Center(child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700))) 
                            : Image.network(
                                _avatar,
                                fit: BoxFit.cover,
                                // Handling jika gambar sedang dimuat atau error
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.white24 : Colors.black12));
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: _kBlue,
                                  child: Center(child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700))),
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_username, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(_email, style: TextStyle(color: subColor, fontSize: 13), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.edit, color: _kBlue), onPressed: _showEditDialog)
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF262626) : const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(10)),
                    child: Text(_bio, style: TextStyle(color: textColor, fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionLabel('Appearance', subColor),
            _card(
              cardBg: cardBg,
              child: Row(
                children: [
                  Container(width: 38, height: 38, decoration: BoxDecoration(color: isDark ? Colors.indigo.shade900 : Colors.amber.shade100, borderRadius: BorderRadius.circular(10)), child: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: isDark ? Colors.indigoAccent : Colors.amber, size: 22)),
                  const SizedBox(width: 14),
                  Expanded(child: Text('Dark Mode', style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500))),
                  Switch.adaptive(value: isDark, activeColor: _kBlue, onChanged: (val) async { await ThemeController.setDark(val); setState(() => _isDark = val); }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionLabel('Akun', subColor),
            _card(
              cardBg: cardBg,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _signOut,
                child: Row(
                  children: [
                    Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20)),
                    const SizedBox(width: 14),
                    const Expanded(child: Text('Sign Out', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w500))),
                    const Icon(Icons.chevron_right, color: Colors.red, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, Color color) => Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)));
  Widget _card({required Widget child, required Color cardBg}) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]), child: child);

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
  }
}