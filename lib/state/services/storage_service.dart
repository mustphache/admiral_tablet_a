import 'package:shared_preferences/shared_preferences.dart';
import 'package:admiral_tablet_a/common/constants/app_constants.dart';
import 'package:admiral_tablet_a/common/helpers/utils.dart';
import 'package:admiral_tablet_a/data/models/day_session_model.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  /// حفظ جلسة اليوم
  Future<void> saveDaySession(DaySessionModel model) async {
    final sp = await SharedPreferences.getInstance();
    // نخزّن كـ JSON آمن انطلاقًا من الـ Map
    await sp.setString(
      AppConstants.daySessionStorageKey,
      safeEncode(model.toMap()),
    );
  }

  /// تحميل جلسة اليوم
  Future<DaySessionModel?> loadDaySession() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(AppConstants.daySessionStorageKey);
    if (raw == null || raw.isEmpty) return null;

    // نفكّ الترميز إلى Map ثم نحوله لموديل
    final data = Map<String, dynamic>.from(safeDecode(raw));
    return DaySessionModel.fromMap(data);
  }

  /// مسح جلسة اليوم
  Future<void> clearDaySession() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(AppConstants.daySessionStorageKey);
  }
}
