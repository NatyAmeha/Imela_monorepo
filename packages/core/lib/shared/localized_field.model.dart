import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/price.model.dart';

part 'localized_field.model.g.dart';
part 'localized_field.model.freezed.dart';

@freezed
class LocalizedField with _$LocalizedField {
  const factory LocalizedField({String? key, String? value}) = _LocalizedField;

  factory LocalizedField.fromJson(Map<String, dynamic> json) => _$LocalizedFieldFromJson(json);

  
}

extension LocalizedFieldExtension on List<LocalizedField>? {
  String localize(String selectedLanguage) {
    if (this == null) return '';
    return this?.firstWhereOrNull((element) => element.key == selectedLanguage)?.value ?? this?.firstOrNull?.value ?? '';
  }

  bool containsValue(String value) {
    return this?.any((element) => element.value?.toLowerCase().contains(value) ?? false) ?? false;
  }
}

extension LocalizedFieldInputExtension on Map<String, String?>? {
  List<LocalizedField> toLocalizedFieldArray() {
    return this?.entries.map((e) => LocalizedField(key: e.key, value: e.value)).toList() ?? [];
  }

  List<Price> toPriceArray() {
    return this?.entries.map((e) {
      final amount = e.value?.isNotEmpty == true ? double.parse(e.value!) : 0.0;
      return Price(amount: amount, currency: e.key);
    }).toList() ?? [];
  }


}
