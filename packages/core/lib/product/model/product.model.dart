import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/branch/model/inventory.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/product/model/product_price.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_utils/helpers/number_utils.dart';

part 'product.model.freezed.dart';
part 'product.model.g.dart';

enum ProductType { PRODUCT, SERVICE, GIFT_CARD, MEMBERSHIP }

@freezed
class Product with _$Product {
  const Product._();
  const factory Product({
    String? id,
    List<LocalizedField>? name,
    List<LocalizedField>? displayName,
    List<LocalizedField>? description,
    @Default(false) bool featured,
    Gallery? gallery,
    Business? business,
    List<String>? tag,
    @Default(1) int minimumOrderQty,
    int? loyaltyPoint,
    String? businessId,
    List<String>? sectionId,
    @Default(true) bool isActive,
    List<String>? category,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? canOrderOnline,
    List<String>? reviewTopics,
    String? sku,
    List<ProductOption>? options,
    List<String>? optionsIncluded,
    List<String>? variantsId,
    List<Product>? variants,
    bool? mainProduct,
    List<Inventory>? inventory,
    String? callToAction,
    List<String>? branchIds,
    String? deliveryInfoId,
    List<Branch>? branches,
    List<ProductAddon>? addons,
    int? totalViews,
    List<ProductPrice>? prices,
    List<Discount>? discounts,
    double? qty,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  String? getLocalizedProductName(String locale) {
    return name?.localize(locale);
  }

  String getImageUrl() {
    return gallery?.getImages().firstOrNull ?? '';
  }

  List<Price>? getPrice() {
    if (prices == null || prices!.isEmpty) {
      return null;
    }
    if (prices?.length == 1) {
      return prices?.firstOrNull?.price;
    }
    final defaultPrice = prices?.firstOrNullWhere((price) => price.isDefault == true);
    return defaultPrice?.price ?? prices?.firstOrNull?.price;
  }

  String getPriceRangeString(String currency, {List<Discount> discounts = const [], bool showWithoutDiscount = false}) {
    // 1. select default price from product price response
    // 2. if there is a dynamic pricing discount, apply the discount to the default price
    // 3. apply any other discounts passed as argument
    var basePrice = getPrice().toSelectedPrice(currency);
    var basePriceWithDynamicPricingDiscount = basePrice;
    Price? discountedPrice;
    if (basePrice == null) {
      return 'Price not available';
    }
    if (dynamicPricingDiscounts.isNotEmpty) {
      final maxDynamicPriceDiscountPercentage = dynamicPricingDiscounts.map((e) => e.value).max() ?? 0;
      basePriceWithDynamicPricingDiscount = basePrice.copyWith(amount: basePrice.amount.getPercentage(maxDynamicPriceDiscountPercentage));
    }

    if (showWithoutDiscount || discounts.isEmpty) {
      if (haveDynamicPricing) {
        return '${basePriceWithDynamicPricingDiscount!.currency} ${basePriceWithDynamicPricingDiscount.amount.getPresision(2)} - ${basePrice.currency} ${basePrice.amount.getPresision(2)}';
      }
      return '${basePrice.currency} ${basePrice.amount.getPresision(2)}';
    } else {
      final maxDiscountPercentage = discounts.map((e) => e.value).max() ?? 0;
      discountedPrice = basePriceWithDynamicPricingDiscount?.copyWith(amount: basePriceWithDynamicPricingDiscount.amount.getPercentage(maxDiscountPercentage));
      if (haveDynamicPricing) {
        return '${discountedPrice!.currency} ${discountedPrice.amount.getPresision(2)} - ${basePrice!.currency} ${basePrice!.amount.getPresision(2)}';
      }
      return '${discountedPrice!.currency} ${discountedPrice.amount.getPresision(2)}';
    }
  }

  double getTotalPriceUpdated(String currency, {double? qtyInput, List<Discount> discounts = const []}) {
    var basePrice = getPrice().toSelectedPrice(currency);
    if (basePrice == null) {
      return -1;
    }
    if (discounts.isEmpty) {
      return basePrice.amount * (qtyInput ?? qty ?? 1);
    }
    final maxDiscountPercentage = discounts.map((e) => e.value).max() ?? 0;
    final discountedPrice = basePrice.copyWith(amount: basePrice.amount.getPercentage(maxDiscountPercentage));
    return (discountedPrice.amount * (qtyInput ?? qty ?? 1)).getPresision(2);
  }

  double calculateaAppliedDiscount(String currency, {double? qty, List<Discount> discounts = const []}) {
    var productPrice = getTotalPriceUpdated(currency, qtyInput: qty);
    var totalDiscountAmount = 0.0;
    for (var discount in discounts) {
      var discountAmount = discount.getDiscountedSubtotal(productPrice);
      productPrice -= discountAmount;
      totalDiscountAmount += discountAmount;
    }
    return totalDiscountAmount.getPresision(2);
  }

  String getTotalPriceUpdatedString(String currency, {double? qty, List<Discount> discounts = const []}) {
    return '${getTotalPriceUpdated(currency, qtyInput: qty, discounts: discounts)} $currency';
  }

  double get totalPrice {
    final itemPrice = getPrice()?.toSelectedPrice('ETB')?.amount ?? 0.0;
    return itemPrice * (qty ?? 1);
  }

  String activeString() {
    return isActive ? 'Active' : 'Inactive';
  }

  String? getProductOptionInfo() {
    final productOptionCount = variants?.length ?? variantsId?.length ?? 0;
    if (productOptionCount == 0) {
      return '';
    }
    return '$productOptionCount options';
  }

  double? get remainingAmount {
    final selectedInventory = inventory?.firstOrNull;
    if (selectedInventory?.qty != null) {
      return selectedInventory!.qty;
    }
    return null;
  }

  bool canOrderWithQty(double qty) {
    if (!isActive || remainingAmount == null) {
      return false;
    }
    return qty.inRange(DoubleRange(minimumOrderQty.toDouble(), remainingAmount!));
  }

  String getCallToAction() {
    return callToAction ?? 'Order';
  }

  List<Discount> get dynamicPricingDiscounts {
    return discounts?.where((discount) => discount.condition == DiscountCondition.QUANTITY.name).sortedBy((e) => e.conditionValue ?? 0.0).toList() ?? [];
  }

  bool get haveDynamicPricing {
    final qtyBasedDiscount = discounts?.firstOrNullWhere((discount) => discount.condition == DiscountCondition.QUANTITY.name);
    return qtyBasedDiscount != null;
  }

  List<OrderConfig> getDefaultAddonValue() {
    final orderConfig = <OrderConfig>[];
    addons?.forEach((addon) {
      if (addon.isSingleSelectionInput) {
        orderConfig.add(OrderConfig.createSingleSelectOrderConfig(addon.name!, addon.options.first.id!, addon));
      } else if (addon.isMultiSelectionInput) {
        orderConfig.add(OrderConfig.createMultipleSelectOrderConfig(addon.name!, addon.options.map((e) => e.id!).toList(), addon));
      }
      if (addon.isNumberInput) {
        orderConfig.add(OrderConfig.createNumberInputOrderConfig(addon.name!, addon.minAmount, addon));
      }
    });
    return orderConfig;
  }

  OrderItem getOrderItem(double selectedQty, {double originalPrice = 0, String selectedCurrency = 'ETB', List<OrderConfig> config = const [], List<Discount> discounts = const []}) {
    final totalPrice = getTotalPriceUpdated(selectedCurrency, qtyInput: selectedQty, discounts: discounts);
    return OrderItem(
      name: name,
      productId: id,
      image: getImageUrl(),
      subTotal: originalPrice * selectedQty,
      total: totalPrice,
      discount: discounts.map((e) => ItemDiscount(id: e.id, name: [], amount: e.getTotalDiscount(originalPrice, selectedQty: selectedQty))).toList(),
      config: config,
      quantity: selectedQty,
    );
  }

  Product updateQty(double qty) {
    return copyWith(qty: qty);
  }

  bool hasAddons() {
    return addons?.isNotEmpty ?? false;
  }
}

@freezed
class ProductOption with _$ProductOption {
  const factory ProductOption({
    String? key,
    List<String>? value,
  }) = _ProductOption;

  factory ProductOption.fromJson(Map<String, dynamic> json) => _$ProductOptionFromJson(json);
}

enum CallToAction { Order, Call, Book, Reserve }
