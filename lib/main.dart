import 'package:flutter/material.dart';

// 🟢 مهم: تهيئة خدمة المحفظة (repo + service)
import 'package:admiral_tablet_a/state/services/init_wallet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Services.I.init(); // ← هذا السطر ضروري لتفعيل WalletService عبر المشروع
  runApp(const MyApp());
}

/// ملاحظة:
/// - لو عندك MyApp خاصتك، احتفظ به.
/// - هذه نسخة بسيطة لضمان التشغيل حتى لو ما كانش عندك MyApp جاهز.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admiral Tablet A',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const _BootstrapScreen(),
    );
  }
}

class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admiral Tablet A')),
      body: const Center(
        child: Text(
          'App is initialized.\nWalletService is ready.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
