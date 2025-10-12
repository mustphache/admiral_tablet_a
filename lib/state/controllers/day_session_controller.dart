// lib/state/controllers/day_session_controller.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SSOT
import 'package:admiral_tablet_a/core/time/time_formats.dart';

// Audit
import 'package:admiral_tablet_a/state/services/audit_log_service.dart';
import 'package:admiral_tablet_a/data/models/audit_event_model.dart';

/// طبقة توافق للكود القديم الذي يستعمل day.current.*
/// نوفر id + startedAt + market + openingCash.
/// ملاحظة: القيم الافتراضية للـmarket وopeningCash لأن مفهومنا الجديد ON/OFF لا يفرضها.
class _LegacyDay {
  final String id;
  final DateTime startedAt;
  final String market;
  final double openingCash;
  final String? notes;

  const _LegacyDay({
    required this.id,
    required this.startedAt,
    this.market = '',
    this.openingCash = 0.0,
    this.notes,
  });

  /// بعض الأكواد القديمة قد تستعمل 'marker' بدل 'market' بالخطأ
  String get marker => market;
}

/// المتحكم الرسمي: Session ON/OFF
class DaySessionController extends ChangeNotifier {
  static const _kOn = 'day_session_on_v1';
  static const _kStartedAt = 'day_session_started_at_v1';

  bool _isOn = false;
  DateTime? _startedAtUtc;

  // الواجهة الجديدة
  bool get isOn => _isOn;
  bool get isOpen => _isOn; // للتوافق
  DateTime? get startedAt => _startedAtUtc;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _isOn = sp.getBool(_kOn) ?? false;
    final raw = sp.getString(_kStartedAt);
    _startedAtUtc = raw == null ? null : DateTime.tryParse(raw)?.toUtc();
    notifyListeners();
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kOn, _isOn);
    if (_startedAtUtc != null) {
      await sp.setString(_kStartedAt, _startedAtUtc!.toIso8601String());
    } else {
      await sp.remove(_kStartedAt);
    }
  }

  Future<void> turnOn({String? actor}) async {
    if (_isOn) return;
    _isOn = true;
    _startedAtUtc = DateTime.now().toUtc();
    await _persist();
    notifyListeners();

    await AuditLogService().log(
      entityKind: AuditEntityKind.daySession,
      entityId: TimeFmt.dayIdToday(),
      action: AuditAction.open,
      before: {'on': false},
      after: {'on': true, 'startedAt': _startedAtUtc!.toIso8601String()},
      actor: actor,
    );
  }

  Future<void> turnOff({String? actor}) async {
    if (!_isOn) return;
    final prevStarted = _startedAtUtc;
    _isOn = false;
    _startedAtUtc = null;
    await _persist();
    notifyListeners();

    await AuditLogService().log(
      entityKind: AuditEntityKind.daySession,
      entityId: TimeFmt.dayIdToday(),
      action: AuditAction.close,
      before: {'on': true, 'startedAt': prevStarted?.toIso8601String()},
      after: {'on': false},
      actor: actor,
    );
  }

  // ========= طبقة التوافق مع الكود القديم =========

  /// بعض الشاشات القديمة تستخدم `day.current?.id` وأحيانًا `market/openingCash`.
  /// نرجّع كائن مبسّط عند ON، وnull عند OFF.
  _LegacyDay? get current {
    if (!_isOn) return null;
    return _LegacyDay(
      id: TimeFmt.dayIdToday(),
      startedAt: (_startedAtUtc ?? DateTime.now().toUtc()).toLocal(),
      market: '',        // لا نلزم المستخدم بإدخاله في وضع ON/OFF
      openingCash: 0.0,  // قيمة افتراضية آمنة
      notes: null,
    );
  }

  /// الكود القديم يستدعي restore() عند الإقلاع.
  Future<void> restore() => load();

  /// أسماء قديمة مكافئة:
  Future<void> openDay({String? actor}) => turnOn(actor: actor);
  Future<void> closeDay({String? actor}) => turnOff(actor: actor);
  Future<void> closeSession({String? actor}) => turnOff(actor: actor);
}
