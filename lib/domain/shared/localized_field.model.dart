

import 'package:json_annotation/json_annotation.dart';
part 'localized_field.model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocalizedField{
  final String key;
  final String value;

  LocalizedField({required this.key, required this.value});

  factory LocalizedField.fromJson(Map<String, dynamic> json) => _$LocalizedFieldFromJson(json);
  Map<String, dynamic> toJson() => _$LocalizedFieldToJson(this);
}