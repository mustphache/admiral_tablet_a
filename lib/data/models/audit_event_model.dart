// lib/data/models/audit_event_model.dart
import 'dart:convert';

enum AuditEntityKind {
  purchase,
  expense,
  walletMovement,
  daySession,
  other,
}

enum AuditAction {
  create,
  update,
  delete,
  open,
  close,
  adjust,
}

class AuditEventModel {
  final String id;                // UUID
  final AuditEntityKind entityKind;
  final String entityId;
  final AuditAction action;
  final Map<String, dynamic>? before; // لقطة مبسطة قبل
  final Map<String, dynamic>? after;  // لقطة مبسطة بعد
  final DateTime at;                   // UTC ms precision
  final String? actor;                 // هوية الجهاز/المستخدم (اختياري)

  AuditEventModel({
    required this.id,
    required this.entityKind,
    required this.entityId,
    required this.action,
    required this.at,
    this.before,
    this.after,
    this.actor,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'entityKind': entityKind.name,
    'entityId': entityId,
    'action': action.name,
    'before': before,
    'after': after,
    'at': at.toUtc().toIso8601String(), // يحفظ الميلي
    'actor': actor,
  };

  factory AuditEventModel.fromMap(Map<String, dynamic> map) {
    return AuditEventModel(
      id: map['id']?.toString() ?? '',
      entityKind: AuditEntityKind.values.firstWhere(
            (e) => e.name == (map['entityKind']?.toString() ?? ''),
        orElse: () => AuditEntityKind.other,
      ),
      entityId: map['entityId']?.toString() ?? '',
      action: AuditAction.values.firstWhere(
            (e) => e.name == (map['action']?.toString() ?? ''),
        orElse: () => AuditAction.update,
      ),
      before: (map['before'] is Map<String, dynamic>)
          ? (map['before'] as Map<String, dynamic>)
          : null,
      after: (map['after'] is Map<String, dynamic>)
          ? (map['after'] as Map<String, dynamic>)
          : null,
      at: DateTime.tryParse(map['at']?.toString() ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      actor: map['actor']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());
  factory AuditEventModel.fromJson(String src) =>
      AuditEventModel.fromMap(json.decode(src) as Map<String, dynamic>);
}
