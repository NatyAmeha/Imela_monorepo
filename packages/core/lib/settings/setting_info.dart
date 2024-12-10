class SettingKey {
  static const String IS_FIRST_TIME_LAUNCH = 'isFirstTimeLaunch';
  static const String SELECTED_LANGUAGE = 'selectedLanguage';
  static const String SELECTED_CURRENCY = 'selectedCurrency';
}

class SettingInfo {
  final String key;
  final dynamic value;

  SettingInfo({required this.key, required this.value});
}
