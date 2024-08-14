import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/branch/model/branch.model.dart';
import 'package:melegna_customer/domain/branch/model/inventory.model.dart';

import 'package:melegna_customer/domain/business/model/business.model.dart';
import 'package:melegna_customer/domain/product/model/product_addon.model.dart';
import 'package:melegna_customer/domain/product/model/product_price.model.dart';
import 'package:melegna_customer/domain/shared/gallery.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/domain/shared/price.model.dart';

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
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  String? getLocalizedProductName(String locale) {
    return name?.localize();
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
    final defaultPrice = prices?.firstWhereOrNull((price) => price.isDefault == true);
    return defaultPrice?.price ?? prices?.firstOrNull?.price;
  }

  String? getProductOptionInfo() {
    final productOptionCount = variants?.length ?? variantsId?.length ?? 0;
    if (productOptionCount == 0) {
      return '';
    }
    return '$productOptionCount options';
  }

  String getMinOrderQty() {
    return 'Min Order - $minimumOrderQty';
  }

  String getCallToAction() {
    return callToAction ?? 'Order';
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
