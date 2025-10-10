// lib/core/session/day_session_model.dart
// نموذج بسيط لوضع اليوم

enum DayStatus { open, closed }

class DaySessionState {
  final DayStatus status;
  final DateTime? openedAt;

  const DaySessionState({
    required this.status,
    this.openedAt,
  });

  factory DaySessionState.closed() => const DaySessionState(status: DayStatus.closed);

  factory DaySessionState.openedNow() =>
      DaySessionState(status: DayStatus.open, openedAt: DateTime.now());

  bool get isOpen => status == DayStatus.open;

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'openedAt': openedAt?.toIso8601String(),
  };

  factory DaySessionState.fromJson(Map<String, dynamic> json) {
    final s = json['status'] as String? ?? 'closed';
    final opened = json['openedAt'] as String?;
    return DaySessionState(
      status: s == 'open' ? DayStatus.open : DayStatus.closed,
      openedAt: opened != null ? DateTime.tryParse(opened) : null,
    );
  }
}
