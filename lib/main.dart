// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:admiral_tablet_a/l10n/generated/app_localizations.dart';
import 'package:admiral_tablet_a/ui/theme/app_theme.dart';
import 'package:admiral_tablet_a/ui/theme/theme_controller.dart';
import 'package:admiral_tablet_a/ui/app_routes.dart';

// ✅ تحميل حالة اليوم قبل بناء الواجهة
import 'package:admiral_tablet_a/core/session/index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ مهم: حمّل حالة اليوم من التخزين المحلي قبل تشغيل الواجهات
  await DaySessionStore().load();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  /// لتغيير اللغة من أي ويدجت (يستعملها LangSwitcher)
  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// لو تحب اعتماد لغة النظام اتركها null
  Locale? _locale = const Locale('en');

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

          // اللغات والترجمة
          locale: _locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // fallback لو لغة الجهاز غير مدعومة
          localeResolutionCallback: (deviceLocale, supported) {
            if (deviceLocale == null) return supported.first;
            for (final l in supported) {
              if (l.languageCode == deviceLocale.languageCode) return l;
            }
            return supported.first;
          },

          // الثيم (مطابق تمامًا للي في الريبو)
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,

          // الراوتينغ
          onGenerateRoute: AppRoutes.onGenerateRoute,
          initialRoute: AppRoutes.login,
        );
      },
    );
  }
}
