import 'package:flutter/material.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/wallet/screens/wallet_screen.dart';
import '../features/wallet/screens/wallet_movements_screen.dart';
import '../features/wallet/screens/add_wallet_movement_screen.dart';
import '../features/day_session/day_session_screen.dart';
import '../features/day_session/purchases_screen.dart';
import '../features/day_session/expenses_screen.dart';

class AppRoutes {
  // مفاتيح مطلوبة
  static const String home = '/';
  static const String login = '/login';

  static const String wallet = '/wallet';
  static const String walletMovements = '/wallet/movements';
  static const String walletMovementAdd = '/wallet/movements/add';
  static const String daySession = '/day-session';
  static const String purchases = '/purchases';
  static const String expenses = '/expenses';

  static final Map<String, WidgetBuilder> routes = {
    home: (_) => const DaySessionScreen(),
    login: (_) => const LoginScreen(),
    wallet: (_) => const WalletScreen(),
    walletMovements: (_) => const WalletMovementsScreen(),
    walletMovementAdd: (_) => const AddWalletMovementScreen(),
    daySession: (_) => const DaySessionScreen(),
    purchases: (_) => const PurchasesScreen(),
    expenses: (_) => const ExpensesScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    // fallback
    return MaterialPageRoute(builder: (_) => const DaySessionScreen());
  }
}
