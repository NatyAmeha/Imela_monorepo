import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/branch/model/inventory.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/product/model/product_price.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/price.model.dart';

part 'product.model.freezed.dart';
part 'product.model.g.dart';

@freezed
class Product with _$Product {
  const Product._();
  const factory Product({
    String? id,
    List<LocalizedField>? name,
    List<LocalizedField>? displayName,
    List<LocalizedField>? description,
    bool? featured,
    Gallery? gallery,
    Business? business,
    List<String>? tag,
    @Default(1) int minimumOrderQty,
    int? loyaltyPoint,
    String? businessId,
    List<String>? sectionId,
    bool? isActive,
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

  double get totalPrice {
    final itemPrice = getPrice()?.toSelectedPrice('ETB')?.amount ?? 0.0;
    return itemPrice * (qty ?? 1);
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
    if (isActive ?? false || remainingAmount == null) {
      return false;
    }
    return qty.inRange(DoubleRange(minimumOrderQty.toDouble(), remainingAmount!));
  }

  String getCallToAction() {
    return callToAction ?? 'Order';
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

  OrderItem getOrderItem(double selectedQty, {List<OrderConfig> config = const []}) {
    return OrderItem(
      name: name,
      productId: id,
      image: getImageUrl(),
      subTotal: getPrice()?.firstOrNull?.amount,
      discount: [],
      config: config,
      quantity: selectedQty,
    );
  }

  Product updateQty(double qty) {
    return copyWith(qty: qty);
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
