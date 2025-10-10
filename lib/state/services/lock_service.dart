import 'package:shared_preferences/shared_preferences.dart';

class LockService {
  static const _kEnabled = 'lock_enabled';
  static const _kPin = 'lock_pin';
  static const _kLastUnlockMillis = 'lock_last_unlock';

  /// هل القفل مفعّل؟
  static Future<bool> isEnabled() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kEnabled) ?? false;
  }

  /// تفعيل/إلغاء القفل
  static Future<void> setEnabled(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kEnabled, v);
  }

  /// قراءة الـ PIN (قد يكون null لو لم يُضبط بعد)
  static Future<String?> getPin() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kPin);
  }

  /// ضبط/تغيير الـ PIN
  static Future<void> setPin(String pin) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kPin, pin);
  }

  /// وضع ختم وقت آخر فتح ناجح (اختياري لو حبيت تستعمله لاحقاً للأوتو-لوك)
  static Future<void> markJustUnlocked() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kLastUnlockMillis, DateTime.now().millisecondsSinceEpoch);
  }
}
