import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/localized_field.model.dart';

part 'subscription_renewal.model.freezed.dart';
part 'subscription_renewal.model.g.dart';

@freezed
class SubscriptionRenewal with _$SubscriptionRenewal {
  const SubscriptionRenewal._();

  const factory SubscriptionRenewal({
    String? id,
    List<LocalizedField>? name,
    @Default(90) int duration,
    @Default(90) int trialPeriod,
    @Default(0) int discountAmount,
  }) = _SubscriptionRenewal;

  factory SubscriptionRenewal.fromJson(Map<String, dynamic> json) => _$SubscriptionRenewalFromJson(json);
}
