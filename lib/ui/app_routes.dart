import 'package:flutter/material.dart';

// ========== Auth ==========
import '../features/auth/screens/lock_screen.dart';
import '../features/auth/screens/lock_settings_screen.dart';
import '../features/auth/screens/login_screen.dart';

// ========== Home ==========
import '../features/home/screens/home_screen.dart';

// ========== Day Session ==========
import '../features/day_session/day_session_screen.dart';
import '../features/day_session/purchases_screen.dart';
import '../features/day_session/purchase_add_screen.dart';
import '../features/day_session/expenses_screen.dart';
import '../features/day_session/expense_add_screen.dart';
import '../features/day_session/reports_screen.dart';

// ========== Wallet ==========
import '../features/wallet/screens/wallet_screen.dart';
import '../features/wallet/screens/wallet_movements_screen.dart';
import '../features/wallet/screens/add_wallet_movement_screen.dart';

// ========== Dev (اختياري للتجارب) ==========
import '../features/dev/dev_wipe_screen.dart';

class AppRoutes {
  // أساسية
  static const String home = '/';
  static const String login = '/login';
  static const String lockSettings = '/lock-settings';

  // Day session
  static const String daySession = '/day-session';
  static const String purchases = '/purchases';
  static const String purchaseAdd = '/purchases/add';
  static const String expenses = '/expenses';
  static const String expenseAdd = '/expenses/add';
  static const String reports = '/reports';

  // Wallet
  static const String wallet = '/wallet';
  static const String walletMovements = '/wallet/movements';
  static const String walletMovementAdd = '/wallet/movements/add';

  // Dev
  static const String devWipe = '/dev/wipe';

  /// الخريطة الأساسية للراوتات
  static final Map<String, WidgetBuilder> routes = {
    // البداية الفعلية تكون من main.dart عبر initialRoute: AppRoutes.login
    home: (_) => const HomeScreen(),
    login: (_) => const LockScreen(),
    lockSettings: (_) => const LockSettingsScreen(),

    daySession: (_) => const DaySessionScreen(),
    purchases: (_) => const PurchasesScreen(),
    purchaseAdd: (_) => const PurchaseAddScreen(),
    expenses: (_) => const ExpensesScreen(),
    expenseAdd: (_) => const ExpenseAddScreen(),
    reports: (_) => const ReportsScreen(),

    wallet: (_) => const WalletScreen(),
    walletMovements: (_) => const WalletMovementsScreen(),
    walletMovementAdd: (_) => const AddWalletMovementScreen(),

    devWipe: (_) => const DevWipeScreen(),
  };

  /// onGenerateRoute كـ fallback و لدعم أي توسعات لاحقاً
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    // مسار غير معروف → رجّع Home
    return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}
