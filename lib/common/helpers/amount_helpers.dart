double round2(double v) => double.parse(v.toStringAsFixed(2));

double requirePositiveAmount(double amount) {
  if (amount <= 0) {
    throw ArgumentError('Amount must be > 0');
  }
  return round2(amount);
}
