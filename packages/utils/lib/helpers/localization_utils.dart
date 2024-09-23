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
}
