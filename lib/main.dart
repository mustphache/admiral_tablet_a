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

  /// دالة شكلية مؤقتًا باش نسكّت الـ lang switcher.
  /// ما تبدّلش اللغة الآن — نخلوها لمرحلة الواجهة.
  static void setLocale(BuildContext context, Locale locale) {
    // TODO: تفعيل تبديل اللغة لاحقًا بعد ما نكمّل المنطق.
    // حالياً No-op حتى نركّزو على الحسابات/الحفظ فقط.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admiral Tablet',

      // ترجمة (موجودة عندك ومش حنبدلو اللغة runtime الآن)
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // ثيم بسيط مؤقتًا
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),

      // الراوتس
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialRoute: AppRoutes.login, // يبدأ بالقفل ثم يروح للـ Home
    );
  }
}
