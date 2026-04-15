import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_flutter/model/chat_user.dart';
import 'setting_page.dart';
import '../theme/theme_controller.dart';

// ─── WARNA SIGNAL ────────────────────────────────────────────────────────────
const _kBlue        = Color(0xFF2C6BED);
const _kDarkBg      = Color(0xFF121212);
const _kDarkSurface = Color(0xFF1E1E1E);
const _kDarkCard    = Color(0xFF262626);

class ChatDashboardScreen extends StatefulWidget {
  const ChatDashboardScreen({super.key});
  @override
  State<ChatDashboardScreen> createState() => _ChatDashboardScreenState();
}

class _ChatDashboardScreenState extends State<ChatDashboardScreen> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    if (index == 2) {
      // Index 2 = Settings → buka halaman setting
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const SettingPage()))
          .then((_) => setState(() {})); // refresh setelah balik (tema bisa berubah)
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = ThemeController.isDark;
    final navBg    = isDark ? _kDarkSurface : Colors.white;
    final appBarBg = isDark ? _kDarkSurface : Colors.white;
    final selColor = _kBlue;
    final unselColor = isDark ? Colors.white54 : Colors.grey;
    final titleColor = isDark ? Colors.white : const Color(0xFF1B1B1B);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (_, __, ___) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 600;

            return Scaffold(
              backgroundColor:
                  isDark ? _kDarkBg : const Color(0xFFF2F2F7),
              appBar: isDesktop
                  ? null
                  : AppBar(
                      backgroundColor: appBarBg,
                      elevation: 0,
                      centerTitle: false,
                      // Avatar kiri
                      leading: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingPage()))
                              .then((_) => setState(() {})),
                          child: CircleAvatar(
                            backgroundColor:
                                isDark ? _kDarkCard : const Color(0xFFE8EDF5),
                            child: Icon(CupertinoIcons.person_fill,
                                color: isDark ? Colors.white54 : _kBlue,
                                size: 18),
                          ),
                        ),
                      ),
                      title: Text('Signal',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              fontSize: 20)),
                      actions: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(CupertinoIcons.camera,
                              color: _kBlue, size: 22),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(CupertinoIcons.pencil_circle_fill,
                              color: _kBlue, size: 24),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
              body: Row(
                children: [
                  if (isDesktop)
                    _buildRail(isDark, unselColor, titleColor),
                  Expanded(
                    child: _selectedIndex == 0
                        ? ChatListView(isDark: isDark)
                        : _CallsView(isDark: isDark),
                  ),
                ],
              ),
              // ── BOTTOM NAV (mobile) — 3 item termasuk Settings ──────
              bottomNavigationBar: isDesktop
                  ? null
                  : BottomNavigationBar(
                      currentIndex: _selectedIndex,
                      onTap: _onNavTap,
                      backgroundColor: navBg,
                      selectedItemColor: selColor,
                      unselectedItemColor: unselColor,
                      selectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 11),
                      unselectedLabelStyle:
                          const TextStyle(fontSize: 11),
                      elevation: 0,
                      type: BottomNavigationBarType.fixed,
                      items: const [
                        BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.chat_bubble),
                            activeIcon:
                                Icon(CupertinoIcons.chat_bubble_fill),
                            label: 'Chats'),
                        BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.phone),
                            activeIcon:
                                Icon(CupertinoIcons.phone_fill),
                            label: 'Calls'),
                        BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.settings),
                            activeIcon:
                                Icon(CupertinoIcons.settings_solid),
                            label: 'Settings'),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  // ── DESKTOP NAVIGATION RAIL ───────────────────────────────────────────────
  Widget _buildRail(bool isDark, Color unsel, Color titleColor) {
    final railBg = isDark ? _kDarkSurface : Colors.white;

    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      backgroundColor: railBg,
      unselectedIconTheme: IconThemeData(color: unsel),
      selectedIconTheme: const IconThemeData(color: _kBlue),
      unselectedLabelTextStyle: TextStyle(color: unsel, fontSize: 11),
      selectedLabelTextStyle: const TextStyle(
          color: _kBlue, fontSize: 11, fontWeight: FontWeight.w600),
      labelType: NavigationRailLabelType.all,
      indicatorColor: _kBlue.withOpacity(0.12),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SettingPage()))
              .then((_) => setState(() {})),
          child: CircleAvatar(
            radius: 22,
            backgroundColor:
                isDark ? _kDarkCard : const Color(0xFFE8EDF5),
            child: Icon(CupertinoIcons.person_fill,
                color: isDark ? Colors.white54 : _kBlue, size: 20),
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(CupertinoIcons.chat_bubble),
          selectedIcon: Icon(CupertinoIcons.chat_bubble_fill),
          label: Text('Chats'),
        ),
        NavigationRailDestination(
          icon: Icon(CupertinoIcons.phone),
          selectedIcon: Icon(CupertinoIcons.phone_fill),
          label: Text('Calls'),
        ),
      ],
      // Settings selalu tampil di bawah rail (FIX: sebelumnya hilang saat di-kecilkan)
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(CupertinoIcons.settings,
                      color: unsel, size: 24),
                  tooltip: 'Settings',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingPage()))
                      .then((_) => setState(() {})),
                ),
                Text('Settings',
                    style: TextStyle(color: unsel, fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── CHAT LIST VIEW ───────────────────────────────────────────────────────────
class ChatListView extends StatelessWidget {
  final bool isDark;
  const ChatListView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg      = isDark ? _kDarkBg      : const Color(0xFFF2F2F7);
    final cardBg  = isDark ? _kDarkSurface : Colors.white;
    final textColor = isDark ? Colors.white     : const Color(0xFF1B1B1B);
    final subColor  = isDark ? Colors.white54   : const Color(0xFF8696A0);
    final searchBg  = isDark ? _kDarkCard : const Color(0xFFEBEEF5);
    final divider   = isDark ? Colors.white12   : const Color(0xFFEEEEEE);

    final List<ChatModel> chats = [
      ChatModel(id: '1', name: 'Eza Kadek',
          lastMessage: 'Golang: Bingung aku cuk', time: 'Sat'),
      ChatModel(id: '2', name: 'Arya Programer',
          lastMessage: 'Kok ez banget ya', time: '3/10', unreadCount: 1),
      ChatModel(id: '3', name: 'Tim Backend',
          lastMessage: 'Docker sudah jalan?', time: '10:30',
          unreadCount: 3),
      ChatModel(id: '4', name: 'Flutter Dev',
          lastMessage: 'setState vs Provider', time: 'Mon'),
    ];

    return Container(
      color: bg,
      child: Column(
        children: [
          // Search bar
          Container(
            color: cardBg,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              style: TextStyle(color: textColor, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: subColor, fontSize: 15),
                prefixIcon:
                    Icon(Icons.search_rounded, color: subColor, size: 22),
                filled: true,
                fillColor: searchBg,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),

          // List
          Expanded(
            child: Container(
              color: cardBg,
              child: ListView.separated(
                itemCount: chats.length,
                separatorBuilder: (_, __) => Divider(
                    height: 0,
                    indent: 76,
                    endIndent: 16,
                    color: divider),
                itemBuilder: (context, i) {
                  final c = chats[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    leading: _Avatar(name: c.name, isDark: isDark),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(c.name,
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(c.time,
                            style: TextStyle(
                                color: c.unreadCount > 0
                                    ? _kBlue
                                    : subColor,
                                fontSize: 12,
                                fontWeight: c.unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(c.lastMessage,
                              style: TextStyle(
                                  color: subColor, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (c.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: _kBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('${c.unreadCount}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AVATAR ───────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String name;
  final bool isDark;
  const _Avatar({required this.name, required this.isDark});

  // Warna avatar berdasarkan inisial
  static const _colors = [
    Color(0xFF2C6BED), Color(0xFF34C759), Color(0xFFFF9500),
    Color(0xFFFF2D55), Color(0xFF5856D6), Color(0xFF00C7BE),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[name.codeUnitAt(0) % _colors.length];
    return CircleAvatar(
      radius: 26,
      backgroundColor: color.withOpacity(isDark ? 0.85 : 0.9),
      child: Text(name[0].toUpperCase(),
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18)),
    );
  }
}

// ─── CALLS VIEW ───────────────────────────────────────────────────────────────
class _CallsView extends StatelessWidget {
  final bool isDark;
  const _CallsView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subColor  = isDark ? Colors.white38 : Colors.grey;

    return Container(
      color: isDark ? _kDarkBg : const Color(0xFFF2F2F7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.phone_fill,
                size: 64,
                color: isDark ? Colors.white12 : Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Belum ada panggilan',
                style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Riwayat panggilan akan muncul di sini',
                style: TextStyle(color: subColor, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}