import 'package:flutter/material.dart';
import '../../main.dart';
import 'package:admiral_tablet_a/l10n/generated/app_localizations.dart';

class LangSwitcher extends StatelessWidget {
  const LangSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final current = Localizations.localeOf(context).languageCode;

    Widget item(String label, bool selected) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(selected ? Icons.check : Icons.circle_outlined, size: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: t.appTitle,
      onSelected: (locale) => MyApp.setLocale(context, locale),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('en'),
          child: item('English', current == 'en'),
        ),
        PopupMenuItem(
          value: const Locale('fr'),
          child: item('Français', current == 'fr'),
        ),
        PopupMenuItem(
          value: const Locale('ar'),
          child: item('العربية', current == 'ar'),
        ),
      ],
    );
  }
}
