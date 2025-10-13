class WalletState {
  final String dayId;
  final double openingBalance;
  final double credits;      // مجموع الدائن
  final double debits;       // مجموع المدين

  const WalletState({
    required this.dayId,
    required this.openingBalance,
    required this.credits,
    required this.debits,
  });

  double get currentBalance => openingBalance + credits - debits;

  factory WalletState.empty(String dayId, double openingBalance) {
    return WalletState(dayId: dayId, openingBalance: openingBalance, credits: 0, debits: 0);
  }
}
