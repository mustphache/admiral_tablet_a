// lib/state/services/audit_log_service.dart
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

import 'package:admiral_tablet_a/data/models/audit_event_model.dart';
import 'package:admiral_tablet_a/state/services/outbox_service.dart';
import 'package:admiral_tablet_a/data/models/outbox_item_model.dart';

/// خدمة تسجيل تدقيقي بسيطة (append-only)
/// - تحتفظ بقائمة خفيفة في الذاكرة (للعرض اللحظي)
/// - وتبعث كل حدث إلى Outbox للمزامنة.
class AuditLogService extends ChangeNotifier {
  final _uuid = const Uuid();
  final _outbox = OutboxService();

  final List<AuditEventModel> _events = [];
  List<AuditEventModel> get events =>
      List.unmodifiable(_events); // للعرض لاحقًا (Reports)

  Future<void> log({
    required AuditEntityKind entityKind,
    required String entityId,
    required AuditAction action,
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
    String? actor, // اختياري (مستخدم/جهاز)
  }) async {
    final at = DateTime.now().toUtc();

    final event = AuditEventModel(
      id: _uuid.v4(),
      entityKind: entityKind,
      entityId: entityId,
      action: action,
      before: before,
      after: after,
      at: at,
      actor: actor,
    );

    _events.add(event);
    notifyListeners();

    // ادفع إلى Outbox للمزامنة
    await _outbox.add(OutboxItemModel(
      id: _uuid.v4(),
      kind: 'audit',
      dayId: _pickDayIdFrom(after) ?? _pickDayIdFrom(before) ?? '',
      payload: {
        'op': 'audit',
        ...event.toMap(),
      },
      createdAt: at,
    ));
  }

  /// نحاول أخذ dayId من الـsnapshot إن وجد.
  String? _pickDayIdFrom(Map<String, dynamic>? snap) {
    if (snap == null) return null;
    final v = snap['dayId'];
    if (v == null) return null;
    return v.toString().trim().isEmpty ? null : v.toString();
  }
}
