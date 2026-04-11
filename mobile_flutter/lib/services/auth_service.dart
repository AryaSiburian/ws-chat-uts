import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _base = 'http://localhost:8080';

  static Future<UserModel> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$_base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token',  data['token'] ?? '');
      await prefs.setString('userId', data['user']?['id']?.toString() ?? '');
      return UserModel.fromJson(data['user'] ?? {});
    }
    final err = jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception(err['message'] ?? 'Login gagal');
  }

  static Future<String?> getToken() async =>
      (await SharedPreferences.getInstance()).getString('token');

  static Future<String?> getUserId() async =>
      (await SharedPreferences.getInstance()).getString('userId');

  static Future<bool> isLoggedIn() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }

  static Future<void> logout() async =>
      (await SharedPreferences.getInstance()).clear();
}
