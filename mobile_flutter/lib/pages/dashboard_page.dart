import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/app_colors.dart';
import '../config/app_sizes.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/websocket_service.dart';
import '../utils/responsive_helper.dart';
import 'chat_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  UserModel?       _me;
  List<UserModel>  _users   = [];
  bool             _loading = true;
  final _ws = WebSocketService();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadData();
    _connectWs();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _ws.disconnect();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final me    = await UserService.getMyProfile();
      final users = await UserService.getAllUsers();
      if (!mounted) return;
      setState(() {
        _me      = me;
        _users   = users.where((u) => u.id != me.id).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _connectWs() async {
    try {
      await _ws.connect();
      _ws.onUserStatusChanged = (uid, online) {
        if (!mounted) return;
        setState(() {
          final i = _users.indexWhere((u) => u.id == uid);
          if (i != -1) _users[i] = _users[i].copyWith(isOnline: online);
        });
      };
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(phone: _buildPhone, web: _buildWeb);
  }

  Widget _buildPhone(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatWave'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Pesan'),
            Tab(icon: Icon(Icons.person_outline),      text: 'Profil'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(controller: _tabs,
              children: [_buildContactList(), _buildProfilePanel()]),
    );
  }

  Widget _buildWeb(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        SizedBox(
          width: AppSizes.sidebarWidth,
          child: Column(children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              decoration: const BoxDecoration(color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.divider))),
              child: Row(children: [
                const Text('ChatWave', style: TextStyle(fontSize: AppSizes.fontXl,
                    fontWeight: FontWeight.w800, color: AppColors.primary)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.logout),
                    color: AppColors.textSecondary, onPressed: _logout),
              ]),
            ),
            if (_me != null) _buildMiniProfile(),
            Expanded(child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _buildContactList()),
          ]),
        ),
        const VerticalDivider(width: 1, color: AppColors.divider),
        Expanded(
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textHint),
            const SizedBox(height: AppSizes.md),
            Text('Pilih kontak untuk mulai chat',
                style: TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontLg)),
          ])),
        ),
      ]),
    );
  }

  Widget _buildContactList() {
    if (_users.isEmpty) {
      return Center(child: Text('Belum ada kontak',
          style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (_, i) {
        final user = _users[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, vertical: AppSizes.xs),
          leading: _buildAvatar(user, AppSizes.avatarMd),
          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(user.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: user.isOnline ? AppColors.online : AppColors.textHint,
                fontSize: AppSizes.fontSm)),
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ChatPage(partner: user, ws: _ws, myId: _me?.id ?? ''),
          )),
        );
      },
    );
  }

  Widget _buildMiniProfile() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: const BoxDecoration(color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.divider))),
      child: Row(children: [
        CircleAvatar(radius: AppSizes.avatarSm / 2, backgroundColor: AppColors.primary,
            child: Text(_me?.initial ?? '?',
                style: const TextStyle(color: Colors.white))),
        const SizedBox(width: AppSizes.md),
        Expanded(child: Text(_me?.name ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600))),
        IconButton(icon: const Icon(Icons.edit_outlined),
            color: AppColors.textSecondary, onPressed: _showEditSheet),
      ]),
    );
  }

  Widget _buildProfilePanel() {
    if (_me == null) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(children: [
        const SizedBox(height: AppSizes.lg),
        Stack(alignment: Alignment.bottomRight, children: [
          _buildAvatar(_me!, AppSizes.avatarXl),
          GestureDetector(onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.xs),
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            )),
        ]),
        const SizedBox(height: AppSizes.lg),
        Text(_me!.name, style: const TextStyle(fontSize: AppSizes.fontXxl,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text('@${_me!.username}',
            style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: AppSizes.xxl),
        ElevatedButton.icon(onPressed: _showEditSheet,
            icon: const Icon(Icons.edit), label: const Text('Edit Profil')),
      ]),
    );
  }

  Widget _buildAvatar(UserModel user, double size) {
    return Stack(children: [
      CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.primaryLight,
        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null
            ? Text(user.initial, style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.w600, fontSize: size * 0.35))
            : null,
      ),
      Positioned(right: 0, bottom: 0,
        child: Container(width: size * 0.28, height: size * 0.28,
          decoration: BoxDecoration(
            color: user.isOnline ? AppColors.online : AppColors.offline,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ))),
    ]);
  }

  void _showEditSheet() {
    final ctrl = TextEditingController(text: _me?.displayName ?? '');
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl))),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(left: AppSizes.lg, right: AppSizes.lg,
            top: AppSizes.lg,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + AppSizes.lg),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Edit Profil', style: TextStyle(fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSizes.lg),
          TextField(controller: ctrl, autofocus: true,
              decoration: const InputDecoration(labelText: 'Nama Tampil',
                  prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: AppSizes.lg),
          ElevatedButton(
            onPressed: () async {
              final newName = ctrl.text.trim();
              Navigator.pop(sheetCtx);
              try {
                final updated = await UserService.updateDisplayName(newName);
                if (!mounted) return;
                setState(() => _me = updated);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil berhasil diupdate!')));
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e')));
              }
            },
            child: const Text('Simpan'),
          ),
          const SizedBox(height: AppSizes.sm),
        ]),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 80);
    if (picked == null) return;
    try {
      final url = await UserService.uploadAvatar(await picked.readAsBytes(), picked.name);
      if (!mounted) return;
      setState(() => _me = _me?.copyWith(avatarUrl: url));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  Future<void> _logout() async {
    _ws.disconnect();
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }
}
