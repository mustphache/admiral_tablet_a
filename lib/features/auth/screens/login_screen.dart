import 'package:flutter/material.dart';
import 'package:admiral_tablet_a/l10n/generated/app_localizations.dart';
import 'package:admiral_tablet_a/ui/widgets/lang_switcher.dart';
import 'package:admiral_tablet_a/ui/app_routes.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _u = TextEditingController(), _p = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _busy = false, _obsc = true;

  Future<void> _go() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.login_title),
        actions: const [LangSwitcher()],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _u,
                    decoration: InputDecoration(labelText: t.login_username),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? t.login_username : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _p,
                    obscureText: _obsc,
                    decoration: InputDecoration(
                      labelText: t.login_password,
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obsc = !_obsc),
                        icon: Icon(
                            _obsc ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? t.login_password : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _busy ? null : _go,
                      child: _busy
                          ? const CircularProgressIndicator()
                          : Text(t.login_cta),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
