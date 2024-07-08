import 'package:freezed_annotation/freezed_annotation.dart';

part 'discount.model.freezed.dart';
part 'discount.model.g.dart';

@freezed
// @JsonSerializable(explicitToJson: true)
class Discount with _$Discount {
  factory Discount({
    required String type,
    required double value,
    @Default('NONE') String condition,
    double? conditionValue,
  }) = _Discount;

  factory Discount.fromJson(Map<String, dynamic> json) =>
      _$DiscountFromJson(json);
}

enum DiscountType {
  PERCENTAGE,
  AMOUNT
}

enum DiscountCondition {
  NONE,
  PURCHASE_ALL_ITEMS,
  MINIMUM_PURCHASE,
  MAXIMUM_PURCHASE,
  QUANTITY,
}