import 'package:flutter/material.dart';

// الشاشات
import 'package:admiral_tablet_a/features/auth/screens/login_screen.dart';
import 'package:admiral_tablet_a/features/home/screens/home_screen.dart';
import 'package:admiral_tablet_a/features/day_session/day_session_screen.dart';
import 'package:admiral_tablet_a/features/day_session/purchases_screen.dart';
import 'package:admiral_tablet_a/features/day_session/expenses_screen.dart';
import 'package:admiral_tablet_a/features/wallet/screens/wallet_screen.dart';
import 'package:admiral_tablet_a/features/wallet/screens/wallet_movements_screen.dart';
import 'package:admiral_tablet_a/features/wallet/screens/add_wallet_movement_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const daySession = '/day_session';
  static const purchases = '/purchases';
  static const expenses = '/expenses';
  static const wallet = '/wallet';
  static const walletMovements = '/wallet/movements';
  static const addWalletMovement = '/wallet/add_movement';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case daySession:
        return MaterialPageRoute(builder: (_) => const DaySessionScreen());
      case purchases:
        return MaterialPageRoute(builder: (_) => const PurchasesScreen());
      case expenses:
        return MaterialPageRoute(builder: (_) => const ExpensesScreen());
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      case walletMovements:
        return MaterialPageRoute(builder: (_) => const WalletMovementsScreen());
      case addWalletMovement:
        return MaterialPageRoute(builder: (_) => const AddWalletMovementScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
