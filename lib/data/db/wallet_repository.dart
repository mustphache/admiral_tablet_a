import 'package:admiral_tablet_a/data/models/wallet_movement.dart';

/// واجهة المستودع — بدّلها لاحقًا بـ Isar/SQLite
abstract class IWalletRepository {
  Future<void> add(WalletMovement m);
  Future<void> addMany(List<WalletMovement> list);
  Future<void> delete(String id);
  Future<void> update(WalletMovement m);

  /// كل الحركات المؤكدة لليوم
  Future<List<WalletMovement>> listByDay(String dayId);

  /// للربط عبر مرجع خارجي (purchaseId/expenseId)
  Future<List<WalletMovement>> listByExternalRef(String dayId, String externalRefId);
}
