import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:admiral_tablet_a/l10n/generated/app_localizations.dart';
import 'package:admiral_tablet_a/ui/theme/app_theme.dart';
import 'package:admiral_tablet_a/ui/theme/theme_controller.dart';
import 'package:admiral_tablet_a/ui/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // لتغيير اللغة من أي ويدجت (يستعملها LangSwitcher)
  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = ThemeController.instance;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeCtrl.mode,
      builder: (_, themeMode, __) {
        return MaterialApp(
          title: 'ADMIRAL — Tablet A',
          debugShowCheckedModeBanner: false,

          // اللغات
          locale: _locale,
          supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // الثيمات
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,

          // الراوتر الموحد
          onGenerateRoute: AppRoutes.onGenerateRoute,
          initialRoute: AppRoutes.login,
        );
      },
    );
  }
}
