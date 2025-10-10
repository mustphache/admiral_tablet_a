// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أدميرال - التابلت أ';

  @override
  String get login_title => 'تسجيل الدخول';

  @override
  String get login_username => 'اسم المستخدم';

  @override
  String get login_password => 'كلمة المرور';

  @override
  String get login_cta => 'دخول';

  @override
  String get home_title => 'الصفحة الرئيسية';

  @override
  String get home_start_day => 'بداية اليوم';

  @override
  String get home_purchases => 'المشتريات';

  @override
  String get home_expenses => 'المصاريف';

  @override
  String get home_wallet => 'المحفظة';

  @override
  String get home_end_of_day => 'نهاية اليوم';
}
