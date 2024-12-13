import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/number_utils.dart';

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
  LOCATION_PER_KM_INPUT,
  LOCATION_INPUT,
  PRODUCT_SELECTION_INPUT,
  PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT,
  NONE,
}

enum AddonCondition { NONE, MINIMUM_QUANTITY, MEMBERSHIP, MINIMUM_PURCHASE }

// multiple selection addon sample for hotel booking

@freezed
class ProductAddon with _$ProductAddon {
  const ProductAddon._();
  factory ProductAddon({
    String? id,
    List<LocalizedField>? summary,
    List<LocalizedField>? name,
    List<LocalizedField>? description,
    @Default('NONE') String inputType,
    List<String>? membershipIds,
    @Default([]) List<ProductAddonOption> options,
    bool? checkCalendar,
    List<Price>? additionalPrice,
    @Default(1.0) double minAmount,
    @Default(1.0) double maxAmount,
    @Default(true) bool isActive,
    @Default(false) bool isRequired,
    @Default('NONE') String condition,
    String? conditionValue,
    List<String>? tag,
    @Default(false) bool? isProduct,
    List<String>? productIds,
    List<ProductAddonOptionInfo>? productOptionInfos,
    String? calendarId,
    @Default(true) bool includeOnPOS,
    List<Product>? products,
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

  Map<String, Widget>? getAddonOptions(String selectedLanguage) {
    if (options.isEmpty) return {};
    Map<String, Widget>? optionsUI = {};
    for (var option in options) {
      optionsUI.addAll({option.id!: Text(option.name.localize(selectedLanguage))});
    }
    return optionsUI;
  }

  bool canEnableAddon({double selectedQty = 0, double totalPrice = 0, bool isUserMembershipvalid = false}) {
    print('membership check ${selectedQty} ${condition} ${conditionValue} $totalPrice');
    var conditionCheck = false;
    if (condition == AddonCondition.NONE.name) {
      conditionCheck = true;
    } else if (condition == AddonCondition.MINIMUM_QUANTITY.name && selectedQty >= double.parse(conditionValue ?? '0')) {
      conditionCheck = true;
    } else if (condition == AddonCondition.MINIMUM_PURCHASE.name && totalPrice >= double.parse(conditionValue ?? '0')) {
      conditionCheck = true;
    }

    if (membershipIds?.isNotEmpty == true) {
      return conditionCheck && isUserMembershipvalid;
    }
    return conditionCheck;
  }

  String requiredString(String selectedLanguage) {
    return LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: "Required", amharicString: "መምረጥ ያስፈልጋል");
  }

  double getTotalAdditionalPrice(String selectedCurrency, {double qty = 1}) {
    return ((additionalPrice!.toSelectedPrice(selectedCurrency)?.amount ?? 0) * qty).getPresision(2).toDouble();
  }

  String getTotalAdditionalPriceString(String selectedCurrency, {double qty = 1}) {
    if (additionalPrice?.isEmpty == true) {
      return '';
    }
    final totalPrice = getTotalAdditionalPrice(selectedCurrency, qty: qty);
    return '+ $selectedCurrency $totalPrice';
  }
}

@freezed
class ProductAddonOption with _$ProductAddonOption {
  const ProductAddonOption._();
  factory ProductAddonOption({
    String? id,
    List<LocalizedField>? name,
    List<String>? images,
    List<String>? membershipIds,
    List<Price>? price,
  }) = _ProductAddonOption;

  factory ProductAddonOption.fromJson(Map<String, dynamic> json) => _$ProductAddonOptionFromJson(json);

  String? getOptionPriceString(String selectedCurrency) {
    if (price?.isEmpty ?? true) return null;
    return '+${price?.toSelectedPriceString(selectedCurrency)}';
  }
}

@freezed
class ProductAddonOptionInfo with _$ProductAddonOptionInfo {
  factory ProductAddonOptionInfo({
    required String productId,
    required List<Discount> discounts,
    @Default(1) double minQty,
    @Default(10) double maxQty,
  }) = _ProductAddonOptionInfo;

  factory ProductAddonOptionInfo.fromJson(Map<String, dynamic> json) => _$ProductAddonOptionInfoFromJson(json);
}

@freezed
class AddonConfig with _$AddonConfig {
  const AddonConfig._();
  factory AddonConfig({
    required List<OrderConfig> orderConfigs,
    List<OrderItem>? additionalItems,
  }) = _AddonConfig;

  factory AddonConfig.fromJson(Map<String, dynamic> json) => _$AddonConfigFromJson(json);

  AddonConfig removeQtyConfig() {
    return AddonConfig(orderConfigs: List<OrderConfig>.from(orderConfigs.where((element) => element.addonId != OrderConfig.QTY_CONFIG_ID)));
  }
}

extension ProductAddonExtension on List<ProductAddon> {
  List<String> getRequiredAddonsId() {
    return where((element) => element.isRequired).map((e) => e.id!).toList();
  }
}
