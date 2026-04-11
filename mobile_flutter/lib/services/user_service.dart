import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/message_model.dart';
import 'auth_service.dart';

class UserService {
  static const String _base = 'http://localhost:8080';

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type':  'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<UserModel>> getAllUsers() async {
    final res = await http.get(Uri.parse('$_base/users'), headers: await _headers());
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((u) => UserModel.fromJson(u)).toList();
    }
    throw Exception('Gagal ambil daftar user');
  }

  static Future<UserModel> getMyProfile() async {
    final res = await http.get(Uri.parse('$_base/users/me'), headers: await _headers());
    if (res.statusCode == 200) return UserModel.fromJson(jsonDecode(res.body));
    throw Exception('Gagal ambil profil');
  }

  static Future<UserModel> updateDisplayName(String name) async {
    final res = await http.put(
      Uri.parse('$_base/users/me'),
      headers: await _headers(),
      body: jsonEncode({'display_name': name}),
    );
    if (res.statusCode == 200) return UserModel.fromJson(jsonDecode(res.body));
    throw Exception('Gagal update nama');
  }

  static Future<String> uploadAvatar(Uint8List bytes, String filename) async {
    final token = await AuthService.getToken();
    final req   = http.MultipartRequest('POST', Uri.parse('$_base/users/me/avatar'));
    req.headers['Authorization'] = 'Bearer $token';
    req.files.add(http.MultipartFile.fromBytes('avatar', bytes, filename: filename));
    final res  = await req.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode == 200) return jsonDecode(body)['avatar_url'] ?? '';
    throw Exception('Gagal upload foto');
  }

  static Future<List<MessageModel>> getChatHistory(String partnerId) async {
    final res = await http.get(
      Uri.parse('$_base/messages/$partnerId'), headers: await _headers());
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((m) => MessageModel.fromJson(m)).toList();
    }
    throw Exception('Gagal ambil riwayat chat');
  }
}
