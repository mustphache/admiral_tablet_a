// lib/state/controllers/day_session_store.dart
// توافق مع الأكواد القديمة التي تستورد DaySessionStore وتستعمله كـ ChangeNotifier.

import 'day_session_controller.dart';

/// Alias: أي مكان يطلب DaySessionStore راح يشتغل على DaySessionController
typedef DaySessionStore = DaySessionController;
