import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_flutter/theme/theme_controller.dart';
import 'auth/login_page.dart';

const _kBlue = Color(0xFF2C6BED);

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _email = '';
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email  = prefs.getString('email') ?? 'pengguna@signal.com';
      _isDark = ThemeController.isDark;
    });
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = ThemeController.isDark;
    final bg      = isDark ? const Color(0xFF121212) : const Color(0xFFF2F2F7);
    final cardBg  = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subColor  = isDark ? Colors.white54 : const Color(0xFF8696A0);

    // Initial avatar dari email
    final initial = _email.isNotEmpty ? _email[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        title: Text('Settings',
            style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 20)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PROFIL ──────────────────────────────────────────────────
            _sectionLabel('Profil', subColor),
            _card(
              cardBg: cardBg,
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [_kBlue, Color(0xFF1A56D6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(initial,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_email,
                            style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('Signal User',
                            style: TextStyle(
                                color: subColor, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── APPEARANCE ──────────────────────────────────────────────
            _sectionLabel('Appearance', subColor),
            _card(
              cardBg: cardBg,
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.indigo.shade900
                          : Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: isDark ? Colors.indigoAccent : Colors.amber,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dark Mode',
                            style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(isDark ? 'Aktif' : 'Nonaktif',
                            style: TextStyle(color: subColor, fontSize: 12)),
                      ],
                    ),
                  ),
                  // Switch
                  Switch.adaptive(
                    value: isDark,
                    activeColor: _kBlue,
                    onChanged: (val) async {
                      await ThemeController.setDark(val);
                      setState(() => _isDark = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── AKUN ────────────────────────────────────────────────────
            _sectionLabel('Akun', subColor),
            _card(
              cardBg: cardBg,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _signOut,
                child: Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: Colors.red, size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text('Sign Out',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Colors.red, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Center(
              child: Text('Signal v1.0.0',
                  style: TextStyle(color: subColor, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  Widget _sectionLabel(String label, Color color) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(label.toUpperCase(),
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
      );

  Widget _card({required Widget child, required Color cardBg}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: child,
      );
}