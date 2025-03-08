import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/model/addon_dependency.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/address.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_utils/helpers/date_utils.dart';
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
  MULTIPLE_DATE_INPUT,
  LOCATION_PER_KM_INPUT,
  LOCATION_INPUT,
  PRODUCT_SELECTION_INPUT,
  PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT,
  NONE,
}

enum AddonCondition { NONE, MINIMUM_QUANTITY, MEMBERSHIP, MINIMUM_PURCHASE }

enum ConfigurationForType {
  OPTION_ADDON,
}

enum ConfigurationUiType {
  GRID,
  LIST,
}

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
    @Default([]) List<Configuration> configurations,
    bool? checkCalendar,
    List<Price>? additionalPrice,
    @Default(1.0) double minAmount,
    @Default(1.0) double maxAmount,
    @Default(true) bool isActive,
    @Default(false) bool isRequired,
    @Default('NONE') String condition,
    String? conditionValue,
    List<AddonDependency>? dependencies,
    List<String>? tag,
    @Default(false) bool? isProduct,
    List<String>? productIds,
    List<AddonProductOptionInfo>? productOptionInfos,
    String? calendarId,
    @Default(true) bool includeOnPOS,
    @Default(true) bool includeInBundle,
    List<Product>? products,
    String? rewardType,
    DateTime? createdAt,
    DateTime? updatedAt,
    TextAddonConfig? textAddonConfig,
  }) = _ProductAddon;

  factory ProductAddon.fromJson(Map<String, dynamic> json) => _$ProductAddonFromJson(json);

  bool get isNumberInput => inputType == AddonInputType.NUMBER_INPUT.name || inputType == AddonInputType.QUANTITY_INPUT.name;
  bool get isTextINput => inputType == AddonInputType.TEXT_INPUT.name;
  bool get isSingleSelectionInput => inputType == AddonInputType.SINGLE_SELECTION_INPUT.name;
  bool get isMultiSelectionInput => inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name;
  bool get isDateInput => inputType == AddonInputType.DATE_INPUT.name;
  bool get isTimeINput => inputType == AddonInputType.TIME_INPUT.name;
  bool get isDateTimeInput => inputType == AddonInputType.DATE_TIME_INPUT.name;

  String isOptionalOrRequiredString(String selectedLanguage) {
    if (isRequired) return LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: "Required", amharicString: "መምረጥ ያስፈልጋል");
    return LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: "Optional", amharicString: "ተጨማሪ");
  }

  Map<String, Widget>? getAddonOptions(String selectedLanguage) {
    if (options.isEmpty) return {};
    Map<String, Widget>? optionsUI = {};
    for (var option in options) {
      optionsUI.addAll({option.id!: Text(option.name.localize(selectedLanguage))});
    }
    return optionsUI;
  }

  bool canEnableAddon({double selectedQty = 0, double totalPrice = 0, bool isUserMembershipvalid = false}) {
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

  String? getAddonConditionString(String selectedLanguage, {String? unit = 'items'}) {
    if (condition == AddonCondition.MINIMUM_QUANTITY.name) {
      return '${LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: "You need to select at least $conditionValue $unit", amharicString: "ቢያንስ $conditionValue $unit መምረጥ አለብዎት")}';
    } else if (condition == AddonCondition.MINIMUM_PURCHASE.name) {
      return '${LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: "Minimum Purchase", amharicString: "መጠን ብዛት")} $conditionValue';
    }
    return null;
  }

  String requiredString(String selectedLanguage) {
    return LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: "Required", amharicString: "መምረጥ ያስፈልጋል");
  }

  double getTotalAdditionalPrice(String selectedCurrency, {double qty = 1}) {
    return ((additionalPrice!.toSelectedPrice(selectedCurrency)?.amount ?? 0) * qty).getPresision(2).toDouble();
  }

  double getAddonPriceUpdated(String selectedCurrency, {Map<String, OrderConfig>? orderConfigs, List<SelectedRewardInfo> selectedRewards = const []}) {
    final orderconfig = orderConfigs?[id];
    var finalAddonPrice = additionalPrice?.toSelectedPrice(selectedCurrency)?.amount ?? 0;
    if (inputType == AddonInputType.QUANTITY_INPUT.name) {
      final qty = double.tryParse(orderconfig?.singleValue ?? '1') ?? 1;
      finalAddonPrice = ((additionalPrice!.toSelectedPrice(selectedCurrency)?.amount ?? 0) * qty).getPresision(2).toDouble();
    } else if (inputType == AddonInputType.DATE_RANGE_INPUT.name) {
      final dateRange = orderconfig?.getConfigDateRange();
      final numberOfDays = DateHelper.getNumberofDaysFromDateRange(dateRange);
      finalAddonPrice = ((additionalPrice!.toSelectedPrice(selectedCurrency)?.amount ?? 0) * numberOfDays).getPresision(2).toDouble();
    } else if (inputType == AddonInputType.MULTIPLE_DATE_INPUT.name) {
      final dates = orderconfig?.getConfigDates();
      if (dates?.isNotEmpty == true) {
        finalAddonPrice = ((additionalPrice!.toSelectedPrice(selectedCurrency)?.amount ?? 0) * dates!.length).getPresision(2).toDouble();
      }
    } else if (inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name || inputType == AddonInputType.SINGLE_SELECTION_INPUT.name) {
      finalAddonPrice = 0.0;
      final selectedOptionsIds = inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name ? orderconfig?.multipleValue : [orderconfig?.singleValue];
      if (selectedOptionsIds?.isNotEmpty == true) {
        var selectedOptions = options.where((option) => selectedOptionsIds?.contains(option.id) ?? false).toList();
        var optionTotalPrice = selectedOptions.sumBy((options) => options.price?.toSelectedPrice(selectedCurrency)?.amount ?? 0);
        if (optionTotalPrice > 0) {
          finalAddonPrice = optionTotalPrice;
        }
      }
    } else if (inputType == AddonInputType.SINGLE_SELECTION_INPUT.name) {
      final selectedOptionId = orderconfig?.singleValue;
      if (selectedOptionId?.isNotEmpty == true) {
        var selectedOption = options.firstOrNullWhere((option) => option.id == selectedOptionId);
        finalAddonPrice = selectedOption?.price?.toSelectedPrice(selectedCurrency)?.amount ?? 0;
      }
    }
    finalAddonPrice = getAddonPriceAfterRewards(finalAddonPrice, selectedCurrency, selectedRewards);
    return finalAddonPrice;
  }

  double getAddonPriceAfterRewards(double addonPrice, String selectedCurrency, List<SelectedRewardInfo> selectedRewards) {
    var rewards = getSelectedRewardsInfo(selectedRewards);
    for (var reward in rewards) {
      if (reward.reward.isDeliveryReward()) {
        var deliveryDiscountAmount = reward.deliveryFeeDiscount ?? 0;
        addonPrice = addonPrice.getPercentageOff([deliveryDiscountAmount]);
      }
    }
    return addonPrice;
  }

  List<SelectedRewardInfo> getSelectedRewardsInfo(List<SelectedRewardInfo> selectedRewards) {
    return selectedRewards.where((element) => element.reward.rewardTypes?.contains(rewardType) ?? false).toList();
  }

  String getTotalAdditionalPriceString(String selectedCurrency, {double qty = 1}) {
    if (additionalPrice?.isEmpty == true) {
      return '';
    }
    final totalPrice = getTotalAdditionalPrice(selectedCurrency, qty: qty);
    return '+ $selectedCurrency $totalPrice';
  }

  // List<String> get productIds => productOptionInfos?.map((info) => info.productId).toList() ?? [];

  List<Product> getProducts() {
    return productOptionInfos?.map((info) => info.product).whereNotNull().toList() ?? [];
  }

  List<ProductAddon> getDependentAddons(List<ProductAddon> addons) {
    return addons?.where((e) => e.dependencies?.any((depend) => depend.addonId == id) ?? false).toList() ?? [];
  }

  List<String> getDependentAddonIds(List<ProductAddon> addons) {
    final dependentAddons = getDependentAddons(addons);
    return dependentAddons.map((e) => e.id!).toList();
  }

  List<AddonProductOptionInfo> getProductOptionInfos() {
    return productOptionInfos ?? [];
  }

  AddonProductOptionInfo? getProductAddonOptionInfo(String productId, String selectedLanguage) {
    return productOptionInfos?.firstOrNullWhere((info) => info.productId == productId);
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
    @Default(1) int maxSelection,
    List<Address>? addresses,
  }) = _ProductAddonOption;

  factory ProductAddonOption.fromJson(Map<String, dynamic> json) => _$ProductAddonOptionFromJson(json);

  String? getOptionPriceString(String selectedCurrency) {
    if (price?.isEmpty ?? true) return null;
    if ((price.toSelectedPrice('ETB')?.amount == 0)) return null;
    return '+${price?.toSelectedPriceString(selectedCurrency)}';
  }
}

