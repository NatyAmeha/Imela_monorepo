import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_utils/helpers/number_utils.dart';
import 'order_config.model.dart';

part 'order_item.model.freezed.dart';
part 'order_item.model.g.dart';

@freezed
class OrderItem with _$OrderItem {
  const OrderItem._();
  const factory OrderItem({
    String? id,
    List<LocalizedField>? name,
    @Default(0) double quantity,
    String? branchId,
    String? image,
    String? productId,
    double? originalPrice,
    double? subTotal,
    double? total,
    @Default(0) double? point,
    double? tax,
    List<ItemDiscount>? discount,
    List<OrderConfig>? config,
    double? finalPrice,
    Product? product,
    String? calendarId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

  OrderItem updateQuantity(double qty) {
    return copyWith(quantity: qty);
  }

  OrderItem addOrRemoveDiscount(List<ItemDiscount> newDiscounts) {
    var finalDiscounts = List<ItemDiscount>.from(discount ?? []);
    for (var discountInfo in newDiscounts) {
      var existingDiscount = finalDiscounts.firstWhereOrNull((e) => e.id == discountInfo.id);
      if (existingDiscount != null) {
        finalDiscounts.remove(existingDiscount);
      } else {
        finalDiscounts.add(discountInfo);
      }
    }
    return copyWith(discount: finalDiscounts);
  }

  OrderItem addDiscount(List<ItemDiscount> newDiscounts, {bool replaceIfExists = false}) {
    var finalDiscounts = List<ItemDiscount>.from(discount ?? []);

    for (var discountInfo in newDiscounts) {
      if (replaceIfExists) {
        var existingDiscount = discount?.firstWhereOrNull((e) => discountInfo.id == e.id);
        if (existingDiscount != null) {
          finalDiscounts.remove(existingDiscount);
        }
      }
      finalDiscounts.add(discountInfo);
    }
    return copyWith(discount: finalDiscounts);
  }

  OrderItem removeDiscount(List<ItemDiscount> newDiscounts) {
    final discountIds = newDiscounts.map((e) => e.id).toList();
    return copyWith(discount: discount?.where((e) => !discountIds.contains(e.id)).toList());
  }

  OrderItem removeDiscountById(String discountId) {
    return copyWith(discount: discount?.where((e) => e.id != discountId).toList());
  }

  OrderItem resetDiscounts() {
    return copyWith(discount: []);
  }

  double getSubtotal({bool applyQty = true}) {
    var finalSubtotalAmount = (subTotal ?? 0);
    final selectedDynamicPriceDiscount = product?.getDynamicPriceDiscountByQty(quantity);
    if (selectedDynamicPriceDiscount != null) {
      final totalDynamicPriceDiscountAmount = finalSubtotalAmount.getPercentage(selectedDynamicPriceDiscount.value, deductPercentageFromOriginalPrice: false);
      finalSubtotalAmount -= totalDynamicPriceDiscountAmount;
    }
    return (finalSubtotalAmount * (applyQty ? quantity : 1)).getPresision(2);
  }

  String subtotalAmountString(String currency) {
    return '$currency ${getSubtotalPOSUpdated().getPresisionString(precision: 2)}';
  }

  double getTotalDiscountAmount({bool applyQty = false}) {
    var subtotalAmount = getSubtotal(applyQty: false);
    double totalDiscount = 0;
    var finalDiscounts = [...(discount ?? [])];
    if (finalDiscounts.isNotEmpty == true) {
      for (var disc in finalDiscounts) {
        totalDiscount += subtotalAmount.getPercentage(disc.percentage ?? 0, deductPercentageFromOriginalPrice: false);
        subtotalAmount -= totalDiscount;
      }
    }
    return (totalDiscount * (applyQty ? quantity : 1)).getPresision(2);
  }

  String totalAmountString({String? currency}) {
    return '$currency ${getTotalAmountPOS()}';
  }

  double getTotalAmount({bool applyQty = true}) {
    return (getSubtotal(applyQty: applyQty) - getTotalDiscountAmount(applyQty: applyQty)).getPresision(2);
  }

  double getTotalAddonPrices() {
    return (config?.sumBy((e) => e.additionalPrice) ?? 0).getPresision(2);
  }

  String getTotalAddonPricesString({String? currency}) {
    return '$currency ${getTotalAddonPrices().getPresisionString(precision: 2)}';
  }

  double getTotalDiscountAmountPOS({bool applyQty = true}) {
    var subtotalAmount = getSubtotalPOSUpdated(includeAddonPrice: false);
    double totalDiscount = 0;
    if (discount?.isNotEmpty == true) {
      for (var disc in discount!) {
        var discountIteration = subtotalAmount.getPercentage(disc.percentage ?? 0, deductPercentageFromOriginalPrice: false);
        subtotalAmount -= discountIteration;
        totalDiscount += discountIteration;
      }
    }
    return (totalDiscount).getPresision(2);
  }

  String getTotalDiscountAmountPOSString({String? currency}) {
    final totalDiscount = getTotalDiscountAmountPOS();
    if (totalDiscount == 0.0) return '';
    return '- $currency ${totalDiscount.getPresisionString(precision: 2)}';
  }

  double getSubtotalPOSUpdated({bool includeDynamicPricingDiscount = true, bool applyQty = true, bool includeAddonPrice = true}) {
    final totalAmount = (((subTotal ?? 0) * (applyQty ? quantity : 1))).getPresision(2);
    if (includeAddonPrice) {
      return totalAmount + getTotalAddonPrices();
    }
    return totalAmount;
  }

  double getTotalAmountPOS({bool includeDynamicPricingDiscount = true}) {
    final totalAmount = getSubtotalPOSUpdated(includeDynamicPricingDiscount: includeDynamicPricingDiscount, includeAddonPrice: false) - getTotalDiscountAmountPOS();
    final totalAddonPrices = getTotalAddonPrices();
    return (totalAmount + totalAddonPrices).getPresision(2);
  }

  String totalDiscountString(String currency) {
    final discount = getTotalDiscountAmount(applyQty: true);
    if (discount == 0.0) return '';
    return '- $currency ${discount.getPresision(2)}';
  }

  OrderItem applyLoyaltyDiscount(List<Reward> rewards) {
    var initialSubtotal = getTotalAmount();
    List<ItemDiscount> rewardDiscounts = [];
    for (var reward in rewards) {
      if (reward.discountAmount != null) {
        var totalDiscount = 0.0;
        if (reward.discountType == DiscountType.AMOUNT.name) {
        } else {
          totalDiscount = initialSubtotal.getPercentage(reward.discountAmount ?? 0, deductPercentageFromOriginalPrice: false);
          initialSubtotal -= totalDiscount;
          final discount = ItemDiscount(amount: totalDiscount, percentage: reward.discountAmount, name: reward.name, claimedRewardId: [reward.id]);
          rewardDiscounts.add(discount);
        }
      }
    }
    return copyWith(discount: [...(discount ?? []), ...rewardDiscounts]);
  }

  OrderItem removeAppliedRewardDiscounts(List<String> rewardIds) {
    var nonRewardDiscounts = discount?.where((disc) => !rewardIds.containsAny(disc.claimedRewardId ?? [])).toList();
    return copyWith(discount: nonRewardDiscounts ?? []);
  }
}

@freezed
class ItemDiscount with _$ItemDiscount {
  const ItemDiscount._();

  const factory ItemDiscount({
    String? id,
    List<LocalizedField>? name,
    @Default(0) double amount,
    double? percentage,
    List<String>? claimedRewardId,
    DiscountSource? source,
  }) = _ItemDiscount;

  factory ItemDiscount.fromJson(Map<String, dynamic> json) => _$ItemDiscountFromJson(json);

  double getDiscountAmount({double? subTotal}) {
    return (subTotal?.getPercentage(percentage ?? 0, deductPercentageFromOriginalPrice: false) ?? 0);
  }

  String getDiscountAmountString({double? subTotal, String? currency}) {
    final discountAmount = getDiscountAmount(subTotal: subTotal);
    if (discountAmount == 0.0) return '';
    return '- $currency ${discountAmount.getPresision(2)}';
  }
}
