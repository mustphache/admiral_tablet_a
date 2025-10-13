import 'dart:collection';
import 'package:admiral_tablet_a/data/db/wallet_repository.dart';
import 'package:admiral_tablet_a/data/models/wallet_movement.dart';

/// تنفيذ مؤقت بالذاكرة — يصلح للتجربة الآن
class WalletRepositoryMemory implements IWalletRepository {
  final Map<String, WalletMovement> _store = HashMap();

  @override
  Future<void> add(WalletMovement m) async {
    _store[m.id] = m;
  }

  @override
  Future<void> addMany(List<WalletMovement> list) async {
    for (final m in list) {
      _store[m.id] = m;
    }
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }

  @override
  Future<void> update(WalletMovement m) async {
    if (_store.containsKey(m.id)) {
      _store[m.id] = m;
    } else {
      throw StateError('Movement not found: ${m.id}');
    }
  }

  @override
  Future<List<WalletMovement>> listByDay(String dayId) async {
    final list = _store.values.where((e) => e.dayId == dayId).toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  @override
  Future<List<WalletMovement>> listByExternalRef(String dayId, String externalRefId) async {
    final list = _store.values.where((e) => e.dayId == dayId && e.externalRefId == externalRefId).toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }
}
