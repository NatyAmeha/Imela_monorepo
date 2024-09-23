import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_utils/helpers/number_utils.dart';

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

  double getTotalPrice(double basePrice) {
    if (trialPeriod > 0) {
      return 0;
    } else {
      return (basePrice.getPercentage(discountAmount.toDouble())) * (duration / 30);
    }
  }

  String getTotalPriceString(double basePrice) {
    final totalPrice = getTotalPrice(basePrice);
    return 'ETB $totalPrice';
  }
}
