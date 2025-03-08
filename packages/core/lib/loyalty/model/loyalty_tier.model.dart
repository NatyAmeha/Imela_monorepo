import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';

part 'loyalty_tier.model.freezed.dart';
part 'loyalty_tier.model.g.dart';

@freezed
class LoyaltyTier with _$LoyaltyTier {
  const LoyaltyTier._();
  const factory LoyaltyTier({
    String? id,
    List<LocalizedField>? name,
    List<LocalizedField>? description,
    List<Reward>? rewards,
    List<String>? businessIds,
    List<Business>? businesses,
    List<String>? productIds,
    List<Product>? products,
    int? minPoints,
    int? maxPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _LoyaltyTier;

  factory LoyaltyTier.fromJson(Map<String, dynamic> json) => _$LoyaltyTierFromJson(json);

  bool canUseRewardsFromTier(double remainingUserPoints) {
    if (minPoints == null || maxPoints == null) return true;
    var data =  remainingUserPoints >= minPoints! && remainingUserPoints <= maxPoints!;
    print('remainingUserPoints: $data $remainingUserPoints $minPoints $maxPoints');
    return data;
  }
}  
