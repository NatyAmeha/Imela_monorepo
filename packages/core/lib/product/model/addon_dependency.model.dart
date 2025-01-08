import 'package:freezed_annotation/freezed_annotation.dart';

part 'addon_dependency.model.freezed.dart';
part 'addon_dependency.model.g.dart';

enum AddonDependencyType {
  ADDON_VALUE,
  ADDON_PRICE,
}

@freezed
class AddonDependency with _$AddonDependency {
  factory AddonDependency({ 
    String? id,
    String? addonId,
    required String type,
    List<String>? value,
  }) = _AddonDependency;

  factory AddonDependency.fromJson(Map<String, dynamic> json) => _$AddonDependencyFromJson(json);
}
