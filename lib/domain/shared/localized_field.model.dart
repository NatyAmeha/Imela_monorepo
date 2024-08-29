import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela/presentation/ui/app_controller.dart';
part 'localized_field.model.g.dart';
part 'localized_field.model.freezed.dart';

@freezed
class LocalizedField with _$LocalizedField {
  const factory LocalizedField({String? key, String? value}) = _LocalizedField;

  factory LocalizedField.fromJson(Map<String, dynamic> json) => _$LocalizedFieldFromJson(json);
}

extension LocalizedFieldExtension on List<LocalizedField>? {
  String localize() {
    if (this == null) return '';
    return this?.firstWhereOrNull((element) => element.key == AppController.getInstance.selectedLanguage.name)?.value ?? this?.firstOrNull?.value ?? "";
  }
}
