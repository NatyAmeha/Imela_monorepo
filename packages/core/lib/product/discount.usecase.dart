import 'dart:math';

import 'package:collection/collection.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:injectable/injectable.dart';

@injectable
class DiscountUseCase {
  List<DiscountInfo> _appliedDiscounts = [];

  DiscountUseCase createDynamicPriceDiscount(Product? product) {
    // Middleware logic for dynamic price discount.
    // Example calculation based on dynamic pricing rules.
    _appliedDiscounts.add(DiscountInfo(
      name: "Dynamic Pricing Discount",
      id: "dynamic_001",
      value: 50,
      source: DiscountSource.DYNAMIC_PRICING,
    ));
    return this;
  }

  DiscountUseCase resetAddedDiscount() {
    _appliedDiscounts.clear();
    return this;
  }

  DiscountUseCase createBusinessOfferDiscounts(List<Discount> discounts) {
    final eligableDiscounts = discounts;
    final finalDiscount = eligableDiscounts.map((e) {
      return e.toDiscountInfo(name: 'business offer ${e.value} %', source: DiscountSource.BUSINESS_OFFER);
    }).toList();
    _appliedDiscounts.addAll(finalDiscount);
    return this;
  }

  DiscountUseCase createLoyaltyDiscount(CustomerLoyalty? customerLoyalty, List<Reward> businessRewards) {
    // Middleware logic for loyalty discount based on points and rewards.
    final eligableRewards = businessRewards.getEligibleRewards(customerLoyalty?.currentPoints ?? 0);
    if (eligableRewards.isEmpty) return this;
    var loyaltyDiscounts = eligableRewards.map((reward) {
      return DiscountInfo(
        name: reward.name.localize('ENGLISH'),
        id: Random().nextInt(1000000).toString(),
        type: DiscountType.PERCENTAGE,
        value: reward.discountAmount ?? 0,
        source: DiscountSource.LOYALTY,
      );
    }).toList();
    _appliedDiscounts.addAll(loyaltyDiscounts);
    return this;
  }

  DiscountUseCase createMembershipDiscount(List<CustomerWithMembership> customerMemberships) {
    final activeMemberships = customerMemberships.where((e) => e.subscription?.isSubscriptionActive() ?? false).toList();
    final membershipDiscounts = activeMemberships.map((e) => e.toDiscountInfo()).toList().whereNotNull();
    _appliedDiscounts.addAll(membershipDiscounts);
    return this;
  }

  List<DiscountInfo> build(List<DiscountInfo> appliedDiscounts) {
    return _appliedDiscounts.mapIndexed((index, element) {
      final isApplied = appliedDiscounts.any((e) => e.name == element.name);
      if (isApplied) {
        return _appliedDiscounts[index] = element.copyWith(isApplied: true);
      }
      return element;
    }).toList();
  }
}
