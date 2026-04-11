class MessageModel {
  final String   id;
  final String   senderId;
  final String   receiverId;
  final String   content;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id:         json['id']?.toString() ?? '',
      senderId:   json['sender_id']?.toString()  ?? '',
      receiverId: json['receiver_id']?.toString() ?? '',
      content:    json['content'] ?? '',
      timestamp:  json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
