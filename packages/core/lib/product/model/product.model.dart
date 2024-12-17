import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/branch/model/inventory.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/order/model/cart.model.dart';
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
    List<Calendar>? calendars,
    List<String>? tag,
    @Default(1) int minimumOrderQty,
    @Default(0) int loyaltyPoint,
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
    List<String>? membershipIds,
    double? qty,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  String? getLocalizedProductName(String locale) {
    return name?.localize(locale);
  }

  String getImageUrl() {
    return gallery?.getImages().firstOrNull ?? '';
  }

  String getDefaultUOM() {
    return inventory?.firstOrNull?.unit ?? 'Unit';
  }

  String getProductCategoryString() {
    return category?.join(', ') ?? '';
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

  Price? getMinVariantPrice(String currency) {
    if (variants?.isNotEmpty == true) {
      return variants!.map((e) => e.getPrice()?.toSelectedPrice(currency)).minBy((e) => e?.amount ?? 0.0);
    }
    return null;
  }

  Price? getMaxVariantPrice(String currency) {
    if (variants?.isNotEmpty == true) {
      return variants!.map((e) => e.getPrice()?.toSelectedPrice(currency)).toList().maxBy((e) => e?.amount ?? 0.0);
    }
    return null;
  }

  String getTotalDiscountPercentageApplied(String currency, {List<Discount> discounts = const []}) {
    var basePrice = getTotalPriceUpdated(currency, qtyInput: qty);
    final totalDiscount = calculateaAppliedDiscount(currency, discounts: discounts);
    final discountPercentage = ((totalDiscount / (basePrice)) * 100).getPresision(0, roundUp: false);
    return '$discountPercentage% off';
  }

  String getPriceRangeString(String currency, {List<Discount> discounts = const [], bool showWithoutDiscount = false}) {
    // 1. select default price from product price response
    // 2. if there is a dynamic pricing discount, apply the discount to the default price
    // 3. if there is a variant products, show the price range of the variant products
    // 4. apply any other discounts passed as argument
    var basePrice = getPrice().toSelectedPrice(currency);
    var finalPrice = basePrice;
    if (basePrice == null) {
      return 'Not available';
    }

    // if (sortedDynamicPricingDiscounts.isNotEmpty) {
    //   final maxDynamicPriceDiscountPercentage = sortedDynamicPricingDiscounts.map((e) => e.value).max() ?? 0;
    //   basePriceWithDynamicPricingDiscount = basePrice.copyWith(amount: basePrice.amount.getPercentage(maxDynamicPriceDiscountPercentage));
    // }

    if (hasVariants()) {
      basePrice = getMinVariantPrice(currency);
      finalPrice = getMaxVariantPrice(currency);
    }

    if (!showWithoutDiscount && discounts.isNotEmpty) {
      basePrice = basePrice?.copyWith(amount: basePrice.amount.getPercentageOff(discounts.map((e) => e.value).toList()));
      finalPrice = finalPrice?.copyWith(amount: finalPrice.amount.getPercentageOff(discounts.map((e) => e.value).toList()));
    }
    if (basePrice?.amount == finalPrice?.amount) {
      return '${basePrice?.currency} ${basePrice?.amount.getPresisionString()}';
    }
    return '${basePrice?.currency} ${basePrice?.amount.getPresisionString()} - ${finalPrice?.currency} ${finalPrice?.amount.getPresisionString()}';
  }

  double getTotalPriceUpdated(String currency, {double? qtyInput, List<Discount> discounts = const [], double additionalPrice = 0, bool round = true}) {
    var basePrice = getPrice().toSelectedPrice(currency);
    if (basePrice == null) {
      return -1;
    }
    if (discounts.isNotEmpty) {
      for (var discount in discounts) {
        basePrice = basePrice!.copyWith(amount: basePrice.amount.getPercentage(discount.value));
      }
    }
    final finalPrice =  ((basePrice!.amount + additionalPrice).getPresision(2) * (qtyInput ?? qty ?? 1));
    if(round){
      return finalPrice.getPresision(2);
    }
    return finalPrice;
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

  String getTotalPriceUpdatedString(String currency, {double? qty, List<Discount> discounts = const [], double additionalPrice = 0, bool round = true}) {
    var finalTotalPrice = getTotalPriceUpdated(currency, qtyInput: qty, discounts: discounts, additionalPrice: additionalPrice, round: round);
    return '$currency ${finalTotalPrice.getPresisionString()}';
  }

  double get totalPrice {
    final itemPrice = getPrice()?.toSelectedPrice('ETB')?.amount ?? 0.0;
    return itemPrice * (qty ?? 1);
  }

  String activeString() {
    return isActive ? 'Active' : 'Inactive';
  }

  String getLoyaltyPointString(String selectedLanguage) {
    return '$loyaltyPoint points';
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

  List<ProductAddon> getAddons({bool getDefault = false, bool forPOS = false}) {
    // return addons;
    var result = List<ProductAddon>.from(addons ?? []);
    if (forPOS) {
      result = result.where((e) => e.includeOnPOS == true).toList();
    }
    if (getDefault) {
      result = result.where((e) => e.inputType == 'NONE').toList();
      return result;
    }

    result = result.where((e) => e.inputType != 'NONE').toList();
    return result;
  }

  List<String> getBadgeInfos({bool forPOS = false}) {
    print('product membership ${membershipIds}');
    final badgeInfos = <String>[];
    if (isMembershipProduct) {
      badgeInfos.add('For members');
    }
    return badgeInfos;
  }

  bool canOrderWithQty(double qty, {double? minQty, double? maxQty}) {
    if (!isActive) {
      return false;
    }
    return qty.inRange(DoubleRange((minQty ?? minimumOrderQty.toDouble()), (((maxQty ?? (remainingAmount ?? 10)) - 1).toDouble())));
  }

  String getCallToAction() {
    return callToAction ?? 'Order';
  }

  List<Discount> getAddonDiscounts({required String addonId, required String selectedLanguage, required Product parentProduct}) {
    var result = discounts?.where((disc) => disc.condition == DiscountCondition.PRODUCT_ADDON.name && disc.conditionValue == addonId).toList() ?? [];
    if (result.isNotEmpty) {
      result = result.map((e) => e.copyWith(name: [LocalizedField(value: 'Bundle deal from ${parentProduct.getLocalizedProductName(selectedLanguage)}', key: selectedLanguage)], value: 18)).toList();
    }
    return result;
  }

  List<Discount> get sortedDynamicPricingDiscounts {
    final qtyBasedDiscounts = discounts?.where((discount) => discount.condition == DiscountCondition.QUANTITY.name).sortedBy((e) => e.conditionValue ?? 0.0).toList() ?? [];
    return qtyBasedDiscounts.sortedBy((e) => e.value).toList();
  }

  bool get haveDynamicPricing {
    final qtyBasedDiscount = discounts?.firstOrNullWhere((discount) => discount.condition == DiscountCondition.QUANTITY.name);
    return qtyBasedDiscount != null;
  }

  List<Price> getDynamicPriceList(String currency, {List<Discount> additionalDiscounts = const []}) {
    final priceList = <Price>[];
    var basePrice = getTotalPriceUpdated(currency, qtyInput: 1, discounts: [...additionalDiscounts]);
    for (var discountItem in sortedDynamicPricingDiscounts) {
      final amount = basePrice.getPercentage(discountItem.value);
      priceList.add(Price(amount: amount.getPresision(2), currency: currency));
    }
    priceList.insert(0, Price(amount: basePrice.getPresision(2), currency: currency));
    return priceList;
  }

  Price selectedDynamicPrice(String currency, {required double qty, List<Discount> additionalDiscounts = const []}) {
    var basePrice = getTotalPriceUpdated(currency, qtyInput: 1, discounts: [...additionalDiscounts]);
    final selectedDynamicPriceDiscount = getDynamicPriceDiscountByQty(qty);
    if (selectedDynamicPriceDiscount != null) {
      final amount = basePrice.getPercentage(selectedDynamicPriceDiscount.value);
      return Price(amount: amount.getPresision(2), currency: currency);
    }
    return Price(amount: basePrice.getPresision(2), currency: currency);
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

  Cart getCartInfo({double qty = 1, required Business businessInfo, List<OrderConfig> productOrderConfigs = const [], List<Discount> discounts = const [], List<ProductAddon> addons = const [], double productPoint = 0}) {
    final originalProductPrice = getTotalPriceUpdated('ETB', qtyInput: 1);
    final item = getOrderItem(qty, originalPrice: originalProductPrice, discounts: discounts, config: productOrderConfigs, addons: addons, productPoint: productPoint);
    return Cart(id: businessInfo.id, name: businessInfo.name, items: [item], paymentOptions: businessInfo.paymentOptions, businessIds: [businessInfo.id!]);
  }

  OrderItem getOrderItem(
    double selectedQty, {
    double originalPrice = 0,
    String selectedCurrency = 'ETB',
    List<OrderConfig> config = const [],
    List<Discount> discounts = const [],
    List<ProductAddon> addons = const [],
    double minQty = 1,
    double maxQty = 10,
    double? productPoint,
    List<LocalizedField>? defaultDiscountName,
  }) {
    final subtotalPrice = getTotalPriceUpdated(selectedCurrency, qtyInput: 1);
    final totalPrice = getTotalPriceUpdated(selectedCurrency, qtyInput: 1);
    print('subtotalPrice $subtotalPrice');
    return OrderItem(
      name: name,
      product: copyWith(addons: addons),
      productId: id,
      image: getImageUrl(),
      originalPrice: originalPrice,
      subTotal: subtotalPrice.getPresision(2),
      total: totalPrice.getPresision(2),
      point: (productPoint ?? loyaltyPoint.toDouble()) * selectedQty,
      discount: discounts.map((e) => e.toItemDiscount(defaultName: defaultDiscountName)).toList(),
      config: config,
      quantity: selectedQty,
      minQty: minQty,
      maxQty: maxQty,
    );
  }

  Discount? getDynamicPriceDiscountByQty(double qty) {
    if (!haveDynamicPricing) {
      return null;
    }
    final selectedDiscount = sortedDynamicPricingDiscounts.lastOrNullWhere((element) {
      return ((double.tryParse(element.conditionValue ?? '0') ?? 0) <= qty);
    });
    final updatedDiscountInfo = selectedDiscount?.copyWith(id: DiscountSource.DYNAMIC_PRICING.name, name: [LocalizedField(key: 'ENGLISH', value: 'Discount for bulk order (${selectedDiscount.conditionValue})')], source: DiscountSource.DYNAMIC_PRICING);
    return updatedDiscountInfo;
  }

  Product updateQty(double qty) {
    return copyWith(qty: qty);
  }

  bool hasAddons() {
    return addons?.isNotEmpty ?? false;
  }

  bool get isMembershipProduct => membershipIds?.isNotEmpty ?? false;

  bool hasVariants() {
    return (variants?.isNotEmpty ?? false) || (variantsId?.isNotEmpty ?? false);
  }

  List<Discount> getBusinessDiscounts() {
    return business?.discounts ?? [];
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
