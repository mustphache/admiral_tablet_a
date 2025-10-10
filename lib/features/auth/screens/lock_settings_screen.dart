import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:admiral_tablet_a/state/services/lock_service.dart';

class LockSettingsScreen extends StatefulWidget {
  const LockSettingsScreen({super.key});

  @override
  State<LockSettingsScreen> createState() => _LockSettingsScreenState();
}

class _LockSettingsScreenState extends State<LockSettingsScreen> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final en = await LockService.isEnabled();
    final saved = await LockService.getPin();
    setState(() {
      _enabled = en;
      _pin.text = saved ?? '';
      _confirm.text = saved ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final pin = _pin.text.trim();
    final confirm = _confirm.text.trim();
    if (_enabled && (pin.isEmpty || pin != confirm)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تحقّق من PIN والتأكيد')),
      );
      return;
    }
    await LockService.setEnabled(_enabled);
    if (_enabled) {
      await LockService.setPin(pin);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم الحفظ')),
    );
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('إعداد القفل')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('تفعيل القفل'),
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pin,
            enabled: _enabled,
            maxLength: 6,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'PIN',
              counterText: '',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirm,
            enabled: _enabled,
            maxLength: 6,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'تأكيد PIN',
              counterText: '',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
