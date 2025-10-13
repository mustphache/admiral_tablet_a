// lib/ui/app_routes.dart
import 'package:flutter/material.dart';

import '../features/wallet/screens/wallet_screen.dart';
import '../features/wallet/screens/wallet_movements_screen.dart';
import '../features/wallet/screens/add_wallet_movement_screen.dart';

// أضف بقية الشاشات حسب مشروعك...

final Map<String, WidgetBuilder> appRoutes = {
  '/wallet': (c) => const WalletScreen(),
  '/wallet/movements': (c) => const WalletMovementsScreen(),
  '/wallet/movements/add': (c) => const AddWalletMovementScreen(),
  // ...
};
