import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';

class DaySessionScreen extends StatelessWidget {
  const DaySessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DaySessionController>(
      create: (_) => DaySessionController()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Session Info')),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<DaySessionController>(
      builder: (_, ctrl, __) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: Icon(
                    ctrl.isOn ? Icons.toggle_on : Icons.toggle_off,
                    size: 40,
                    color: ctrl.isOn ? Colors.green : cs.outline,
                  ),
                  title: Text(ctrl.isOn ? 'Session ON' : 'Session OFF'),
                  subtitle: Text(ctrl.isOn
                      ? 'الإضافة مفعّلة (مشتريات/مصاريف/محفظة)'
                      : 'القراءة فقط — لا يمكن إضافة/تعديل/حذف'),
                ),
              ),
              const SizedBox(height: 12),
              if (ctrl.startedAt != null)
                Text(
                  'Started at: ${ctrl.startedAt!.toLocal().toString().split(".").first}',
                  style: TextStyle(color: cs.outline),
                ),
              const SizedBox(height: 20),
              const _Hints(),
            ],
          ),
        );
      },
    );
  }
}

class _Hints extends StatelessWidget {
  const _Hints();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• التحكم ON/OFF حصريًا من الشاشة الرئيسية.', style: style),
        Text('• عند OFF: كل الشاشات وضع قراءة فقط.', style: style),
        Text('• عند ON: مسموح الإضافة والتعديل والحذف.', style: style),
      ],
    );
  }
}
