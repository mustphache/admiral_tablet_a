import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'ui/app_routes.dart';
import 'l10n/generated/app_localizations.dart';

// ⬅️ كنترولرات تحتاج Provider فوق الشجرة
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

/// نغلّف MyApp بـ MultiProvider باش يكون WalletController متاح في كل الراوتس
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WalletController>(
          create: (_) => WalletController(),
        ),
        ChangeNotifierProvider<DaySessionController>(
          create: (_) => DaySessionController(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

/// Stateful مع setLocale (للـ lang_switcher) + MaterialApp
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?._setLocale(locale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void _setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admiral Tablet',

      // 🗣️ الترجمات (نبدل runtime عبر MyApp.setLocale لما تحب)
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,

      // 🎨 ثيم مؤقت
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),

      // 🧭 الراوتس
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialRoute: AppRoutes.login, // يبدأ بالقفل ثم Home
    );
  }
}
