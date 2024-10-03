import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_utils/helpers/date_utils.dart';
import 'package:imela_utils/helpers/number_utils.dart';

part 'discount.model.freezed.dart';
part 'discount.model.g.dart';

@freezed
// @JsonSerializable(explicitToJson: true)
class Discount with _$Discount {
  const Discount._();
  factory Discount({
    String? id,
    required String type,
    required double value,
    @Default('NONE') String condition,
    double? conditionValue,
    DateTime? startDate,
    DateTime? endDate,
  }) = _Discount;

  factory Discount.fromJson(Map<String, dynamic> json) => _$DiscountFromJson(json);

  String getId() {
    return id ?? Random().nextInt(1000000).toString();
  }

  String getDiscountValueString(String currency) {
    if (type == DiscountType.PERCENTAGE.name) {
      return '$value%';
    }
    return '$currency $value';
  }

  String? getDiscountConditionDescription(String currency) {
    if (condition == DiscountCondition.MAXIMUM_PURCHASE.name) {
      return 'on orders less $currency $conditionValue';
    } else if (condition == DiscountCondition.MINIMUM_PURCHASE.name) {
      return 'on orders above $currency $conditionValue';
    } else if (condition == DiscountCondition.QUANTITY.name) {
      return 'You should purchase total  $conditionValue items. you can purchase any quantity of each item';
    } else if (condition == DiscountCondition.PURCHASE_ALL_ITEMS.name) {
      return 'You should purchase of all items in the bundle';
    } else {
      return '';
    }
  }

  double getDiscountedSubtotal(double price) {
    if (type == DiscountType.PERCENTAGE.name) {
      return price.getPercentage(value, deductPercentageFromOriginalPrice: true);
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
    return DateHelper.getDateDifference(startDate: startDate, endDate: endDate);
  }
}

enum DiscountType { PERCENTAGE, AMOUNT }

enum DiscountCondition { NONE, PURCHASE_ALL_ITEMS, MINIMUM_PURCHASE, MAXIMUM_PURCHASE, QUANTITY, TIME_BASED }
