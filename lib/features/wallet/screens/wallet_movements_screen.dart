import 'package:flutter/material.dart';
import '../../../ui/app_routes.dart'; // من features/wallet/screens إلى ui = ../../../

class WalletMovementsScreen extends StatelessWidget {
  const WalletMovementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Movements')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.walletMovementAdd),
          child: const Text('Add Movement'),
        ),
      ),
    );
  }
}
