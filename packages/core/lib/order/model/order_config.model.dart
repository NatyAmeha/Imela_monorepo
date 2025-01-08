import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_utils/helpers/date_utils.dart';
import 'package:imela_utils/helpers/number_utils.dart';

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
    List<String>? rewardTypes,
    List<SelectedRewardInfo>? rewards,
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
    if (multipleValue != null && multipleValue!.length >= 2) {
      final startDate = multipleValue!.first;
      final endDate = multipleValue!.last;
      return DateHelper.parseDateRange([startDate, endDate], format: 'dd/MM/yyyy');
    }
    return null;
  }

  List<DateTime>? getConfigDates() {
    if (multipleValue != null) {
      return multipleValue!.map((date) => DateHelper.parseDate(date, format: 'dd/MM/yyyy HH:mm')).toList();
    }
    return null;
  }

  DateTime? getConfigDate() {
    if (singleValue != null) {
      return DateHelper.parseDate(singleValue!, format: 'dd/MM/yyyy HH:mm');
    }
    return null;
  }

  String getConfigDateRangeString() {
    final dateRange = getConfigDateRange();
    if (dateRange != null) {
      return '${dateRange.start.toFormattedString(format: 'dd/MM/yyyy')} - ${dateRange.end.toFormattedString(format: 'dd/MM/yyyy')}';
    }
    return '';
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
      final dateRange = getConfigDateRangeString();
      return dateRange;
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
    if (type == AddonInputType.QUANTITY_INPUT.name) {
      final qty = double.tryParse(singleValue ?? '1') ?? 1;
      return (additionalPrice * qty).getPresision(2);
    } else if (type == AddonInputType.DATE_RANGE_INPUT.name) {
      final dateRange = getConfigDateRange();
      final numberOfDays = DateHelper.getNumberofDaysFromDateRange(dateRange);
      return (additionalPrice * numberOfDays).getPresision(2).toDouble();
    } else if (type == AddonInputType.MULTIPLE_SELECTION_INPUT.name || type == AddonInputType.SINGLE_SELECTION_INPUT.name) {
      final selectedOptionsIds = type == AddonInputType.MULTIPLE_SELECTION_INPUT.name ? multipleValue : [singleValue];
      if (selectedOptionsIds?.isNotEmpty == true) {
        final selectedAddon = addons?.firstOrNullWhere((e) => e.id == addonId);
        var selectedOptions = selectedAddon?.options.where((option) => selectedOptionsIds?.contains(option.id) ?? false).toList();
        var optionTotalPrice = selectedOptions?.sumBy((options) => options.price?.toSelectedPrice(selectedCurrency)?.amount ?? 0);
        if (optionTotalPrice == 0) {
          return additionalPrice;
        }
        return optionTotalPrice ?? 0;
      }
      return additionalPrice;
    }
    return additionalPrice;
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

  OrderConfig addRewards(List<SelectedRewardInfo> rewards) {
    return copyWith(rewards: rewards);
  }

  OrderConfig removeRewards(List<SelectedRewardInfo> rewards) {
    final rewardsToRemove = rewards.map((e) => e.reward.id).toList();
    final updatedRewards = this.rewards?.where((e) => !rewardsToRemove.contains(e.reward.id)).toList();
    return copyWith(rewards: updatedRewards);
  }

  OrderConfig removeAllRewards() {
    return copyWith(rewards: []);
  }

  static OrderConfig createQtyOrderConfig(double selectedQty, {ProductAddon? addon, bool isQtyConfig = false}) {
    final additionalPrice = addon?.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0;
    return OrderConfig(
      singleValue: selectedQty.toString(),
      name: addon?.name,
      type: AddonInputType.QUANTITY_INPUT.name,
      calendarId: addon?.calendarId,
      addonId: isQtyConfig ? QTY_CONFIG_ID : addon?.id,
      additionalPrice: additionalPrice,
      finalPrice: (additionalPrice * selectedQty).getPresision(2),
    ).updateFinalPrice('ETB', addons: addon != null ? [addon] : null);
  }

  static OrderConfig createDateRangeOrderConfig(List<LocalizedField> name, DateTimeRange? pickedDateRange, ProductAddon addon) {
    final allDates = List.generate(pickedDateRange?.duration.inDays ?? 0 + 1, (index) => pickedDateRange?.start.add(Duration(days: index))).map((date) => date.toFormattedString(format: 'dd/MM/yyyy')).toList();
    return OrderConfig(
      name: name,
      type: AddonInputType.DATE_RANGE_INPUT.name,
      multipleValue: allDates,
      addonId: addon.id,
      additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
    ).updateFinalPrice('ETB', addons: [addon]);
  }

  static OrderConfig createDateOrderConfig(List<LocalizedField> name, List<DateTime> pickedDates, ProductAddon addon) {
    return OrderConfig(
      name: name,
      type: AddonInputType.DATE_INPUT.name,
      multipleValue: pickedDates.map((date) => date.toFormattedString(format: 'dd/MM/yyyy HH:mm')).toList(),
      singleValue: addon.inputType == AddonInputType.MULTIPLE_DATE_INPUT.name ? null : pickedDates.first.toFormattedString(format: 'dd/MM/yyyy HH:mm'),
      addonId: addon.id,
      additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
    ).updateFinalPrice('ETB', addons: [addon]);
  }

  OrderConfig updateFinalPrice(String selectedCurrency, {List<ProductAddon>? addons}) {
    return copyWith(finalPrice: getAdditionalPriceUpdated(addons, selectedCurrency));
  }

  static OrderConfig createSingleSelectOrderConfig(List<LocalizedField> name, String selectedValue, ProductAddon addon) {
    var selectedOption = addon.options.firstWhere((e) => e.id == selectedValue);
    final additionalPrice = selectedOption.price?.toSelectedPrice('ETB')?.amount ?? addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0;
    return OrderConfig(
      name: name,
      type: AddonInputType.SINGLE_SELECTION_INPUT.name,
      singleValue: selectedValue,
      addonId: addon.id,
      additionalPrice: additionalPrice,
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
    final selectedOptions = addon.options.where((e) => selectedValues.contains(e.id)).toList();
    final additionalPrice = selectedOptions.sumBy((options) => options.price?.toSelectedPrice('ETB')?.amount ?? 0);
    return OrderConfig(
      name: name,
      type: AddonInputType.MULTIPLE_SELECTION_INPUT.name,
      multipleValue: selectedValues,
      addonId: addon.id,
      additionalPrice: additionalPrice,
    ).updateFinalPrice('ETB', addons: [addon]);
  }
}

extension OrderConfigExtension on List<OrderConfig> {
  List<OrderConfig> addOrRemoveRewards(List<SelectedRewardInfo> rewards) {
    final updatedConfigs = <OrderConfig>[];
    for (var config in this) {
      final rewardForConfig = rewards.where((e) => e.reward.rewardTypes?.containsAny(config.rewardTypes ?? []) ?? false).toList();
      if (rewardForConfig.isNotEmpty == true) {
        final updatedConfig = config.addRewards(rewardForConfig);
        updatedConfigs.add(updatedConfig);
      } else {
        final updatedConfig = config.removeAllRewards();
        updatedConfigs.add(updatedConfig);
      }
    }
    return updatedConfigs;
  }
}
