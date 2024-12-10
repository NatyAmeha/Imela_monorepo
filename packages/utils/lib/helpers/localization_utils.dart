import 'dart:ui';

import 'package:dartx/dartx.dart';

enum AppLanguage { ENGLISH, AMHARIC }

enum Currency { USD, ETB }

class LocalizationUtils {
  static Map<String, String> getDefaultInputOptions() {
    return <String, String>{AppLanguage.ENGLISH.name: '', AppLanguage.AMHARIC.name: ''};
  }

  static String getDefaultSelectedKey(String selectedLanguage) {
    return AppLanguage.values.firstOrNullWhere((element) => element.name == selectedLanguage)?.name ?? AppLanguage.ENGLISH.name;
  }

  static String returnLocalizedString(String selectedLanguage, {required String englishString, String? amharicString}) {
    if (selectedLanguage == AppLanguage.AMHARIC.name) {
      return amharicString ?? englishString;
    } else {
      return englishString;
    }
  }
}

extension AppLanguageExtension on AppLanguage {
  String get displayName {
    switch (this) {
      case AppLanguage.ENGLISH:
        return 'English';
      case AppLanguage.AMHARIC:
        return 'አማርኛ';
      default:
        return 'English';
    }
  }

  Locale get locale {
    switch (this) {
      case AppLanguage.ENGLISH:
        return const Locale('en', 'US');
      case AppLanguage.AMHARIC:
        return const Locale('am', 'ET');
      default:
        return const Locale('en', 'US');
    }
  }
}
