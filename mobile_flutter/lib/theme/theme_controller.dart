import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static bool get isDark => themeNotifier.value == ThemeMode.dark;

  static Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final nowDark = themeNotifier.value == ThemeMode.dark;
    themeNotifier.value = nowDark ? ThemeMode.light : ThemeMode.dark;
    print("THEME DEBUG: Switched to ${themeNotifier.value}");
    await prefs.setBool('isDark', !nowDark);
  }

  static Future<void> setDark(bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    themeNotifier.value = dark ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool('isDark', dark);
  }
}