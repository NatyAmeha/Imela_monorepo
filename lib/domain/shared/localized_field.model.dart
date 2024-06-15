import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'localized_field.model.g.dart';
part 'localized_field.model.freezed.dart';

@freezed
class LocalizedField with _$LocalizedField {
  const factory LocalizedField({String? key, String? value}) = _LocalizedField;

  factory LocalizedField.fromJson(Map<String, dynamic> json) => _$LocalizedFieldFromJson(json);
}

extension LocalizedFieldExtension on List<LocalizedField>? {
  String? getLocalizedValue(String selectedLanguage) {
    if (this == null) return null;
    return this?.firstWhere((element) => element.key == selectedLanguage, orElse: () => this!.first).value;
  }
}
