import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/loyalty/model/reward_info.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';

part 'reward.model.freezed.dart';
part 'reward.model.g.dart';

enum RewardType {
  DISCOUNT,
  POINTS,
  FREE_DELIVERY,
  PRODUCT,
  DELIVERY_DISCOUNT,
  FREE_ITEM,
  ADDON_REWARD,
}

enum RewardCriteria {
  ORDER_PRICE,
  ADDON_OPTION,
}

@freezed
class Reward with _$Reward {
  const Reward._();
  const factory Reward({
    required String id,
    required List<LocalizedField> name,
    required int minPointsToRedeem,
    List<LocalizedField>? description,
    List<LocalizedField>? conditions,
    String? businessId,
    @Default(false) bool applyOnAddon,
    List<String>? rewardTypes,
    List<RewardInfo>? rewardInfo,
    @Default(true) bool isActive,
    String? discountType,
    double? discountAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Reward;

  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);

  bool isProductReward() {
    return rewardTypes?.containsAny([RewardType.PRODUCT.name, RewardType.FREE_ITEM.name]) ?? false;
  }

  bool isDeliveryReward() {
    return rewardTypes?.containsAny([RewardType.FREE_DELIVERY.name, RewardType.DELIVERY_DISCOUNT.name]) ?? false;
  }

  bool isDiscountReward() {
    return rewardTypes?.containsAny([RewardType.DISCOUNT.name]) ?? false;
  }

  String getDiscountInfo(String language) {
    if (rewardInfo?.firstOrNull?.discount?.condition == DiscountType.AMOUNT.name) {
      return '${rewardInfo?.firstOrNull?.discount?.value}  discount';
    }
    return '${rewardInfo?.firstOrNull?.discount?.value}% discount';
  }

  String redeemPointString({bool showMinus = false}) {
    return '${showMinus ? '- ' : ''}$minPointsToRedeem points';
  }
}

@freezed
class SelectedRewardInfo with _$SelectedRewardInfo {
  const SelectedRewardInfo._();
  const factory SelectedRewardInfo({
    required Reward reward,
    List<Product>? products,
    Discount? discount,
    double? deliveryFeeDiscount,
  }) = _SelectedRewardInfo;

  factory SelectedRewardInfo.fromJson(Map<String, dynamic> json) => _$SelectedRewardInfoFromJson(json);

  SelectedRewardInfo setDeliveryFeeDiscount(double discount) {
    return copyWith(deliveryFeeDiscount: discount);
  }

  setProducts(List<Product> list) {
    return copyWith(products: list);
  }
}

extension SelectedRewardInfoX on List<SelectedRewardInfo> {
  void updateByRewardId(String rewardId, {required SelectedRewardInfo updatedInfo}) {
    final index = indexWhere((info) => info.reward.id == rewardId);
    if (index != -1) {
      this[index] = updatedInfo;
    }
  }

  List<String> getRewardIds() {
    return map((info) => info.reward.id).toList();
  }
}

extension RewardListX on List<Reward>? {
  List<Reward> getEligibleRewards(double point) {
    return this?.where((reward) => reward.minPointsToRedeem <= point).toList().sortedByDescending((a) => a.minPointsToRedeem) ?? [];
  }

  List<Reward> getEligibleRewardsBasedOnAddonReward(List<ProductAddon> addons) {
    var addonsReward = addons.map((addon) => addon.rewardType).whereNotNull().toList();
    var eligibleRewards = <Reward>[];
    for (var reward in this ?? <Reward>[]) {
      if (reward.applyOnAddon) {
        if (reward.rewardTypes?.containsAny(addonsReward) ?? false) {
          eligibleRewards.add(reward);
        }
      } else {
        eligibleRewards.add(reward);
      }
    }
    return eligibleRewards;
  }
}
