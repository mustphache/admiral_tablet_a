// lib/state/services/dev_reset.dart
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class DevReset {
  static Future<void> wipeAll() async {
    // 1) مسح SharedPreferences
    final sp = await SharedPreferences.getInstance();
    await sp.clear();

    // 2) حذف مجلدات التخزين المحلية (إن وُجدت)
    final dirs = <Directory?>[
      await getApplicationDocumentsDirectory(),
      await getApplicationSupportDirectory(),
      await getTemporaryDirectory(),
    ];

    for (final d in dirs) {
      if (d != null && await d.exists()) {
        try {
          await d.delete(recursive: true);
        } catch (_) {
          // نتجاهل أي ملفات مقفولة
        }
      }
    }
  }
}
