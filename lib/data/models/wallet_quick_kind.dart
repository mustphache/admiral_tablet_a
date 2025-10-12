// lib/data/models/wallet_quick_kind.dart
/// أنواع الحركات المالية السريعة في المحفظة.
/// تُستخدم في WalletScreen و AddWalletMovementScreen وكل مكان آخر.
enum WalletQuickKind {
  deposit,      // إيداع
  withdraw,     // سحب
  returnCash,   // إرجاع الباقي
}
