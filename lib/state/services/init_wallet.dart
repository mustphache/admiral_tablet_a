import 'package:admiral_tablet_a/data/db/wallet_repository.dart';
import 'package:admiral_tablet_a/data/db/wallet_repository_memory.dart';
import 'package:admiral_tablet_a/state/services/wallet_service.dart';

class Services {
  Services._();
  static final Services I = Services._();

  late final IWalletRepository walletRepo;
  late final WalletService wallet;

  void init() {
    walletRepo = WalletRepositoryMemory(); // بدّل لاحقًا بـ Isar/SQLite
    wallet = WalletService(walletRepo);
  }
}
