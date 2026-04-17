import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter/model/chat_user.dart';
import 'package:mobile_flutter/presentation/widgets/empty_chat_view.dart';

class ChatDetailView extends StatelessWidget {
  const ChatDetailView({
    super.key,
    required this.isDark,
    required this.selectedChat,
  });

  final bool isDark;
  final ChatModel? selectedChat;

  static const _kDarkBg = Color(0xFF121212);
  static const _kDarkSurface = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? _kDarkBg : const Color(0xFFF2F2F7);
    final surfaceBg = isDark ? _kDarkSurface : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subColor = isDark ? Colors.white54 : Colors.grey;

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: bg,
      child: Container(
        color: surfaceBg,
        child: selectedChat == null
            ? EmptyChatView(isDark: isDark)
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.white12 : const Color(0xFFEFEFEF),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        
                        if (isMobile)
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(CupertinoIcons.back),
                          ),

                        CircleAvatar(
                          radius: 22,
                          child: Text(selectedChat!.name[0].toUpperCase()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedChat!.name,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Last message at ${selectedChat!.time}',
                                style: TextStyle(color: subColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Icon(CupertinoIcons.phone, color: subColor),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          selectedChat!.lastMessage,
                          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
