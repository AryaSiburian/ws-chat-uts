import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; // Untuk deteksi kIsWeb
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart'; // Wajib untuk platform native (Linux/Android)
import 'dart:io' show Platform; // Untuk deteksi OS
import 'setting_page.dart';
import '../theme/theme_controller.dart';
import '../services/api_client.dart';
import '../model/chat_user.dart';

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
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _initWS(); // Inisialisasi koneksi WebSocket menggunakan Cookie
  }

  void _initWS() async {
    try {
      final cookieString = await ApiClient().getCookieHeader();
      
      // LOGIKA OTOMATIS: 
      // 1. Web -> localhost
      // 2. Android Emulator -> 10.0.2.2
      // 3. Linux Desktop -> 127.0.0.1
      String ipAddress = "127.0.0.1";
      if (kIsWeb) {
        ipAddress = "localhost";
      } else if (Platform.isAndroid) {
        ipAddress = "10.0.2.2";
      }
      
      final wsUrl = Uri.parse("ws://$ipAddress:8080/ws");

      debugPrint("🕵️ Mencoba koneksi WS dengan Cookie: $cookieString");

      if (kIsWeb) {
        // DI WEB: Browser mengurus cookie secara otomatis
        _channel = WebSocketChannel.connect(wsUrl);
      } else {
        // DI NATIVE: Suntikkan Cookie ke header handshake
        _channel = IOWebSocketChannel.connect(
          wsUrl,
          headers: {
            if (cookieString != null && cookieString.isNotEmpty) 'Cookie': cookieString,
          },
        );
      }

      _channel?.stream.listen(
        (message) {
          debugPrint("Pesan masuk dari WS: $message");
        },
        onError: (error) {
          debugPrint("Error WebSocket: $error");
        },
        onDone: () {
          debugPrint("Koneksi WebSocket terputus.");
        }
      );
    } catch (e) {
      debugPrint("Gagal inisialisasi WebSocket: $e");
    }
  }

  @override
  void dispose() {
    _channel?.sink.close(); 
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const SettingPage()))
          .then((_) => setState(() {})); 
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = ThemeController.isDark;
    final navBg    = isDark ? _kDarkSurface : Colors.white;
    final appBarBg = isDark ? _kDarkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1B1B1B);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (_, __, ___) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 600;

            return Scaffold(
              backgroundColor: isDark ? _kDarkBg : const Color(0xFFF2F2F7),
              appBar: isDesktop
                  ? null
                  : AppBar(
                      backgroundColor: appBarBg,
                      elevation: 0,
                      centerTitle: false,
                      leading: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingPage()))
                              .then((_) => setState(() {})),
                          child: CircleAvatar(
                            backgroundColor: isDark ? _kDarkCard : const Color(0xFFE8EDF5),
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
                          icon: const Icon(CupertinoIcons.camera, color: _kBlue, size: 22),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(CupertinoIcons.pencil_circle_fill, color: _kBlue, size: 24),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
              body: Row(
                children: [
                  if (isDesktop) _buildRail(isDark, titleColor),
                  Expanded(
                    child: _selectedIndex == 0
                        ? ChatListView(isDark: isDark)
                        : _CallsView(isDark: isDark),
                  ),
                ],
              ),
              bottomNavigationBar: isDesktop
                  ? null
                  : BottomNavigationBar(
                      currentIndex: _selectedIndex,
                      onTap: _onNavTap,
                      backgroundColor: navBg,
                      selectedItemColor: _kBlue,
                      unselectedItemColor: isDark ? Colors.white54 : Colors.grey,
                      type: BottomNavigationBarType.fixed,
                      items: const [
                        BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.chat_bubble),
                            activeIcon: Icon(CupertinoIcons.chat_bubble_fill),
                            label: 'Chats'),
                        BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.phone),
                            activeIcon: Icon(CupertinoIcons.phone_fill),
                            label: 'Calls'),
                        BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.settings),
                            activeIcon: Icon(CupertinoIcons.settings_solid),
                            label: 'Settings'),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildRail(bool isDark, Color titleColor) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      backgroundColor: isDark ? _kDarkSurface : Colors.white,
      unselectedIconTheme: IconThemeData(color: isDark ? Colors.white54 : Colors.grey),
      selectedIconTheme: const IconThemeData(color: _kBlue),
      labelType: NavigationRailLabelType.all,
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
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: IconButton(
              icon: Icon(CupertinoIcons.settings, color: isDark ? Colors.white54 : Colors.grey),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const SettingPage()))
                  .then((_) => setState(() {})),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatListView extends StatelessWidget {
  final bool isDark;
  const ChatListView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg  = isDark ? _kDarkSurface : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subColor  = isDark ? Colors.white54 : const Color(0xFF8696A0);

    final List<ChatModel> chats = [
      ChatModel(id: '1', name: 'Eza Kadek', lastMessage: 'Golang: Bingung aku cuk', time: 'Sat'),
      ChatModel(id: '2', name: 'Arya Programer', lastMessage: 'Kok ez banget ya', time: '3/10', unreadCount: 1),
      ChatModel(id: '3', name: 'Tim Backend', lastMessage: 'Docker sudah jalan?', time: '10:30', unreadCount: 3),
      ChatModel(id: '4', name: 'Flutter Dev', lastMessage: 'setState vs Provider', time: 'Mon'),
    ];

    return Container(
      color: isDark ? _kDarkBg : const Color(0xFFF2F2F7),
      child: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (_, __) => Divider(height: 1, indent: 76, endIndent: 16, color: isDark ? Colors.white10 : Colors.black12),
        itemBuilder: (context, i) {
          final c = chats[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: _kBlue.withOpacity(isDark ? 0.85 : 0.9),
              child: Text(c.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
            ),
            title: Text(c.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
            subtitle: Text(c.lastMessage, style: TextStyle(color: subColor, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(c.time, style: TextStyle(color: c.unreadCount > 0 ? _kBlue : subColor, fontSize: 12)),
                if (c.unreadCount > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: _kBlue, borderRadius: BorderRadius.circular(12)),
                    child: Text('${c.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CallsView extends StatelessWidget {
  final bool isDark;
  const _CallsView({super.key, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(CupertinoIcons.phone_fill, size: 64, color: isDark ? Colors.white12 : Colors.grey.shade300),
    );
  }
}