@freezed
class Configuration with _$Configuration {
  const Configuration._();
  factory Configuration({
    String? forType,
    @Default('LIST') String uiType,
    int? row,
  }) = _Configuration;

  factory Configuration.fromJson(Map<String, dynamic> json) => _$ConfigurationFromJson(json);
}

@freezed
class AddonProductOptionInfo with _$AddonProductOptionInfo {
  const AddonProductOptionInfo._();
  factory AddonProductOptionInfo({
    required String productId,
    required List<Discount> discounts,
    @Default(1) double minQty,
    @Default(10) double maxQty,
    Product? product,
  }) = _AddonProductOptionInfo;

  factory AddonProductOptionInfo.fromJson(Map<String, dynamic> json) => _$AddonProductOptionInfoFromJson(json);
}

@freezed
class TextAddonConfig with _$TextAddonConfig {
  const TextAddonConfig._();
  factory TextAddonConfig({
    double? minLength,
    double? maxLength,
  }) = _TextAddonConfig;

  factory TextAddonConfig.fromJson(Map<String, dynamic> json) => _$TextAddonConfigFromJson(json);
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

  List<String> getRequiredQtyTypeAddonsId() {
    return where((element) => element.isRequired && element.inputType == AddonInputType.QUANTITY_INPUT.name).map((e) => e.id!).toList();
  }

