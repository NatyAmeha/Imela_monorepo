import 'package:freezed_annotation/freezed_annotation.dart';

part 'redeemed.reward.model.freezed.dart';
part 'redeemed.reward.model.g.dart';

@freezed
class RedeemedReward with _$RedeemedReward {
  const RedeemedReward._();
  const factory RedeemedReward({
    String? id,
    String? rewardId,
    String? businessId,
    String? customerId,
    double? pointUsed,
    DateTime? createdAt,
  }) = _RedeemedReward;

  factory RedeemedReward.fromJson(Map<String, dynamic> json) => _$RedeemedRewardFromJson(json);
}
