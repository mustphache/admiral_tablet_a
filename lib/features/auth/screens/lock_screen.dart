import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:admiral_tablet_a/state/services/lock_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pin = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });

    try {
      final saved = await LockService.getPin();
      final enabled = await LockService.isEnabled();
      final input = _pin.text.trim();

      if (!enabled) {
        Navigator.pop(context, true);
        return;
      }
      if (saved == null || saved.isEmpty) {
        setState(() => _error = 'لم يتم ضبط PIN بعد');
        return;
      }
      if (input == saved) {
        await LockService.markJustUnlocked();
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        setState(() => _error = 'PIN غير صحيح');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدخال PIN')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('أدخل رقم PIN لفتح التطبيق'),
                const SizedBox(height: 12),
                TextField(
                  controller: _pin,
                  autofocus: true,
                  maxLength: 6,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    border: const OutlineInputBorder(),
                    errorText: _error,
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _busy ? null : _submit,
                  icon: _busy
                      ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.lock_open),
                  label: const Text('فتح'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
