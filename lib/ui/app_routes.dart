import 'package:flutter/material.dart';
// ====== Screens (package imports) ======
import 'package:admiral_tablet_a/features/auth/screens/login_screen.dart';
import 'package:admiral_tablet_a/features/home/screens/home_screen.dart';
import 'package:admiral_tablet_a/features/a_day/screens/a_day_summary_screen.dart';
import 'package:admiral_tablet_a/features/day_session/day_session_screen.dart';
import 'package:admiral_tablet_a/features/day_session/expenses_screen.dart';
import 'package:admiral_tablet_a/features/day_session/purchases_screen.dart';
import 'package:admiral_tablet_a/features/day_session/reports_screen.dart';
import 'package:admiral_tablet_a/features/wallet/screens/wallet_screen.dart';
import 'package:admiral_tablet_a/features/wallet/screens/wallet_movements_screen.dart';
import 'package:admiral_tablet_a/features/wallet/screens/add_wallet_movement_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const aDaySummary = '/a_day_summary';
  static const String daySession = '/day-session';
  static const String expenses = '/expenses';
  static const String purchases = '/purchases';
  static const String reports = '/reports';
  static const String daySummary = '/a-day/summary';
  static const String wallet = '/wallet';
  static const String walletMovements = '/wallet/movements';
  static const String walletMovementAdd = '/wallet/movements/add';
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case daySummary:
        return MaterialPageRoute(builder: (_) => const ADaySummaryScreen());


      case daySession:
        return MaterialPageRoute(builder: (_) => const DaySessionScreen());
      case expenses:
        return MaterialPageRoute(builder: (_) => const ExpensesScreen());
      case purchases:
        return MaterialPageRoute(builder: (_) => const PurchasesScreen());
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());

           case wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      case walletMovements:
        return MaterialPageRoute(builder: (_) => const WalletMovementsScreen());
      case walletMovementAdd:
        return MaterialPageRoute(builder: (_) => const AddWalletMovementScreen());

      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
