import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_utils/helpers/localization_utils.dart';

part 'product_bundle.model.freezed.dart';
part 'product_bundle.model.g.dart';

@freezed
class BundleProductInfo with _$BundleProductInfo {
  const BundleProductInfo._();
  const factory BundleProductInfo({
    required String productId,
    required double minQty,
    required double maxQty,
    Product? product,
  }) = _BundleProductInfo;

  factory BundleProductInfo.fromJson(Map<String, dynamic> json) => _$BundleProductInfoFromJson(json);
}

@freezed
class ProductBundle with _$ProductBundle {
  const ProductBundle._();
  const factory ProductBundle({
    String? id,
    List<LocalizedField>? name,
    List<LocalizedField>? description,
    String? type,
    List<String>? productIds,
    List<BundleProductInfo>? productsInfo,
    List<String>? branchIds,
    String? businessId,
    DateTime? startDate,
    DateTime? endDate,
    Gallery? gallery,
    Discount? discount,
    List<Product>? products,
    List<String>? businessIds,
    List<Business>? businesses,
    List<Branch>? branches,
    List<ProductAddon>? addons,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProductBundle;

  factory ProductBundle.fromJson(Map<String, dynamic> json) => _$ProductBundleFromJson(json);

  String getBundleName(String selectedLanguage) {
    return name.localize(selectedLanguage);
  }

  String getBundleProducts() {
    return '${productIds?.length} items';
  }

  String getBundleConditionValue(String selectedLanguage) {
    if (discount?.condition == DiscountCondition.MINIMUM_PURCHASE.name) {
      return LocalizationUtils.returnLocalizedString(
        selectedLanguage,
        englishString: 'You should purchase at least ${discount?.conditionValue} items to get the discount',
        amharicString: ' Amharic version',
      );
    } else if (discount?.condition == DiscountCondition.PURCHASE_ALL_ITEMS.name) {
      return LocalizationUtils.returnLocalizedString(
        selectedLanguage,
        englishString: 'You should purchase all items to get the discount',
        amharicString: 'Amhraic version',
      );
    } else if (discount?.condition == DiscountCondition.QUANTITY.name) {
      return LocalizationUtils.returnLocalizedString(
        selectedLanguage,
        englishString: 'You should purchase at least ${discount?.conditionValue} quantity from each item to get the discount',
        amharicString: 'Amhraic version',
      );
    }
    return discount?.conditionValue.toString() ?? '';
  }

  Cart getCartInfo(
    List<Product> products,
    Map<String, List<OrderConfig>> productOrderConfigs,
  ) {
    final items = products.map((product) {
      final itemConfigs = productOrderConfigs[product.id!] ?? [];
      final originalProductPrice = product.getTotalPriceUpdated('ETB', qtyInput: 1);
      final bundleDiscounts = discount != null ? [discount!] : <Discount>[];
      final updatedDiscountWithName = bundleDiscounts.map((discount) => discount.addName(name!)).toList();
      final item = product.getOrderItem(product.qty ?? 1, originalPrice: originalProductPrice, discounts: updatedDiscountWithName, config: itemConfigs);
      return item;
    }).toList();
    final paymentOptions = businesses?.first.paymentOptions;
    return Cart(id: id!, name: name!, items: items, paymentOptions: paymentOptions, businessIds: businessIds, isBundleCart: true);
  }

  List<String?> getBundleProductImages() {
    return products!.map((e) => e.gallery!.getImage()).toList();
  }

  List<PaymentOption> bundlePaymentOptions() {
    if (businesses!.length == 1) {
      return businesses!.first.paymentOptions ?? [PaymentOption.defaultPaymentOption()];
    }
    return [PaymentOption.defaultPaymentOption()];
  }
}
