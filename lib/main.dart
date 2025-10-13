import 'package:provider/provider.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';

// داخل main():
runApp(
MultiProvider(
providers: [
// ... مزوداتك الأخرى
Provider<WalletController>(create: (_) => WalletController()),
],
child: const MyApp(),
),
);
