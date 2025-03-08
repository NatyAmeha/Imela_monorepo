import 'dart:convert';
import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_utils/helpers/date_utils.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/number_utils.dart';

part 'discount.model.freezed.dart';
part 'discount.model.g.dart';

@freezed
// @JsonSerializable(explicitToJson: true)
class Discount with _$Discount {
  const Discount._();
  factory Discount({
    String? id,
    List<LocalizedField>? name,
    @Default("PERCENTAGE") String type,
    @Default(0) double value,
    @Default('NONE') String condition,
    String? conditionValue,
    DateTime? startDate,
    DateTime? endDate,
    @Default(DiscountSource.BUSINESS_OFFER) DiscountSource source,
  }) = _Discount;

  factory Discount.fromJson(Map<String, dynamic> json) => _$DiscountFromJson(json);

  String getId() {
    return id ?? Random().nextInt(1000000).toString();
  }

  String getDiscountValueString(String currency) {
    if (type == DiscountType.PERCENTAGE.name) {
      return '$value% off';
    }
    return '$currency $value';
  }

  String? getDiscountConditionDescription(String currency) {
    if (condition == DiscountCondition.MAXIMUM_PURCHASE.name) {
      return '$value discount on orders less $currency $conditionValue';
    } else if (condition == DiscountCondition.MINIMUM_PURCHASE.name) {
      return '$value% discount  on orders above $currency $conditionValue';
    } else if (condition == DiscountCondition.QUANTITY.name) {
      return 'You should purchase total  $conditionValue items. you can purchase any quantity of each item';
    } else if (condition == DiscountCondition.PURCHASE_ALL_ITEMS.name) {
      return 'You should purchase all items in the bundle';
    } else {
      return '';
    }
  }

  DiscountInfo toDiscountInfo({required String name, required DiscountSource source}) {
    return DiscountInfo(
      name: name,
      id: id ?? name,
      type: type == DiscountType.PERCENTAGE.name ? DiscountType.PERCENTAGE : DiscountType.AMOUNT,
      value: value,
      source: source,
    );
  }

  ItemDiscount toItemDiscount({List<LocalizedField>? defaultName, required double amount, double qty = 1}) {
    final discountAmount = (amount * qty).getPercentage(value, deductPercentageFromOriginalPrice: false);
    return ItemDiscount(id: id, name: name ?? defaultName, percentage: value, amount: discountAmount, source: source);
  }

  double getDiscountedSubtotal(double price) {
    if (type == DiscountType.PERCENTAGE.name) {
      return price.getPercentage(value, deductPercentageFromOriginalPrice: false);
    }
    return price - value;
  }

  double getTotalDiscount(double price, {double selectedQty = 1}) {
    if (type == DiscountType.PERCENTAGE.name) {
      return price.getPercentage(value, deductPercentageFromOriginalPrice: false) * selectedQty;
    }
    return value;
  }

  Duration get remainingTime {
    return DateHelper.getDateDifference(startDate: DateTime.now(), endDate: endDate);
  }

  Discount addName(List<LocalizedField> name) {
    return copyWith(name: name);
  }
}

enum DiscountType { PERCENTAGE, AMOUNT }

enum DiscountCondition { NONE, PURCHASE_ALL_ITEMS, MINIMUM_PURCHASE, MAXIMUM_PURCHASE, QUANTITY, TIME_BASED, PRODUCT_ADDON }

enum DiscountSource {
  BUSINESS_OFFER,
  MEMBERSHIP,
  MEMBERSHIP_PRODUCTS,
  LOYALTY,
  DYNAMIC_PRICING,
}

@freezed
class DiscountInfo with _$DiscountInfo {
  const DiscountInfo._();
  factory DiscountInfo({
    required String id,
    required String name,
    @Default(DiscountType.PERCENTAGE) DiscountType type,
    @Default(0) double pointApplied,
    required double value,
    @Default(false) bool isApplied,
    required DiscountSource source,
  }) = _DiscountInfo;

  factory DiscountInfo.fromJson(Map<String, dynamic> json) => _$DiscountInfoFromJson(json);

  String getPointAppliedString(String selectedLanguage) {
    return LocalizationUtils.returnLocalizedString(
      selectedLanguage,
      englishString: '${pointApplied.getPresisionString(precision: 2)} point required',
      amharicString: '${pointApplied.getPresisionString(precision: 2)} ነጥብ ያስፈልጋል',
    );
  }

  ItemDiscount toItemDiscount() {
    final amount = type == DiscountType.PERCENTAGE ? 0.0 : value;
    return ItemDiscount(id: id, name: [LocalizedField(key: "ENGLISH", value: name)], percentage: value, amount: amount, source: source);
  }

  DiscountInfo resetToggle() {
    return copyWith(isApplied: false);
  }
}

extension DiscountListX on List<DiscountInfo>? {
  List<DiscountInfo> getLoyaltyDiscounts() {
    return this?.where((discount) => discount.source == DiscountSource.LOYALTY).toList() ?? [];
  }

  double getTotalPointApplied() {
    return this?.sumBy((element) => element.pointApplied) ?? 0;
  }
}

extension DiscountX on List<Discount> {
  String encodeDiscounts() {
    final jsonList = jsonEncode(this.map((e) => e.toJson()).toList());
    // URI encode the JSON string
    return Uri.encodeComponent(jsonList);
  }

  List<ItemDiscount> toItemDiscount({required double amount, required double qty}) {
    var subtotalAmount = amount;
    List<ItemDiscount> itemDiscounts = [];
    for (var discount in this) {
      final discountAmount = subtotalAmount.getPercentage(discount.value, deductPercentageFromOriginalPrice: false);
      itemDiscounts.add(discount.toItemDiscount(amount: subtotalAmount, qty: qty));
      subtotalAmount -= discountAmount;
    }
    return itemDiscounts;
  }
}
