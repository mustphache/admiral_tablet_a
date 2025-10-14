import 'package:flutter/material.dart';

// Auth / Lock
import '../features/auth/screens/lock_screen.dart';
import '../features/auth/screens/login_screen.dart';

// Home
import '../features/home/screens/home_screen.dart';

// Day session
import '../features/day_session/day_session_screen.dart';
import '../features/day_session/purchases_screen.dart';
import '../features/day_session/expenses_screen.dart';

// Wallet
import '../features/wallet/screens/wallet_screen.dart';
import '../features/wallet/screens/wallet_movements_screen.dart';
import '../features/wallet/screens/add_wallet_movement_screen.dart';

class AppRoutes {
  // المفاتيح الأساسية
  static const String home = '/';            // ← الشاشة الرئيسية
  static const String login = '/login';      // شاشة القفل/الدخول

  // أخرى
  static const String daySession = '/day-session';
  static const String purchases = '/purchases';
  static const String expenses = '/expenses';
  static const String wallet = '/wallet';
  static const String walletMovements = '/wallet/movements';
  static const String walletMovementAdd = '/wallet/movements/add';

  // خريطة الراوتات
  static final Map<String, WidgetBuilder> routes = {
    // ترتيب: أول ما نفتح التطبيق يروح لـ login، وبعد النجاح نبدّل بـ home
    home: (_) => const HomeScreen(),
    login: (_) => const LockScreen(),

    daySession: (_) => const DaySessionScreen(),
    purchases: (_) => const PurchasesScreen(),
    expenses: (_) => const ExpensesScreen(),

    wallet: (_) => const WalletScreen(),
    walletMovements: (_) => const WalletMovementsScreen(),
    walletMovementAdd: (_) => const AddWalletMovementScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    // fallback
    return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}
