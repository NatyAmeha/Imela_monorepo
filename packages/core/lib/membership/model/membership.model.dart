import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/membership/model/group.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_core/subscription/model/subscription.model.dart';
import 'package:imela_utils/helpers/date_utils.dart';
import 'package:imela_utils/helpers/localization_utils.dart';

part 'membership.model.freezed.dart';
part 'membership.model.g.dart';

enum MembershipPerkType { DISCOUNT_ON_MEMBERS_PRODUCT, DISCOUNT, POINTS, FREE_DELIVERY }

@freezed
class Membership with _$Membership {
  const Membership._();

  const factory Membership({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<LocalizedField>? name,
    List<LocalizedField>? description,
    List<Price>? price,
    List<String>? category,
    List<Benefit>? benefits,
    @Default(30) int? duration,
    @Default(0) int? trialPeriod,
    String? type,
    String? owner,
    String? ownerName,
    bool? isActive,
    List<String>? groupsId,
    List<Group>? groups,
    List<String>? subscriptionsId,
    List<Subscription>? subscriptions,
    List<String>? membersProductIds,
    List<GroupMember>? allMembers,
    Subscription? currentUserSubscription,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) => _$MembershipFromJson(json);

  String getDurationString(String selectedLanguage) {
    return '${duration} ${LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: 'days', amharicString: 'ቀናት')}';
  }

  String membershipDurationString(String selectedLanguage) {
    return LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: '$duration days', amharicString: '$duration ቀናት');
  }

  String membershipTrialPeriodString(String selectedLanguage) {
    return LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: '$trialPeriod days', amharicString: '$trialPeriod ቀናት');
  }

  GroupMember? getMemberInfo(String userId) {
    return allMembers?.firstWhereOrNull((member) => member.userId == userId);
  }

  List<String> getPaymentProof(String userId) {
    return getMemberInfo(userId)?.paymentMethod?.receiptImages ?? [];
  }

  String getEndsInString(String selectedLanguage) {
    final endDate = DateTime.now().add(Duration(days: duration ?? 0));
    return LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: 'Ends on ${endDate.toFormattedString()}', amharicString: 'በ${endDate.toFormattedString()} ያልቃል');
  }
}

@freezed
class Benefit with _$Benefit {
  const Benefit._();
  const factory Benefit({
    String? id,
    List<LocalizedField>? name,
    String? perkType,
    List<Discount>? discounts,
  }) = _Benefit;

  factory Benefit.fromJson(Map<String, dynamic> json) => _$BenefitFromJson(json);

  List<Discount> getFullDiscontInfo(List<LocalizedField>? name) {
    return discounts?.map((discount) => discount.copyWith(name: name?.isNotEmpty == true ? name : [const LocalizedField(key: 'ENGLISH', value: 'Membership discount')])).toList() ?? [];
  }
}

extension BenefitExtension on List<Benefit> {
  List<Discount> getDiscounts() {
    return map((benefit) => benefit.discounts?.first).whereNotNull().toList();
  }
}
