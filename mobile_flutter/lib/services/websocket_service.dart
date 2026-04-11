import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/message_model.dart';
import 'auth_service.dart';

class WebSocketService {
  static const String _wsUrl = 'ws://localhost:8080/ws';
  WebSocketChannel? _channel;
  bool _connected = false;
  bool get isConnected => _connected;
  Function(MessageModel)? onMessageReceived;
  Function(String uid, bool isOnline)? onUserStatusChanged;

  Future<void> connect() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) return;
    _channel   = WebSocketChannel.connect(Uri.parse('$_wsUrl?token=$token'));
    _connected = true;
    _channel!.stream.listen(
      _onData,
      onDone:  () => _connected = false,
      onError: (_) => _connected = false,
    );
  }

  void _onData(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      if (json['type'] == 'message') {
        onMessageReceived?.call(MessageModel.fromJson(json['data'] ?? json));
      } else if (json['type'] == 'user_status') {
        onUserStatusChanged?.call(
          json['user_id']?.toString() ?? '',
          json['is_online'] as bool? ?? false,
        );
      }
    } catch (_) {}
  }

  void sendMessage(String receiverId, String content) {
    if (!_connected) return;
    _channel?.sink.add(jsonEncode({
      'type': 'message', 'receiver_id': receiverId, 'content': content,
    }));
  }

  void sendTyping(String receiverId, bool isTyping) {
    if (!_connected) return;
    _channel?.sink.add(jsonEncode({
      'type': 'typing', 'receiver_id': receiverId, 'is_typing': isTyping,
    }));
  }

  void disconnect() {
    _channel?.sink.close();
    _connected = false;
  }
}
