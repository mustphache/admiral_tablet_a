// lib/core/policy/permissions.dart
class Policy {
  static bool canAddPurchase({required bool dayOpen}) => dayOpen;
  static bool canAddExpense({required bool dayOpen}) => dayOpen;
  static bool canUseWallet() => true; // حسب سياستك الحالية
}
