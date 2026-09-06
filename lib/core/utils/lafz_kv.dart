import 'package:shared_preferences/shared_preferences.dart';

import 'package:lafz/core/utils/cookie_store.dart';

/// String store that writes a cookie (web) and SharedPreferences (all).
class LafzKv {
  static Future<void> setString(String key, String value) async {
    writeCookie(key, value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final fromCookie = readCookie(key);
    if (fromCookie != null && fromCookie.isNotEmpty) return fromCookie;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await setString(key, value ? '1' : '0');
  }

  static Future<bool?> getBool(String key) async {
    final raw = await getString(key);
    if (raw == '1' || raw == 'true') return true;
    if (raw == '0' || raw == 'false') return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }
}
