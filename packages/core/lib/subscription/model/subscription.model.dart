import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/subscription/model/platform_service_subscription.model.dart';
import 'package:imela_utils/helpers/localization_utils.dart';

part 'subscription.model.freezed.dart';
part 'subscription.model.g.dart';

@freezed
class Subscription with _$Subscription {
  const Subscription._();
  const factory Subscription({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    @Default(0) double? amountPaid,
    String? subscriptioinPlanId,
    @Default(false) bool? isTrialPeriod,
    String? type,
    String? subscribedTo,
    String? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(true) bool isActive,
    List<PlatformServiceSubscription>? platformServices,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);

  int get daysLeftToExpire => endDate?.difference(DateTime.now()).inDays ?? 0;

  bool isSubscriptionActive() {
    return isActive && endDate != null && endDate!.isAfter(DateTime.now());
  }

  String subscriptionStatusString(String selectedLanguage) {
    if (isSubscriptionActive()) {
      return LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: 'Active', amharicString: 'የሚሰራ');
    } else {
      return LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: 'Inactive', amharicString: 'ጊዘው አብቅቷል');
    }
  }

  String daysLeftToExpireString(String selectedLanguage) {
    return LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: 'Ends in $daysLeftToExpire days', amharicString: 'ክ $daysLeftToExpire ቀናት በኋላ ያልቃል');
  }
}
