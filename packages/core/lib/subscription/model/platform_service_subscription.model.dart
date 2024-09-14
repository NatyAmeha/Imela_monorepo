import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_service_subscription.model.freezed.dart';
part 'platform_service_subscription.model.g.dart';

@freezed
class PlatformServiceSubscription with _$PlatformServiceSubscription {
  const PlatformServiceSubscription._();

  const factory PlatformServiceSubscription({
    String? id,
    String? serviceId,
    String? serviceName,
    DateTime? startDate,
    DateTime? endDate,
    @Default(false) bool? isTrialPeriod,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CustomizationInfo>? selectedCustomizationInfo,
  }) = _PlatformServiceSubscription;

  factory PlatformServiceSubscription.fromJson(Map<String, dynamic> json) => _$PlatformServiceSubscriptionFromJson(json);
}

@freezed
class CustomizationInfo with _$CustomizationInfo {
  const CustomizationInfo._();

  const factory CustomizationInfo({
    String? id,
    String? customizationId,
    String? action,
  }) = _CustomizationInfo;

  factory CustomizationInfo.fromJson(Map<String, dynamic> json) => _$CustomizationInfoFromJson(json);
}
