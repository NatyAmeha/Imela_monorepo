import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/subscription/model/platform_service.model.dart';
import 'package:imela_core/subscription/model/platform_service_subscription.model.dart';
import 'package:imela_core/subscription/model/subscription.model.dart';

part 'subscription.response.freezed.dart';
part 'subscription.response.g.dart';

@freezed
class SubscriptionResponse with _$SubscriptionResponse {
  const SubscriptionResponse._();
  const factory SubscriptionResponse({
    bool? success,
    String? message,
    Subscription? subscription,
    List<Subscription>? subscriptions,
    List<Subscription>? existingActiveSubscriptions,
    List<Subscription>? deletedSubscritpions,
    List<PlatformServiceSubscription>? addedPlatformServices,
    List<PlatformServiceSubscription>? existingPlatformService,
    List<PlatformService>? platformServices,
    List<String>? platformServicehavingFreeTrial,
  }) = _SubscriptionResponse;

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) => _$SubscriptionResponseFromJson(json);
}
