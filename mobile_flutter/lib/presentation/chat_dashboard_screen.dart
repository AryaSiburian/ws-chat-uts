import 'package:flutter/material.dart';
import 'package:mobile_flutter/model/chat_user.dart';
import 'package:flutter/cupertino.dart';

class ChatDashboardScreen extends StatefulWidget {
  const ChatDashboardScreen({super.key});

  @override
  State<ChatDashboardScreen> createState() => _ChatDashboardScreenState();
}

class _ChatDashboardScreenState extends State<ChatDashboardScreen> {
  int _selectedIndex = 0;
  ChatModel? _selectedChat;

  // List halaman untuk navigasi
  final List<Widget> _pages = [
    const ChatListView(), // Halaman daftar chat
    const Center(child: Text("Calls Screen")), // Halaman calls
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 600;

        return Scaffold(
          // Header (AppBar) hanya muncul di mobile, di desktop biasanya masuk ke sidebar/content
          appBar: isDesktop ? null : _buildAppBar(),
          body: Row(
            children: [
              if (isDesktop) _buildNavigationRail(),
              Expanded(child: _pages[_selectedIndex]),
            ],
          ),
          bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
        );
      },
    );
  }

  //WIDGET COMPONEN HEADER
  AppBar _buildAppBar() {
  return AppBar(
    backgroundColor: Colors.black,
    elevation: 0,
    centerTitle: true,
    // Bagian Profile (Kiri)
    leading: const Padding(
      padding: EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: Color(0xFF262626), // Abu-abu gelap khas dark mode
        child: Icon(
          CupertinoIcons.person_fill, 
          color: Colors.white, 
          size: 20
        ),
      ),
    ),
    title: const Text(
      "Chats", 
      style: TextStyle(
        fontWeight: FontWeight.bold, 
        color: Colors.white,
        fontSize: 22,
      )
    ),
    // Bagian Action Icons (Kanan)
    actions: [
      // Icon Kamera
      IconButton(
        onPressed: () {},
        icon: const Icon(
          CupertinoIcons.camera, 
          color: Colors.white, 
          size: 24,
        ),
      ),
      // Icon Pensil (Tulis Pesan)
      IconButton(
        onPressed: () {},
        icon: const Icon(
          CupertinoIcons.pencil_circle_fill, // Menggunakan versi fill agar lebih mirip desain premium
          color: Colors.white, 
          size: 24,
        ),
      ),
      const SizedBox(width: 8), // Padding kecil di paling kanan
    ],
  );
}

  Widget _buildNavigationRail() {
  return NavigationRail(
    selectedIndex: _selectedIndex,
    onDestinationSelected: (index) => setState(() => _selectedIndex = index),
    backgroundColor: Colors.black,
    unselectedIconTheme: const IconThemeData(color: Colors.grey),
    selectedIconTheme: const IconThemeData(color: Colors.white),
    labelType: NavigationRailLabelType.all,
    
    // 1. Bagian Atas (Opsional: Bisa ditaruh foto profil)
    leading: const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Color(0xFF262626),
        child: Icon(CupertinoIcons.person_fill, color: Colors.white, size: 20),
      ),
    ),

    // 2. Menu Utama
    destinations: const [
      NavigationRailDestination(
        icon: Icon(CupertinoIcons.chat_bubble), 
        label: Text("Chats", style: TextStyle(color: Colors.white))
      ),
      NavigationRailDestination(
        icon: Icon(CupertinoIcons.phone), 
        label: Text("Calls", style: TextStyle(color: Colors.white))
      ),
    ],

    // 3. Bagian Paling Bawah
    trailing: Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0), // Jarak dari pinggir bawah
          child: IconButton(
            icon: const Icon(CupertinoIcons.settings, color: Colors.grey),
            onPressed: () {
              // Aksi buka setting
              print("Settings Tapped");
            },
          ),
        ),
      ),
    ),
  );
}

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chats"),
        BottomNavigationBarItem(icon: Icon(Icons.call), label: "Calls"),
      ],
    );
  }
}

// --- VIEW COMPONENTS ---
class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulasi data kosong atau list dari API
    final List<ChatModel> dummyChats = [
      ChatModel(id: "1" , name: "Eza Kadek", lastMessage: "Golang: Bingung aku cuk", time: "Sat"),
      ChatModel(id:"2" , name: "Arya Programer", lastMessage: "Kok ez banget ya", time: "3/10", unreadCount: 1),
    ];

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                fillColor: Colors.grey[900],
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          // List of Chats
          Expanded(
            child: ListView.builder(
              itemCount: dummyChats.length,
              itemBuilder: (context, index) {
                final chat = dummyChats[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[800],
                    child: Text(chat.name[0], style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(chat.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(chat.lastMessage, style: const TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(chat.time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 5),
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          child: Text(chat.unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}