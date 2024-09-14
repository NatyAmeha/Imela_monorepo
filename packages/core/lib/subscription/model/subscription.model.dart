import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/subscription/model/platform_service_subscription.model.dart';

part 'subscription.model.freezed.dart';
part 'subscription.model.g.dart';

@freezed
class Subscription with _$Subscription {
  const Subscription._();
  const factory Subscription({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    double? amountPaid,
    String? subscriptioinPlanId,
    bool? isTrialPeriod,
    String? type,
    String? subscribedTo,
    String? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<PlatformServiceSubscription>? platformServices,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);
}
