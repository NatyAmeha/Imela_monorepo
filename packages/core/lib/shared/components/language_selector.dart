import 'package:flutter/material.dart';

import 'package:imela_utils/helpers/localization_utils.dart';

class LanguageSelectorDialog extends StatelessWidget {
  final String selectedLanguage;
  final Function(AppLanguage) onLanguageSelected;

  const LanguageSelectorDialog({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: AppLanguage.values.map((language) {
        return ListTile(
          title: Text(language.displayName),
          trailing: selectedLanguage == language.name ? const Icon(Icons.check_circle, color: Colors.green) : null,
          onTap: () => onLanguageSelected(language),
        );
      }).toList(),
    );
  }
}
