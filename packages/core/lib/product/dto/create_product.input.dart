
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/product/dto/create_inventory.input.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/price.model.dart';

part 'create_product.input.freezed.dart';
part 'create_product.input.g.dart';

@freezed
class CreateProductInput with _$CreateProductInput {
  const CreateProductInput._();

  const factory CreateProductInput({
    List<LocalizedField>? name, 
    List<LocalizedField>? description,
    List<String>? tag,
    bool? mainProduct,
    double? minimumOrderQty,
    int? loyaltyPoint,
    List<String>? sectionId,
    List<String>? category,
    String? type,
    Gallery? gallery,
    List<CreateInventoryInput>? inventoryInfo,
    Map<String, List<String>>? options,
    List<String>? optionsIncluded,
    List<String>? reviewTopics,
    String? callToAction,
    List<String>? branchIds,
    bool? canOrderOnline,
    String? deliveryInfoId,
    List<Price>? defaultPrices,
  }) = _CreateProductInput;

  factory CreateProductInput.fromJson(Map<String, dynamic> json) => _$CreateProductInputFromJson(json);

  static CreateProductInput fromMainInfo({
    required Map<String, String> nameOptions,
    required Map<String, String> descriptionOptions,
    required Map<String, String> callToActionOptions,
    required bool canOrderOnline,
    required List<String> categories,
    required String minOrderQtyText,
  }) {
    return CreateProductInput(
      name: nameOptions.toLocalizedFieldArray(),
      description: descriptionOptions.toLocalizedFieldArray(),
      callToAction: callToActionOptions.toLocalizedFieldArray().firstOrNull?.value,
      canOrderOnline: canOrderOnline,
      category: categories,
      inventoryInfo: [],
      defaultPrices: [],
      minimumOrderQty: double.tryParse(minOrderQtyText) ?? 1,
      // Initialize other fields with default values or null as needed
    );
  }
}
