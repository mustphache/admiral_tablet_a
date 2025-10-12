import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class KvStore {
  KvStore._();
  static Future<List<Map<String, dynamic>>> getList(String key) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = jsonDecode(raw) as List;
    return decoded.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  static Future<void> setList(String key, List<Map<String, dynamic>> items) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(items);
    await sp.setString(key, raw);
  }
}
