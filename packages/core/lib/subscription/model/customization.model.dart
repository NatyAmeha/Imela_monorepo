import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/localized_field.model.dart';

part 'customization.model.freezed.dart';
part 'customization.model.g.dart';

enum CustomizationSelectionType { SINGLE_SELECTION, MULTI_SELECTION }

@freezed
class CustomizationCategory with _$CustomizationCategory {
  const CustomizationCategory._();
  const factory CustomizationCategory({
    String? id,
    List<LocalizedField>? name,
    List<LocalizedField>? description,
    String? selectionType,
    bool? selectionRequired,
    List<Customization>? customizations,
  }) = _CustomizationCategory;

  factory CustomizationCategory.fromJson(Map<String, dynamic> json) => _$CustomizationCategoryFromJson(json);
}

@freezed
class Customization with _$Customization {
  const Customization._();
  const factory Customization({
    String? id,
    List<LocalizedField>? name,
    String? actionIdentifier,
    String? value,
    double? additionalPrice,
    @JsonKey(name: 'default') @Default(false) bool defaultValue,
  }) = _Customization;

  factory Customization.fromJson(Map<String, dynamic> json) => _$CustomizationFromJson(json);

  bool isSelected(List<String> selectedCustomizationId){
    return selectedCustomizationId.contains(id);
  }

  String? additionalPriceString(){
    if(additionalPrice == null || additionalPrice == 0) return null;
    return '+${additionalPrice!.toStringAsFixed(2)}';
  }
}
