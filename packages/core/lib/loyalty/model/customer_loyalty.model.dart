import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/loyalty/model/loyalty_tier.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/loyalty/model/reward_info.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/number_utils.dart';

part 'customer_loyalty.model.freezed.dart';
part 'customer_loyalty.model.g.dart';

@freezed
class CustomerLoyalty with _$CustomerLoyalty {
  const CustomerLoyalty._();
  const factory CustomerLoyalty({
    String? id,
    String? customerId,
    List<LocalizedField>? name,
    String? businessId,
    List<PointSource>? pointsSource,
    @Default(0) double currentPoints,
    LoyaltyTier? currentTier,
    List<LoyaltyTier>? loyaltyTiers,
    List<Reward>? rewards,
    Customer? customer,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CustomerLoyalty;

  factory CustomerLoyalty.fromJson(Map<String, dynamic> json) => _$CustomerLoyaltyFromJson(json);

  String currentPointsString(String language) {
    if (language == AppLanguage.AMHARIC.name) {
      return '${currentPoints?.getPresisionString(precision: 2)} ነጥብ';
    } else {
      return '${currentPoints?.getPresisionString(precision: 2)} points';
    }
  }

  String rewardCountString(String language) {
    if (language == AppLanguage.AMHARIC.name) {
      return '${rewards?.length} ሽልማቶች';
    } else {
      return '${rewards?.length} rewards';
    }
  }
}

@freezed
class PointSource with _$PointSource {
  const factory PointSource({
    String? id,
    String? name,
    String? sourceId,
    String? sourceType,
    double? value,
  }) = _PointSource;

  factory PointSource.fromJson(Map<String, dynamic> json) => _$PointSourceFromJson(json);
}
