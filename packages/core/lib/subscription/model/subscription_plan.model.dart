import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/subscription/model/subscription.model.dart';

part 'subscription_plan.model.freezed.dart';
part 'subscription_plan.model.g.dart';


@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const SubscriptionPlan._();
  const factory SubscriptionPlan({
    String? id,
    List<LocalizedField>? name,
    List<LocalizedField>? description,
    double? price,
    List<String>? category,
    // List<Benefit>? benefits,
    int? duration,
    int? trialPeriod,
    String? type,
    String? owner,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Subscription>? subscriptions,
  }) = _SubscriptionPlan;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => _$SubscriptionPlanFromJson(json);
}