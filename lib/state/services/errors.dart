class InsufficientBalanceError implements Exception {
  final double currentBalance;
  final double requiredAmount;
  InsufficientBalanceError(this.currentBalance, this.requiredAmount);

  @override
  String toString() => 'InsufficientBalanceError(current=$currentBalance, required=$requiredAmount)';
}

class NoFinancialChangeError implements Exception {
  @override
  String toString() => 'NoFinancialChangeError()';
}

class ImmutableCapitalError implements Exception {
  @override
  String toString() => 'ImmutableCapitalError()';
}
