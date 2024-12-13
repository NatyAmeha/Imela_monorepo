import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_utils/helpers/date_utils.dart';

part 'order_config.model.freezed.dart';
part 'order_config.model.g.dart';

@freezed
class OrderConfig with _$OrderConfig {
  static const String QTY_CONFIG_ID = 'QTY_CONFIG_ID'; // this is the id for the qty config in product addon config modal
  static const String ORDER_ITEM_CONFIG_ID = "ORDER_ITEM_CONFIG_ID"; // this is the id for the order item config in product addon config modal
  static const String ADDITIONAL_PRODUCT_CONFIG_ID = "ADDITIONAL_PRODUCT_CONFIG_ID"; // this is the id for the additional product config in product addon config modal
  const OrderConfig._();
  const factory OrderConfig({
    List<LocalizedField>? name,
    String? type,
    String? singleValue,
    String? calendarId,
    List<String>? multipleValue,
    List<String>? productIds,
    List<Product>? products,
    @Default(0) double additionalPrice,
    @Default(0) double finalPrice,
    String? addonId,
  }) = _OrderConfig;

  factory OrderConfig.fromJson(Map<String, dynamic> json) => _$OrderConfigFromJson(json);

  double get getAdditionalPriceWithQty {
    if (type == AddonInputType.NUMBER_INPUT.name || type == AddonInputType.QUANTITY_INPUT.name) {
      var addonConfigQty = double.tryParse(singleValue ?? '') ?? 1.0;
      return additionalPrice * addonConfigQty;
    } else if (type == AddonInputType.MULTIPLE_SELECTION_INPUT.name) {
      return additionalPrice * (multipleValue?.length ?? 0);
    }
    return 0;
  }

  DateTimeRange? getConfigDateRange() {
    final dateRangeString = multipleValue?.take(2).toList();
    if (dateRangeString?.length == 2) {
      return DateHelper.parseDateRange(dateRangeString!, format: 'dd/MM/yyyy');
    }
    return null;
  }

  String? getConfigNameForPOSCart(String selectedLanguage) {
    if (singleValue != null) {
      return '${name.localize(selectedLanguage)}: ${singleValue}';
    }
    if (multipleValue != null) {
      return '${name.localize(selectedLanguage)}: ${multipleValue!.join(', ')}';
    }
    return null;
  }

  String selectedConfigValue(List<ProductAddon>? addons, String? selectedLanguage) {
    if (type == AddonInputType.DATE_RANGE_INPUT.name) {
      final dateRange = DateHelper.getDateRange(multipleValue!.take(2).toList());
      return dateRange.toFormattedString();
    } else if (type == AddonInputType.PRODUCT_SELECTION_INPUT.name) {
      return '${productIds?.length} products';
    } else if (type == AddonInputType.SINGLE_SELECTION_INPUT.name || type == AddonInputType.MULTIPLE_SELECTION_INPUT.name) {
      final addon = addons?.firstOrNullWhere((e) => e.id == addonId);
      if (addon?.options.isEmpty == true) {
        if (singleValue != null) {
          return '$singleValue';
        } else if (multipleValue != null) {
          return multipleValue!.join(",");
        }
      }
      return getSelectedAddonOptionNames(addon?.options ?? [], selectedLanguage);
    } else if (singleValue != null) {
      return '$singleValue';
    } else if (multipleValue != null) {
      return multipleValue!.join(",");
    }

    return '';
  }

  double getAdditionalPriceUpdated(List<ProductAddon>? addons, String selectedCurrency) {
    if (type == AddonInputType.SINGLE_SELECTION_INPUT.name || type == AddonInputType.MULTIPLE_SELECTION_INPUT.name) {
      final addon = addons?.firstOrNullWhere((e) => e.id == addonId);
      final selectedOptions = addon?.options.where((e) => multipleValue?.contains(e.id) ?? false).toList();
      if (selectedOptions?.isNotEmpty == true) {
        return selectedOptions?.sumBy((e) => e.price?.toSelectedPrice(selectedCurrency)?.amount ?? 0) ?? addon?.additionalPrice?.toSelectedPrice(selectedCurrency)?.amount ?? 0;
      }
      return addon?.additionalPrice?.toSelectedPrice(selectedCurrency)?.amount ?? 0;
    }
    return 0;
  }

