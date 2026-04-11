class UserModel {
  final String  id;
  final String  username;
  final String? displayName;
  final String? avatarUrl;
  bool isOnline;

  UserModel({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.isOnline = false,
  });

  String get name =>
      (displayName != null && displayName!.isNotEmpty) ? displayName! : username;
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:          json['id']?.toString() ?? '',
      username:    json['username'] ?? '',
      displayName: json['display_name'] ?? json['displayName'],
      avatarUrl:   json['avatar_url']   ?? json['avatarUrl'],
      isOnline:    json['is_online']    ?? json['isOnline'] ?? false,
    );
  }

  UserModel copyWith({String? displayName, String? avatarUrl, bool? isOnline}) {
    return UserModel(
      id:          id,
      username:    username,
      displayName: displayName ?? this.displayName,
      avatarUrl:   avatarUrl   ?? this.avatarUrl,
      isOnline:    isOnline    ?? this.isOnline,
    );
  }
}
