import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/loyalty/model/redeemed.reward.model.dart';
import 'package:imela_core/membership/model/group.model.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/subscription/model/subscription.model.dart';
import 'package:imela_utils/helpers/localization_utils.dart';

part 'customer.model.freezed.dart';
part 'customer.model.g.dart';

@freezed
class Customer with _$Customer {
  const Customer._();
  const factory Customer({
    required String id,
    required String name,
    String? userId,
    String? businessId,
    String? phoneNumber,
    String? email,
    List<CustomerLoyalty>? customerLoyalties,
    List<RedeemedReward>? redeemedRewards,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);

  List<CustomerWithMembership> getCustomerMemberships(List<Membership> allMemberships) {
    List<CustomerWithMembership> customerMemberships = [];
    for (var membership in allMemberships) {
      final isCustomerMember = membership.allMembers?.any((member) => member.userId == userId) ?? false;
      if (isCustomerMember) {
        final customerMembership = getCustomerMembershipInfo(membership.id!, allMemberships);
        if (customerMembership != null) {
          customerMemberships.add(customerMembership);
        }
      }
    }
    return customerMemberships;
  }

  List<String> getCustomerMembershipIds(List<Membership> allMemberships) {
    return getCustomerMemberships(allMemberships).map((e) => e.membership.id).whereType<String>().toList();
  }

  CustomerWithMembership? getCustomerMembershipInfo(String membershipId, List<Membership> allMemberships) {
    final selectedMembership = allMemberships.firstWhereOrNull((membership) => membership.id == membershipId);
    if (selectedMembership == null) {
      return null;
    }
    final subscription = selectedMembership.allMembers?.firstWhereOrNull((member) => member.userId == userId)?.activeSubscription;
    return CustomerWithMembership(membership: selectedMembership, subscription: subscription);
  }

  bool isCustomerAMember(String? membershipId, List<Membership> allMemberships) {
    if (membershipId == null) return false;
    return getCustomerMembershipInfo(membershipId, allMemberships)?.subscription != null;
  }



}

@freezed
class CustomerWithMembership with _$CustomerWithMembership {
  const CustomerWithMembership._();
  const factory CustomerWithMembership({
    required Membership membership,
    Subscription? subscription,
  }) = _CustomerWithMembership;

  factory CustomerWithMembership.fromJson(Map<String, dynamic> json) => _$CustomerWithMembershipFromJson(json);

  DiscountInfo? toDiscountInfo() {
    final discount = membership.benefits?.getDiscounts().firstOrNull;
    if (discount == null) {
      return null;
    }
    return DiscountInfo( 
      name: "${membership.name?.localize('ENGLISH')} discount",
      id: membership.id ?? '',
      type: DiscountType.PERCENTAGE,
      value: discount.value,
      source: DiscountSource.MEMBERSHIP,
    );
  }

  GroupMember? getCustomerGroupMemberInfo(String customerId) {
    return membership.allMembers?.firstWhereOrNull((member) => member.userId == customerId);
  }

  String membershipSubscriptionStatusString(String selectedLanguage,{String? customerId}) {
    if(subscription?.isSubscriptionActive() ?? false){
      return LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: 'Active', amharicString: 'የሚሰራ');
    }
    final memberJoinStatus = getCustomerGroupMemberInfo(customerId ?? '');
    if(memberJoinStatus?.memberStatus == GroupMemberStatus.PENDING.name){
      return LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: 'Waiting approval', amharicString: 'እስኪጸድቅ በመጠባበቅ ላይ');
    }
    return LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: 'Inactive', amharicString: 'ጊዘው አብቅቷል');
  }
}
