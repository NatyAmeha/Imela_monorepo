
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela/domain/shared/localized_field.model.dart';
import 'package:imela/domain/shared/price.model.dart';

part 'product_addon.model.freezed.dart';
part 'product_addon.model.g.dart';

enum AddonInputType {
  NUMBER_INPUT,
  QUANTITY_INPUT,
  TEXT_INPUT,
  SINGLE_SELECTION_INPUT,
  MULTIPLE_SELECTION_INPUT,
  DATE_INPUT,
  TIME_INPUT,
  DATE_TIME_INPUT,
  DATE_RANGE_INPUT,
}

@freezed
class ProductAddon with _$ProductAddon {
  const ProductAddon._();
  factory ProductAddon({
    String? id,
    List<LocalizedField>? name,
    // List<LocalizedField>? description,
    required String inputType,
    @Default([]) List<ProductAddonOption> options,
    bool? checkCalendar,
    List<Price>? additionalPrice,
    @Default(1.0) double minAmount,
    @Default(1.0) double maxAmount,
    @Default(true) bool isActive,
    @Default(false) bool isRequired,
    List<String>? tag,
    @Default(false) bool? isProduct,
    String? productId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProductAddon;

  factory ProductAddon.fromJson(Map<String, dynamic> json) => _$ProductAddonFromJson(json);

  bool get isNumberInput => inputType == AddonInputType.NUMBER_INPUT.name || inputType == AddonInputType.QUANTITY_INPUT.name;
  bool get isTextINput => inputType == AddonInputType.TEXT_INPUT.name;
  bool get isSingleSelectionInput => inputType == AddonInputType.SINGLE_SELECTION_INPUT.name;
  bool get isMultiSelectionInput => inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name;
  bool get isDateInput => inputType == AddonInputType.DATE_INPUT.name;
  bool get isTimeINput => inputType == AddonInputType.TIME_INPUT.name;
  bool get isDateTimeInput => inputType == AddonInputType.DATE_TIME_INPUT.name;

  Map<String, Widget>? getAddonOptions() {
    var sampleOption = options;
    if (sampleOption == null || sampleOption.isEmpty == true) {
      sampleOption =  ProductAddonOption.getSampleProductADdongOption();
    }
    Map<String, Widget>? optionsUI = {};
    for (var option in sampleOption) {
      optionsUI.addAll({option.id!: Text(option.name.localize())});
    }
    return optionsUI;
  }
}

@freezed
class ProductAddonOption with _$ProductAddonOption {
  const ProductAddonOption._();
  factory ProductAddonOption({
    String? id,
    List<LocalizedField>? name,
    List<String>? images,
  }) = _ProductAddonOption;

  factory ProductAddonOption.fromJson(Map<String, dynamic> json) => _$ProductAddonOptionFromJson(json);

  static List<ProductAddonOption> getSampleProductADdongOption() {
    return [
      ProductAddonOption(
        id: '1',
        name: [const LocalizedField(key: 'en', value: 'Option 1')],
        images: ['https://via.placeholder.com/150'],
      ),
      ProductAddonOption(
        id: '2',
        name: [const LocalizedField(key: 'en', value: 'Option 2')],
        images: ['https://via.placeholder.com/150'],
      ),
      ProductAddonOption(
        id: '3',
        name: [const LocalizedField(key: 'en', value: 'Option 3')],
        images: ['https://via.placeholder.com/150'],
      ),
    ];
  }
}
