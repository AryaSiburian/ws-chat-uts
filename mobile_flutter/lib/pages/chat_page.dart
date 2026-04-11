import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../config/app_sizes.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/websocket_service.dart';
import '../utils/responsive_helper.dart';

class ChatPage extends StatefulWidget {
  final UserModel        partner;
  final WebSocketService ws;
  final String           myId;
  const ChatPage({super.key, required this.partner,
      required this.ws, required this.myId});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<MessageModel> _messages = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _listenWs();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    widget.ws.onMessageReceived = null;
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final hist = await UserService.getChatHistory(widget.partner.id);
      if (!mounted) return;
      setState(() { _messages = hist; _loadingHistory = false; });
      _scrollDown();
    } catch (_) {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  void _listenWs() {
    widget.ws.onMessageReceived = (msg) {
      if (!mounted) return;
      final relevant = msg.senderId == widget.partner.id ||
          (msg.senderId == widget.myId && msg.receiverId == widget.partner.id);
      if (relevant) {
        setState(() => _messages.add(msg));
        _scrollDown();
      }
    };
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    widget.ws.sendMessage(widget.partner.id, text);
    setState(() => _messages.add(MessageModel(
      id:         DateTime.now().millisecondsSinceEpoch.toString(),
      senderId:   widget.myId,
      receiverId: widget.partner.id,
      content:    text,
      timestamp:  DateTime.now(),
    )));
    _msgCtrl.clear();
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        titleSpacing: 0,
        title: Row(children: [
          CircleAvatar(radius: 18, backgroundColor: AppColors.primaryLight,
              child: Text(widget.partner.initial,
                  style: const TextStyle(color: Colors.white, fontSize: 14))),
          const SizedBox(width: AppSizes.md),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.partner.name,
                style: const TextStyle(fontSize: AppSizes.fontLg)),
            Text(widget.partner.isOnline ? 'Online' : 'Offline',
                style: TextStyle(fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.normal,
                    color: widget.partner.isOnline
                        ? AppColors.online : AppColors.textHint)),
          ]),
        ]),
      ),
      body: Column(children: [
        Expanded(child: _loadingHistory
            ? const Center(child: CircularProgressIndicator())
            : _buildMessages()),
        _buildInputBar(),
      ]),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return Center(child: Text('Mulai percakapan dengan ${widget.partner.name}',
          style: const TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg    = _messages[i];
        final isMine = msg.senderId == widget.myId;
        final maxW   = ResponsiveHelper.bubbleMaxWidth(context);
        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxW),
            margin: const EdgeInsets.symmetric(vertical: AppSizes.xs),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.sm),
            decoration: BoxDecoration(
              color: isMine ? AppColors.bubbleSent : AppColors.bubbleReceived,
              borderRadius: BorderRadius.only(
                topLeft:     const Radius.circular(AppSizes.radiusLg),
                topRight:    const Radius.circular(AppSizes.radiusLg),
                bottomLeft:  Radius.circular(isMine ? AppSizes.radiusLg : 4),
                bottomRight: Radius.circular(isMine ? 4 : AppSizes.radiusLg),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(msg.content, style: TextStyle(
                    color: isMine ? Colors.white : AppColors.textPrimary,
                    fontSize: AppSizes.fontMd)),
                const SizedBox(height: 2),
                Text(DateFormat('HH:mm').format(msg.timestamp),
                    style: TextStyle(fontSize: AppSizes.fontSm,
                        color: isMine
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.textHint)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(left: AppSizes.md, right: AppSizes.md,
          top: AppSizes.sm,
          bottom: MediaQuery.of(context).viewInsets.bottom > 0
              ? AppSizes.sm : AppSizes.md),
      decoration: const BoxDecoration(color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider))),
      child: SafeArea(child: Row(children: [
        Expanded(
          child: TextField(
            controller: _msgCtrl, maxLines: null,
            decoration: InputDecoration(
              hintText: 'Ketik pesan...',
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md, vertical: AppSizes.sm),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  borderSide: const BorderSide(color: AppColors.inputBorder)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  borderSide: const BorderSide(color: AppColors.inputBorder)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5)),
            ),
            onChanged: (v) =>
                widget.ws.sendTyping(widget.partner.id, v.isNotEmpty),
            onSubmitted: (_) => _send(),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        GestureDetector(onTap: _send,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          )),
      ])),
    );
  }
}
