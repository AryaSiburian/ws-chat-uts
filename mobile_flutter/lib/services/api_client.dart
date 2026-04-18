import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;
  late PersistCookieJar cookieJar;
  
  // LOGIKA OTOMATIS: Android pakai 10.0.2.2, Linux/Windows pakai 127.0.0.1
  final String baseUrl = Platform.isAndroid ? "http://10.0.2.2:8080" : "http://127.0.0.1:8080";

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      extra: {'withCredentials': true}, 
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  Future<void> init() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage("${appDocDir.path}/.cookies/"),
    );
    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<String?> getCookieHeader() async {
    List<Cookie> cookies = await cookieJar.loadForRequest(Uri.parse(baseUrl));
    if (cookies.isEmpty) return null;
    return cookies.map((c) => '${c.name}=${c.value}').join('; ');
  }
}