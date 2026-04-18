import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter/model/chat_user.dart';
import 'package:mobile_flutter/presentation/widgets/empty_chat_view.dart';

class ChatDetailView extends StatefulWidget {
  const ChatDetailView({
    super.key,
    required this.isDark,
    required this.selectedChat,
  });

  final bool isDark;
  final ChatModel? selectedChat;

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  static const _kDarkBg = Color(0xFF121212);
  static const _kDarkSurface = Color(0xFF1E1E1E);

  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onSend() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    debugPrint('send message: $message');
    _messageController.clear();
  }

  void _onPickImage() {
    debugPrint('pick image');
  }

  Widget _buildChatHeader({required bool isMobile}) {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subColor = widget.isDark ? Colors.white54 : Colors.grey;
    final borderColor = widget.isDark ? Colors.white12 : const Color(0xFFEFEFEF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(CupertinoIcons.back, color: textColor),
            ),
          CircleAvatar(
            radius: 22,
            child: Text((widget.selectedChat?.name ?? 'C')[0].toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedChat?.name ?? 'Chats',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.selectedChat == null
                      ? 'Select a conversation'
                      : 'Last message at ${widget.selectedChat!.time}',
                  style: TextStyle(color: subColor, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(CupertinoIcons.phone, color: subColor),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final borderColor = widget.isDark ? Colors.white12 : const Color(0xFFEFEFEF);
    final inputBg = widget.isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF6F6F6);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: widget.isDark ? _kDarkSurface : Colors.white,
        border: Border(
          top: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Text('😊', style: TextStyle(fontSize: 22)),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _onSend(),
                decoration: InputDecoration(
                  hintText: 'Message',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: widget.isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: _onPickImage,
            icon: Icon(
              CupertinoIcons.add,
              color: widget.isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFF0A84FF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _onSend,
              icon: const Icon(CupertinoIcons.paperplane_fill, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea() {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subColor = widget.isDark ? Colors.white54 : Colors.grey;

    if (widget.selectedChat == null) {
      return Center(
        child: Text(
          'No messages yet',
          style: TextStyle(color: subColor, fontSize: 15),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF2B2B2B) : const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              widget.selectedChat!.lastMessage,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: Column(
        children: [
          _buildChatHeader(isMobile: true),
          Expanded(child: _buildMessagesArea()),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final panelBg = widget.isDark ? _kDarkSurface : Colors.white;
    final splitBg = widget.isDark ? _kDarkBg : const Color(0xFFF2F2F7);
    final borderColor = widget.isDark ? Colors.white12 : const Color(0xFFEFEFEF);

    return SafeArea(
      child: Container(
        color: splitBg,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: panelBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildChatHeader(isMobile: false),
                    Expanded(child: _buildMessagesArea()),
                    _buildInputBar(),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: panelBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: borderColor),
                ),
                child: widget.selectedChat == null
                    ? EmptyChatView(isDark: widget.isDark)
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Conversation info',
                              style: TextStyle(
                                color: widget.isDark ? Colors.white : const Color(0xFF1B1B1B),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Use this panel for profile, shared media, and member settings.',
                              style: TextStyle(
                                color: widget.isDark ? Colors.white60 : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: widget.isDark ? const Color(0xFF242424) : const Color(0xFFF7F7F9),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _InfoRow(
                                      isDark: widget.isDark,
                                      icon: CupertinoIcons.person_crop_circle,
                                      label: 'Profile details',
                                    ),
                                    const SizedBox(height: 12),
                                    _InfoRow(
                                      isDark: widget.isDark,
                                      icon: CupertinoIcons.photo_on_rectangle,
                                      label: 'Shared media',
                                    ),
                                    const SizedBox(height: 12),
                                    _InfoRow(
                                      isDark: widget.isDark,
                                      icon: CupertinoIcons.bell,
                                      label: 'Notification preferences',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? _kDarkBg : const Color(0xFFF2F2F7);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.isDark,
    required this.icon,
    required this.label,
  });

  final bool isDark;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFEFEFEF)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1B1B1B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
