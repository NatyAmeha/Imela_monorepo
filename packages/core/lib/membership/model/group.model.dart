import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/subscription/model/subscription.model.dart';
import 'package:imela_core/user/model/user.model.dart';

part 'group.model.freezed.dart';
part 'group.model.g.dart';

enum GroupMemberStatus { PENDING, ACTIVE, INACTIVE, BLOCKED }

@freezed
class Group with _$Group {
  const factory Group({
    String? id,
    List<LocalizedField>? name,
    List<GroupMember>? members,
    @JsonKey(name: 'default') bool? isDefault,
    String? membershipId,
    Membership? membership,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

@freezed
class GroupMember with _$GroupMember {
  const GroupMember._();

  const factory GroupMember({
    String? userId,
    User? user,
    String? memberStatus,
    String? activeSubscriptionId,
    Subscription? activeSubscription,
    DateTime? dateJoined,
    SelectedPaymentMethod? paymentMethod,
  }) = _GroupMember;

  factory GroupMember.fromJson(Map<String, dynamic> json) => _$GroupMemberFromJson(json);

  bool get isUserMembershipStatusPending => memberStatus == GroupMemberStatus.PENDING.name;
  bool get isUserMembershipStatusActive => memberStatus == GroupMemberStatus.ACTIVE.name;
}
