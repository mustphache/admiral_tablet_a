// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ADMIRAL — Tablet A';

  @override
  String get login_title => 'Sign in';

  @override
  String get login_username => 'Username';

  @override
  String get login_password => 'Password';

  @override
  String get login_cta => 'Login';

  @override
  String get home_title => 'Tablet A — Home';

  @override
  String get home_start_day => 'Start day';

  @override
  String get home_purchases => 'Purchases';

  @override
  String get home_expenses => 'Expenses';

  @override
  String get home_wallet => 'Wallet';

  @override
  String get home_end_of_day => 'End of day';
}
