import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floating;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floating,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floating,
    );
  }
}
