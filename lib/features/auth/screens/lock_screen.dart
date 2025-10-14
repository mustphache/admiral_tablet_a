import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:admiral_tablet_a/ui/app_routes.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pin = TextEditingController();
  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    try {
      // TODO: LockService().verifyPin(_pin.text.trim());
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
            (route) => false,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Unlock')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Text('أدخل كلمة المرور', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pin,
                      obscureText: _obscure,
                      obscuringCharacter: '•',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'PIN',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'الرجاء إدخال كلمة المرور';
                        if (t.length < 4) return 'الحد الأدنى 4 أرقام';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _busy ? null : _unlock,
                      icon: const Icon(Icons.lock_open),
                      label: _busy ? const Text('جاري الفتح…') : const Text('Unlock'),
                    ),
                    const SizedBox(height: 8),
                    // 🔧 زر DEV للوصول السريع لصفحة التصفير
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.pushNamed(context, AppRoutes.devWipe),
                      child: Text('تصفير (DEV)', style: TextStyle(color: cs.primary)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
