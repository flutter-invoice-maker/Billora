import 'package:flutter/material.dart';

class LanguageSwitcher extends StatelessWidget {
  final void Function(Locale)? onLocaleChanged;
  const LanguageSwitcher({super.key, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<Locale>(
        icon: const Icon(Icons.language),
        value: Localizations.localeOf(context),
        items: const [
          DropdownMenuItem(
            value: Locale('en'),
            child: Text('EN'),
          ),
          DropdownMenuItem(
            value: Locale('vi'),
            child: Text('VI'),
          ),
        ],
        onChanged: (locale) {
          if (locale != null && onLocaleChanged != null) {
            onLocaleChanged!(locale);
          }
        },
        style: Theme.of(context).textTheme.bodyMedium,
        dropdownColor: Theme.of(context).cardColor,
      ),
    );
  }
} 