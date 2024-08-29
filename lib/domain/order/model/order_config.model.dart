import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela/domain/product/model/product_addon.model.dart';
import 'package:imela/domain/shared/localized_field.model.dart';
import 'package:imela/presentation/utils/date_utils.dart';

part 'order_config.model.freezed.dart';
part 'order_config.model.g.dart';

@freezed
class OrderConfig with _$OrderConfig {
  const OrderConfig._();
  const factory OrderConfig({
    List<LocalizedField>? name,
    String? type,
    String? singleValue,
    List<String>? multipleValue,
    List<String>? productIds,
    @Default(0) double additionalPrice,
    String? addonId,
  }) = _OrderConfig;

  factory OrderConfig.fromJson(Map<String, dynamic> json) => _$OrderConfigFromJson(json);

  String selectedConfigValue() {
    if(type == AddonInputType.DATE_RANGE_INPUT.name){
      final dateRange = DateHelper.getDateRange(multipleValue!.take(2).toList());
      return dateRange.toFormattedString();
    }
    if (singleValue != null) {
      return '$singleValue';
    } else if (multipleValue != null) {
      return multipleValue!.join(",");
    }
    return '';
  }

  String getAdditionalPrice(String selectedCurrency) {
    return '$additionalPrice $selectedCurrency';
  }

  static OrderConfig createDateRangeOrderConfig(List<LocalizedField> name, DateTimeRange pickedDateRange, String addonId) {
    return OrderConfig(
      name: name,
      type: AddonInputType.DATE_RANGE_INPUT.name,
      multipleValue: [pickedDateRange.start.toString(), pickedDateRange.end.toString()],
      addonId: addonId,
    );
  }

  static OrderConfig createSingleSelectOrderConfig(List<LocalizedField> name, String selectedValue, String addonId) {
    return OrderConfig(
      name: name,
      type: AddonInputType.SINGLE_SELECTION_INPUT.name,
      singleValue: selectedValue,
      addonId: addonId,
    );
  }

  static OrderConfig createMultipleSelectOrderConfig(List<LocalizedField> name, List<String> selectedValues, String addonId) {
    return OrderConfig(
      name: name,
      type: AddonInputType.MULTIPLE_SELECTION_INPUT.name,
      multipleValue: selectedValues,
      addonId: addonId,
    );
  }
}
