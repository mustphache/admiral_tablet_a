import 'package:admiral_tablet_a/state/services/errors.dart';

String mapWalletError(Object e) {
  if (e is InsufficientBalanceError) {
    return 'الرصيد غير كافٍ.\nالمتوفر: ${e.currentBalance.toStringAsFixed(2)}\nالمطلوب: ${e.requiredAmount.toStringAsFixed(2)}';
  }
  if (e is NoFinancialChangeError) {
    return 'لا يوجد تغيير في القيمة — لا يمكن التأكيد.';
  }
  if (e is ImmutableCapitalError) {
    return 'رأس المال المؤكَّد لا يمكن تعديله أو حذفه.';
  }
  return 'حدث خطأ غير متوقع.';
}
