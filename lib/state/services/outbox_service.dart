import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/outbox_item_model.dart';

class OutboxService {
  static const _kKey = 'outbox_items_v1';


  Future<void> add(OutboxItemModel item) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_kKey) ?? <String>[];
    list.add(item.toJson());
    await sp.setStringList(_kKey, list);
  }

  Future<void> clearDay(String dayId) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_kKey) ?? <String>[];
    final kept = list.where((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return m['dayId'] != dayId;
    }).toList();
    await sp.setStringList(_kKey, kept);
  }
}
