// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ADMIRAL — Tablette A';

  @override
  String get login_title => 'Connexion';

  @override
  String get login_username => 'Nom d’utilisateur';

  @override
  String get login_password => 'Mot de passe';

  @override
  String get login_cta => 'Se connecter';

  @override
  String get home_title => 'Tablette A — Accueil';

  @override
  String get home_start_day => 'Commencer la journée';

  @override
  String get home_purchases => 'Achats';

  @override
  String get home_expenses => 'Dépenses';

  @override
  String get home_wallet => 'Portefeuille';

  @override
  String get home_end_of_day => 'Fin de journée';
}