  List<ProductAddon> getProductSelectionAddons() {
    return where((element) => element.inputType == AddonInputType.PRODUCT_SELECTION_INPUT.name || element.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name).toList();
  }

  List<ProductAddon> getNonDependentAddons({bool getDefault = false, bool forPOS = false, List<OrderConfig>? orderConfigs}) {
    var result = this;

    if (forPOS) {
      result = result.where((e) => e.includeOnPOS == true).toList();
    }
    if (getDefault) {
      result = result.where((e) => e.inputType == 'NONE').toList();
      return result;
    }
    result = result.where((e) => e.inputType != 'NONE').toList();

    // Create a new list of addons that meet the dependency requirements
    result = result.where((addon) {
      if (addon.dependencies == null || addon.dependencies!.isEmpty) return true;

      for (var dependency in addon.dependencies!) {
        if (dependency.type == AddonDependencyType.ADDON_VALUE.name) {
          var dependencyAddonConfig = orderConfigs?.firstOrNullWhere((e) => addon.dependencies?.firstOrNull?.addonId == e.addonId);
          if (!(dependency.value?.contains(dependencyAddonConfig?.singleValue) ?? false) && !(dependency.value?.containsAny(dependencyAddonConfig?.multipleValue ?? []) ?? false)) {
            return false;
          }
        }
      }
      return true;
    }).toList();

    return result;
  }

  
}
