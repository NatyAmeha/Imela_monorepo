import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';

part 'reward.model.freezed.dart';
part 'reward.model.g.dart';

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
    String? rewardType,
    @Default(true) bool isActive,
    String? discountType,
    double? discountAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Reward;

  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);

  String getDiscountInfo(String language) {
    if (discountType == DiscountType.AMOUNT.name) {
      return '$discountAmount  discount';
    }
    return '$discountAmount% discount';
  }

  String redeemPointString({bool showMinus = false}) {
    return '${showMinus ? '- ' : ''}$minPointsToRedeem points';
  }
}

extension RewardListX on List<Reward>? {
  List<Reward> getEligibleRewards(double point) {
    return this?.where((reward) => reward.minPointsToRedeem <= point).toList().sortedByDescending((a) => a.minPointsToRedeem) ?? [];
  }
}


