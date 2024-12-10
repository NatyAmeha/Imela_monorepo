import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/number_utils.dart';
import 'order_item.model.dart';
part 'cart.model.freezed.dart';
part 'cart.model.g.dart';

@freezed
class Cart with _$Cart {
  const Cart._();
  const factory Cart({
    String? id,
    List<LocalizedField>? name,
    List<String>? businessIds,
    String? userId,
    @Default(false) bool isBundleCart,
    List<OrderItem>? items,
    List<OrderConfig>? configs,
    List<ProductAddon>? orderAddons,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PaymentOption>? paymentOptions,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

  String getTotalItems() {
    return '${items?.length ?? 0} items';
  }

  List<ProductAddon> getAddons({bool getDefault = false, bool forPOS = false}) {
    var result = List<ProductAddon>.from(orderAddons ?? []);
    if (forPOS) {
      result = orderAddons?.where((e) => e.includeOnPOS == true).toList() ?? [];
    }
    if (getDefault) {
      result = orderAddons?.where((e) => e.inputType == 'NONE').toList() ?? [];
      return result;
    }

    result = result.where((e) => e.inputType != 'NONE').toList();
    return result;
  }

  double get getSubtotal {
    final itemSubtotal = items?.sumBy((element) => element.subTotal ?? 0) ?? 0;
    final addonSubtotal = configs?.sumBy((element) => element.additionalPrice) ?? 0;
    return (itemSubtotal + addonSubtotal).getPresision(2);
  }

  String getSubtotalFormatted(String selectedCurrency) {
    return '$selectedCurrency $getSubtotal';
  }

  String totalEarnedPointString(String selectedLanguage) {
    final totalPoints = (items?.sumBy((element) => element.point ?? 0) ?? 0).getPresision(2);
    if (selectedLanguage == AppLanguage.AMHARIC.name) {
      return '$totalPoints ነጥብ ያገኛሉ';
    }
    return 'You will earn $totalPoints points';
  }

  List<ItemDiscount> getAllItemDiscounts(List<OrderItem>? selectedItems, {List<String> rewardsId = const []}) {
    final allDisicounts = selectedItems?.map((item) => item.discount ?? []).flatten().toList() ?? [];
    if (rewardsId.isNotEmpty) {
      allDisicounts.where((disc) => rewardsId.containsAny(disc.claimedRewardId ?? []));
    }
    return allDisicounts;
  }

  Cart applyLoyaltyDiscountOnCartItems(List<Reward> rewards) {
    final updatedItemsWithLoyaltyDiscount = items?.map((item) => item.applyLoyaltyDiscount(rewards)).toList();
    // final rewardsId =  rewards.map((reward) => reward.id).toList();
    // final appliedLoyaltyDiscounts = getAllItemDiscounts(updatedItemsWithLoyaltyDiscount, rewardsId: rewardsId);
    // final totalDiscount = appliedLoyaltyDiscounts.sumBy((disc) => disc.amount ?? 0);

    final updatedCart = copyWith(items: updatedItemsWithLoyaltyDiscount);
    return updatedCart;
  }

  Cart removeAppliedLoyaltyDiscounts(List<String> rewardIds) {
    final updatedItems = items?.map((item) => item.removeAppliedRewardDiscounts(rewardIds)).toList();
    final updatedCart = copyWith(items: updatedItems);
    return updatedCart;
  }

  double get getTotalDiscountAmount {
    final dicountInfo = (items ?? []).map((element) => element.getTotalDiscountAmount()).toList();
    return (dicountInfo.sumBy((element) => element)).getPresision(2);
  }

  double get getTotalPrice {
    return (items?.sumBy((element) => element.getTotalAmount()) ?? 0).getPresision(2);
  }

  double getSubtotalPOSUpdated({bool includeDynamicPricingDiscount = true}) {
    var subtotal = items?.sumBy((element) => element.getSubtotalPOSUpdated(includeDynamicPricingDiscount: includeDynamicPricingDiscount)) ?? 0;
    var orderAddonsTotalAmount = configs?.sumBy((element) => element.additionalPrice) ?? 0;
    return (subtotal + orderAddonsTotalAmount).getPresision(2);
  }

  double getTotalDiscountAmountPOS() {
    final dicountInfo = items?.sumBy((element) => element.getTotalDiscountAmountPOS()) ?? 0;
    return (dicountInfo).getPresision(2);
  }

  double getTotatAmountPOS() {
    final itemsTotalAmount = getSubtotalPOSUpdated();
    final discounts = getTotalDiscountAmountPOS();
    return (itemsTotalAmount - discounts).getPresision(2);
  }

  String getSubtotalPOSUpdatedFormatted(String selectedCurrency) {
    return '$selectedCurrency ${getSubtotalPOSUpdated()}';
  }

  String getTotalDiscountAmountPOSFormatted(String selectedCurrency) {
    return '$selectedCurrency ${getTotalDiscountAmountPOS()}';
  }

  String getTotalAmountPOSFormatted(String selectedCurrency) {
    return '$selectedCurrency ${getTotatAmountPOS()}';
  }

  String getFormattedTotalPrice(BuildContext context) {
    return 'ETB ${getTotalPrice.toStringAsFixed(2)}';
  }

  Cart addPaymentOption(List<PaymentOption> paymentOptions) {
    return copyWith(paymentOptions: paymentOptions);
  }

  Cart addOrderAddons(List<ProductAddon> orderAddons) {
    if (orderAddons.isEmpty) return this;
    return copyWith(orderAddons: orderAddons);
  }

  Cart addOrUpdateItems(List<OrderItem> nItems, {bool increaseQty = true, List<Discount> dynamicPriceDiscounts = const []}) {
    final existingItems = items ?? [];
    final existedItemsId = existingItems.map((item) => item.productId).toList();
    final finalItems = <OrderItem>[];
    if (existingItems.isEmpty) {
      finalItems.addAll(nItems);
    } else {
      final newItems = nItems.where((nItem) => !existedItemsId.contains(nItem.productId)).toList();
      finalItems.addAll(newItems);
      final updatedItems = existingItems.map((item) {
        final existedItem = nItems.firstWhereOrNull((newItem) => newItem.productId == item.productId);
        if (existedItem != null) {
          return existedItem.copyWith(quantity: increaseQty ? item.quantity + existedItem.quantity : existedItem.quantity);
        }
        return item;
      }).toList();
      finalItems.addAll(updatedItems);
    }

    return copyWith(items: [...finalItems]);
  }

  Cart updateOrderItem(OrderItem item) {
    final index = items?.indexWhere((element) => element.productId == item.productId) ?? -1;
    if (index != -1) {
      return copyWith(items: items?.map((e) => e.productId == item.productId ? item : e).toList());
    }
    return this;
  }

  Cart addBusiness(List<String> businessIds) {
    return copyWith(businessIds: businessIds);
  }

  Cart removeItems(List<String> productIds) {
    return copyWith(items: items?.where((element) => !productIds.contains(element.productId)).toList());
  }

  bool hasOrderAddons() {
    return orderAddons?.isNotEmpty ?? false;
  }

  List<String> getMembershipProductIds() {
    return items?.map((item) => item.product?.membershipIds ?? []).flatten().toList() ?? [];
  }

  bool cartContainsMembershipProduct() {
    return items?.any((item) => item.product?.isMembershipProduct ?? false) ?? false;
  }

  Cart addSelectedOrderConfigs(List<OrderConfig> configs) {
    if (configs.isEmpty) return this;
    return copyWith(configs: configs);
  }

  Cart applyDiscountOnOrderItems(List<ItemDiscount> discountList, {bool removeExistingDiscount = false}) {
    final updatedItems = items?.map((item) {
      var updatedItem = item;
      for (var discountInfo in discountList) {
        if (discountInfo.source == DiscountSource.BUSINESS_OFFER) {
          if (removeExistingDiscount) {
            updatedItem = updatedItem.removeDiscount([discountInfo]);
          } else {
            updatedItem = updatedItem.addDiscount([discountInfo]);
          }
        } else if (discountInfo.source == DiscountSource.MEMBERSHIP) {
          if (!(item.product?.isMembershipProduct ?? false)) continue;
          if (removeExistingDiscount) {
            updatedItem = updatedItem.removeDiscount([discountInfo]);
          } else {
            updatedItem = updatedItem.addDiscount([discountInfo]);
          }
        }
      }
      return updatedItem;
    }).toList();

    return copyWith(items: updatedItems);
  }

  Cart resetAllDiscounts() {
    return copyWith(items: items?.map((item) => item.resetDiscounts()).toList());
  }
}
