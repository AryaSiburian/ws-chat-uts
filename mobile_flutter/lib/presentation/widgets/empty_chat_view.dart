import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyChatView extends StatelessWidget {
  const EmptyChatView({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subColor = isDark ? Colors.white54 : Colors.grey;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.chat_bubble_2_fill,
            size: 72,
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a chat to start messaging',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your conversation will appear here.',
            style: TextStyle(color: subColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
