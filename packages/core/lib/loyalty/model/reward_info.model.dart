import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';

part 'reward_info.model.freezed.dart';
part 'reward_info.model.g.dart';

@freezed
class RewardInfo with _$RewardInfo {
  const RewardInfo._();
  const factory RewardInfo({
    Discount? discount,
    DeliveryRewardInfo? deliveryRewardInfo,
    List<RewardProductInfo>? products,
  }) = _RewardInfo;

  factory RewardInfo.fromJson(Map<String, dynamic> json) => _$RewardInfoFromJson(json);
}

@freezed
class RewardProductInfo with _$RewardProductInfo {
  const RewardProductInfo._();
  const factory RewardProductInfo({
    String? id,
    String? productId,
    Product? product,
    @Default(1) double minQty,
    @Default(10) double maxQty,
    RewardProductCriteria? criteria,
    Discount? discount,
  }) = _RewardProductInfo;

  factory RewardProductInfo.fromJson(Map<String, dynamic> json) => _$RewardProductInfoFromJson(json);


  Discount? getDiscount(String productId) {
    if(productId == productId) {
      return discount;
    }
    return null;
  }
}

@freezed
class RewardProductCriteria with _$RewardProductCriteria {
  const RewardProductCriteria._();
  const factory RewardProductCriteria({
    String? id,
    double? minPurchaseAmount,
    List<String>? purchasedProductIds,
  }) = _RewardProductCriteria;

  factory RewardProductCriteria.fromJson(Map<String, dynamic> json) => _$RewardProductCriteriaFromJson(json);
}

@freezed
class DeliveryRewardInfo with _$DeliveryRewardInfo {
  const DeliveryRewardInfo._();
  const factory DeliveryRewardInfo({
    String? id,
    List<LocalizedField>? description,
    double? minPurchaseAmount,
    Discount? discount,
  }) = _DeliveryRewardInfo;

  factory DeliveryRewardInfo.fromJson(Map<String, dynamic> json) => _$DeliveryRewardInfoFromJson(json);
}



