// lib/features/dev/dev_wipe_screen.dart
import 'package:flutter/material.dart';
import 'package:admiral_tablet_a/state/services/dev_reset.dart';
import 'package:admiral_tablet_a/ui/app_routes.dart';

class DevWipeScreen extends StatefulWidget {
  const DevWipeScreen({super.key});

  @override
  State<DevWipeScreen> createState() => _DevWipeScreenState();
}

class _DevWipeScreenState extends State<DevWipeScreen> {
  bool _busy = false;

  Future<void> _wipe() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await DevReset.wipeAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم مسح كل البيانات (DEV).')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
            (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('فشل المسح: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DEV — تصفير الجهاز')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'هذا الزرّ يمسح كل بيانات التطبيق المحلية (للتجارب فقط).',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _busy ? null : _wipe,
                  icon: const Icon(Icons.delete_forever),
                  label: _busy
                      ? const Text('جارٍ التصفير…')
                      : const Text('تصفير (DEV)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