  String getAdditionalPriceStringUpdated(List<ProductAddon>? addons, String selectedCurrency) {
    return '+$selectedCurrency ${getAdditionalPriceUpdated(addons, selectedCurrency)}';
  }

  String getAdditionalPrice(String selectedCurrency) {
    return '$additionalPrice $selectedCurrency';
  }

  String getSelectedAddonOptionNames(List<ProductAddonOption> options, String? selectedLanguage) {
    final selectedAddonOptionIds = [singleValue, ...multipleValue ?? []].whereNotNull().toList();
    final selectedAddonOptions = options.where((option) => selectedAddonOptionIds.contains(option.id)).toList();

    return selectedAddonOptions.map((e) => e.name.localize(selectedLanguage ?? 'ENGLISH')).join(', ');
  }

  static OrderConfig createQtyOrderConfig(double selectedQty, {ProductAddon? addon}) {
    return OrderConfig(
      singleValue: selectedQty.toString(),
      name: addon?.name,
      type: AddonInputType.QUANTITY_INPUT.name,
      calendarId: addon?.calendarId,
      addonId: QTY_CONFIG_ID,
      additionalPrice: 0,
    ).updateFinalPrice('ETB', addons: addon != null ? [addon] : null);
  }

  static OrderConfig createDateRangeOrderConfig(List<LocalizedField> name, DateTimeRange pickedDateRange, ProductAddon addon) {
    return OrderConfig(
      name: name,
      type: AddonInputType.DATE_RANGE_INPUT.name,
      multipleValue: [pickedDateRange.start.toString(), pickedDateRange.end.toString()],
      addonId: addon.id,
      additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
    ).updateFinalPrice('ETB', addons: [addon]);
  }

  static OrderConfig createDateOrderConfig(List<LocalizedField> name, DateTime pickedDate, ProductAddon addon) {
    return OrderConfig(
      name: name,
      type: AddonInputType.DATE_INPUT.name,
      singleValue: pickedDate.toString(),
      addonId: addon.id,
      additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
    ).updateFinalPrice('ETB', addons: [addon]);
  }

  OrderConfig updateFinalPrice(String selectedCurrency, {List<ProductAddon>? addons}) {
    return copyWith(finalPrice: getAdditionalPriceUpdated(addons, selectedCurrency));
  }

  static OrderConfig createSingleSelectOrderConfig(List<LocalizedField> name, String selectedValue, ProductAddon addon) {
    return OrderConfig(
      name: name,
      type: AddonInputType.SINGLE_SELECTION_INPUT.name,
      singleValue: selectedValue,
      addonId: addon.id,
      additionalPrice: addon.additionalPrice!.toSelectedPrice('ETB')?.amount ?? 0,
    ).updateFinalPrice('ETB', addons: [addon]);
  }

  static OrderConfig createNumberInputOrderConfig(List<LocalizedField> name, double selectedValue, ProductAddon addon) {
    print('additionalPrice: ${addon.additionalPrice?.toSelectedPrice('ETB')?.amount}');
    return OrderConfig(
      name: name,
      type: AddonInputType.NUMBER_INPUT.name,
      singleValue: selectedValue.toString(),
      addonId: addon.id,
      additionalPrice: addon.additionalPrice!.toSelectedPrice('ETB')?.amount ?? 0,
    ).updateFinalPrice('ETB', addons: [addon]);
  }

  static OrderConfig createMultipleSelectOrderConfig(List<LocalizedField> name, List<String> selectedValues, ProductAddon addon) {
    return OrderConfig(
      name: name,
      type: AddonInputType.MULTIPLE_SELECTION_INPUT.name,
      multipleValue: selectedValues,
      addonId: addon.id,
      additionalPrice: addon.additionalPrice!.toSelectedPrice('ETB')?.amount ?? 0,
    ).updateFinalPrice('ETB', addons: [addon]);
  }
}
