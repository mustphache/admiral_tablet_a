import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admiral_tablet_a/state/controllers/day_session_controller.dart';

class DayStatusIndicator extends StatelessWidget {
  const DayStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DaySessionController>(
      create: (_) => DaySessionController()..load(),
      builder: (_, __) {
        return Consumer<DaySessionController>(
          builder: (_, ctrl, __) {
            final on = ctrl.isOn;
            final color = on ? Colors.green : Colors.grey;
            final label = on ? 'ON' : 'OFF';
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('Session $label'),
                avatar: CircleAvatar(backgroundColor: color, radius: 6),
              ),
            );
          },
        );
      },
    );
  }
}
