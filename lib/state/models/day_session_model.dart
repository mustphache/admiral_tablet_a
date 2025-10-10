import 'package:flutter/foundation.dart';

@immutable
class DaySessionModel {
  final String id;         // YYYY-MM-DD
  final String market;     // اسم السوق
  final double openingCash;
  final String? note;

  /// وقت الإغلاق (null يعني اليوم مفتوح)
  final DateTime? closedAt;

  const DaySessionModel({
    required this.id,
    required this.market,
    required this.openingCash,
    this.note,
    this.closedAt,
  });

  bool get isOpen => closedAt == null;

  DaySessionModel copyWith({
    String? id,
    String? market,
    double? openingCash,
    String? note,
    DateTime? closedAt, // مرّر قيمة وليس nullable toggle
  }) {
    return DaySessionModel(
      id: id ?? this.id,
      market: market ?? this.market,
      openingCash: openingCash ?? this.openingCash,
      note: note ?? this.note,
      closedAt: closedAt,
    );
  }

  factory DaySessionModel.fromJson(Map<String, dynamic> json) {
    return DaySessionModel(
      id: json['id'] as String,
      market: json['market'] as String,
      openingCash: (json['openingCash'] as num).toDouble(),
      note: json['note'] as String?,
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'market': market,
    'openingCash': openingCash,
    'note': note,
    'closedAt': closedAt?.toIso8601String(),
  };
}
