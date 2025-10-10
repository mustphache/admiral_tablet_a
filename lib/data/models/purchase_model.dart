import 'dart:convert';

/// عملية شراء تابعة لجلسة يوم معينة
class PurchaseModel {
  String? id;
  String sessionId;

  /// المورد
  final String supplier;

  /// رقم الخاتم/التاغ (اختياري)
  final String? tagNumber;

  /// السعر للوحدة
  final double price;

  /// العدد
  final int count;

  /// الإجمالي (إن لم يرسل نحسبه price * count)
  final double total;

  /// ملاحظات
  final String? note;

  /// وقت الإدخال
  final DateTime timestamp;

  PurchaseModel({
    this.id,
    required this.sessionId,
    required this.supplier,
    this.tagNumber,
    required this.price,
    required this.count,
    double? total,
    this.note,
    DateTime? timestamp,
  })  : total = total ?? (price * count),
        timestamp = timestamp ?? DateTime.now();

  PurchaseModel copyWith({
    String? id,
    String? sessionId,
    String? supplier,
    String? tagNumber,
    double? price,
    int? count,
    double? total,
    String? note,
    DateTime? timestamp,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      supplier: supplier ?? this.supplier,
      tagNumber: tagNumber ?? this.tagNumber,
      price: price ?? this.price,
      count: count ?? this.count,
      total: total ?? this.total,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'sessionId': sessionId,
    'supplier': supplier,
    'tagNumber': tagNumber,
    'price': price,
    'count': count,
    'total': total,
    'note': note,
    'timestamp': timestamp.toIso8601String(),
  };

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      id: map['id'] as String?,
      sessionId: map['sessionId'] as String? ?? '',
      supplier: map['supplier'] as String? ?? '',
      tagNumber: map['tagNumber'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      count: (map['count'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num?)?.toDouble(),
      note: map['note'] as String?,
      timestamp: (map['timestamp'] as String?) != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  static PurchaseModel fromJson(String raw) =>
      PurchaseModel.fromMap(jsonDecode(raw) as Map<String, dynamic>);
}
