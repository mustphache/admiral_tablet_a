import 'package:flutter/material.dart';
import 'package:admiral_tablet_a/data/models/day_session_model.dart';

/// كنترولر جلسة اليوم (Singleton)
class DaySessionController extends ChangeNotifier {
  // ===== Singleton =====
  static final DaySessionController _singleton = DaySessionController._();
  factory DaySessionController() => _singleton;
  DaySessionController._();

  // ===== الحالة الداخلية =====
  DaySessionModel? _current;

  // ===== قراءات/خصائص =====
  DaySessionModel? get current => _current;

  /// اليوم مفتوح؟ (يوجد current و ليس مغلق)
  bool get isOpen => _current != null && _current!.closedAt == null;

  /// معرّف اليوم الحالي (لو مافيش جلسة مفتوحة يرجّع تاريخ اليوم)
  String get dayId => _current?.id ?? DaySessionModel.todayISO();

  /// وقت الإغلاق إن وُجد
  DateTime? get closedAt => _current?.closedAt;

  // ===== عمليات =====

  /// استعادة الحالة من أي تخزين (حاليًا لا شيء – نوفّر واجهة فقط حتى لا تظهر أخطاء)
  Future<void> restore() async {
    // لو كان عندك تخزين SharedPreferences/DB.. حمّل منه هنا
    // الآن نتركها كما هي حتى لا تكسر الواجهات التي تستدعيها.
    return;
  }

  /// فتح جلسة اليوم
  Future<void> openSession({
    required String market,
    required double openingCash,
    String? notes,
  }) async {
    final id = DaySessionModel.todayISO();
    _current = DaySessionModel(
      id: id,
      market: market,
      openingCash: openingCash,
      notes: notes,
      createdAt: DateTime.now(),
      closedAt: null,
    );
    notifyListeners();
  }

  /// إغلاق جلسة اليوم
  Future<void> closeSession() async {
    if (_current == null) return;
    if (_current!.closedAt != null) return; // مغلق أصلاً
    _current = _current!.copyWith(closedAt: DateTime.now());
    notifyListeners();
  }

  /// مسح الجلسة بالكامل (حالة المصنع)
  Future<void> wipeSession() async {
    _current = null;
    notifyListeners();
  }

  // ===== حراس/حمايات تُستدعى من الشاشات =====

  /// التأكد أن اليوم مفتوح – يرجع false ويظهر SnackBar إن لم يكن مفتوحًا
  bool ensureOpen(BuildContext context) {
    if (isOpen) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('اليوم مغلق – افتح يوم جديد أولًا')),
    );
    return false;
  }

  /// نفس الفكرة لكن ترمي Exception بدل السناكبار (إذا كانت الشاشات تتوقع throw)
  void ensureOpenOrThrow() {
    if (!isOpen) {
      throw StateError('Day session is not open');
    }
  }
}
