import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/membership/model/group.model.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/subscription/model/subscription.model.dart';

part 'membership_response.freezed.dart';
part 'membership_response.g.dart';

@freezed
class MembershipResponse with _$MembershipResponse{


  const MembershipResponse._();

  const factory MembershipResponse({
    bool? success,
    String? message, 
    Membership? membership,
    List<Membership>? memberships,
    List<Product>? products,
    List<GroupMember>? modifiedMembers,
    Subscription? currentUserSubscription,
  }) = _MembershipResponse;

  factory MembershipResponse.fromJson(Map<String, dynamic> json) => _$MembershipResponseFromJson(json);

  List<String> get membershipIds => memberships?.map((e) => e.id).whereType<String>().toList() ?? [];


  Subscription? getCurrentUserSubscription(String membershipId) {
    return memberships?.firstWhereOrNull((e) => e.currentUserSubscription != null)?.currentUserSubscription ?? currentUserSubscription;
  }

  bool isCurrentUserSubscriptionActive(String? membershipId) {
    if (membershipId == null) return false;
    final subscription = getCurrentUserSubscription(membershipId);
    return subscription?.endDate?.isAfter(DateTime.now()) ?? false;
  }
  
  
}