import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ui/app_routes.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admiral Tablet',

      // 🔤 الترجمة (موجودة عندك في lib/l10n/generated/)
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // 🎨 ثيم افتراضي بسيط (بدون الاعتماد على ملفات ثيم خاصة حتى ما يكسرش)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),

      // 🧭 الراوتس
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,

      // ⛳️ يبدأ بشاشة القفل (Lock)
      initialRoute: AppRoutes.login,
    );
  }
}
