// lib/main.dart
import 'package:flutter/material.dart';

// ✅ تحميل حالة اليوم قبل بناء الواجهة
import 'package:admiral_tablet_a/core/session/index.dart';

// الثيم (إن كان لديك AppTheme)
import 'package:admiral_tablet_a/ui/theme/app_theme.dart';

// الراوتس
import 'package:admiral_tablet_a/ui/app_routes.dart';

// الترجمة (مولَّدة من l10n)
import 'package:admiral_tablet_a/l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ مهم: حمّل حالة اليوم من التخزين المحلي قبل تشغيل الواجهات
  await DaySessionStore().load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ADMIRAL — Tablet A',

      // ✅ الترجمة
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // ✅ الثيم (إن وُجد AppTheme لديك)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // ✅ الراوتس
      initialRoute: AppRoutes.login, // كما في ملفك الحالي
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
