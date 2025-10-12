// lib/features/wallet/screens/wallet_movements_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:admiral_tablet_a/core/session/index.dart';
import 'package:admiral_tablet_a/core/session/day_status_indicator.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';
import 'package:admiral_tablet_a/state/controllers/wallet_controller.dart';
import 'package:admiral_tablet_a/data/models/wallet_movement_model.dart';

// SSOT: المال
import 'package:admiral_tablet_a/core/money/money.dart';

enum _Filter { all, thisDay }

class WalletMovementsScreen extends StatefulWidget {
  const WalletMovementsScreen({super.key});

  @override
  State<WalletMovementsScreen> createState() => _WalletMovementsScreenState();
}

class _WalletMovementsScreenState extends State<WalletMovementsScreen> {
  final _wallet = WalletController();
  final _day = DaySessionController();
  final _fmt = DateFormat('yyyy-MM-dd  HH:mm');

  _Filter _filter = _Filter.all;

  List<WalletMovementModel> get _source {
    final items = List<WalletMovementModel>.from(_wallet.items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (_filter == _Filter.thisDay && _day.isOpen && _day.current != null) {
      final id = _day.current!.id;
      return items.where((e) => e.dayId == id).toList();
    }
    return items;
  }

  double get _sumTotal => _source.fold(0.0, (s, e) => s + e.amount);
  double get _sumIn =>
      _source.where((e) => e.amount > 0).fold(0.0, (s, e) => s + e.amount);
  double get _sumOut =>
      _source.where((e) => e.amount < 0).fold(0.0, (s, e) => s + e.amount.abs());

  @override
  Widget build(BuildContext context) {
    return DaySessionGate(
      allowWhenClosed: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet Movements'),
          actions: const [DayStatusIndicator()],
        ),
        body: Column(
          children: [
            _FiltersBar(
              filter: _filter,
              showThisDay: _day.isOpen && _day.current != null,
              onChange: (f) => setState(() => _filter = f),
            ),
            _TotalsBar(
              total: _sumTotal,
              incoming: _sumIn,
              outgoing: _sumOut,
            ),
            const Divider(height: 0),
            Expanded(
              child: _source.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _source.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (ctx, i) => _MovementTile(
                  model: _source[i],
                  fmt: _fmt,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  final _Filter filter;
  final bool showThisDay;
  final ValueChanged<_Filter> onChange;
  const _FiltersBar({
    required this.filter,
    required this.showThisDay,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: filter == _Filter.all,
            onSelected: (_) => onChange(_Filter.all),
          ),
          if (showThisDay)
            ChoiceChip(
              label: const Text('This day'),
              selected: filter == _Filter.thisDay,
              onSelected: (_) => onChange(_Filter.thisDay),
            ),
        ],
      ),
    );
  }
}

class _TotalsBar extends StatelessWidget {
  final double total;
  final double incoming;
  final double outgoing;
  const _TotalsBar({
    required this.total,
    required this.incoming,
    required this.outgoing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    TextStyle v([bool strong = false]) =>
        TextStyle(fontWeight: strong ? FontWeight.w700 : FontWeight.w500);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      color: cs.surfaceVariant,
      child: Row(
        children: [
          _KV('Total', Money.fmt(total), v(true)),
          const Spacer(),
          _KV('In', Money.fmt(incoming), v()),
          const SizedBox(width: 16),
          _KV('Out', Money.fmt(outgoing), v()),
        ],
      ),
    );
  }

  static Widget _KV(String k, String v, TextStyle style) => Row(
    children: [Text('$k: ', style: style), Text(v, style: style)],
  );
}

class _MovementTile extends StatelessWidget {
  final WalletMovementModel model;
  final DateFormat fmt;
  const _MovementTile({required this.model, required this.fmt});

  IconData _iconFor(WalletType t) {
    switch (t) {
      case WalletType.open:
        return Icons.play_circle_outline;
      case WalletType.purchase:
        return Icons.shopping_bag_outlined;
      case WalletType.expense:
        return Icons.receipt_long_outlined;
      case WalletType.refund:
        return Icons.reply_all;
      case WalletType.adjust:
        return Icons.tune;
      case WalletType.close:
        return Icons.flag_circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isIn = model.amount >= 0;
    final color = isIn ? cs.primary : cs.error;
    final amountText = (isIn ? '+' : '-') + Money.fmt(model.amount.abs());

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cs.surfaceVariant,
        child: Icon(_iconFor(model.type), color: cs.onSurfaceVariant),
      ),
      title: Text(model.note?.isNotEmpty == true ? model.note! : model.type.name),
      subtitle: Text(fmt.format(model.createdAt.toLocal())),
      trailing: Text(
        amountText,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.list_alt, size: 48, color: cs.outline),
          const SizedBox(height: 8),
          Text('لا توجد حركات بعد', style: TextStyle(color: cs.outline)),
          const SizedBox(height: 12),
          const Text('هذه شاشة عرض فقط'),
        ],
      ),
    );
  }
}
