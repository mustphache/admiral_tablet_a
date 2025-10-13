// lib/ui/app_routes.dart
import 'package:flutter/material.dart';

import '../features/wallet/screens/wallet_screen.dart';
import '../features/wallet/screens/wallet_movements_screen.dart';
import '../features/wallet/screens/add_wallet_movement_screen.dart';
import '../features/day_session/day_session_screen.dart';
import '../features/day_session/purchases_screen.dart';
import '../features/day_session/expenses_screen.dart';

class AppRoutes {
  static const wallet = '/wallet';
  static const walletMovements = '/wallet/movements';
  static const walletMovementAdd = '/wallet/movements/add';
  static const daySession = '/day-session';
  static const purchases = '/purchases';
  static const expenses = '/expenses';

  static final Map<String, WidgetBuilder> routes = {
    wallet: (_) => const WalletScreen(),
    walletMovements: (_) => const WalletMovementsScreen(),
    walletMovementAdd: (_) => const AddWalletMovementScreen(),
    daySession: (_) => const DaySessionScreen(),
    purchases: (_) => const PurchasesScreen(),
    expenses: (_) => const ExpensesScreen(),
  };
}
