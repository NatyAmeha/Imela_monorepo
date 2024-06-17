import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/branch/branch.model.dart';
import 'package:melegna_customer/domain/branch/inventory.model.dart';
import 'package:melegna_customer/domain/business/model/business.model.dart';
import 'package:melegna_customer/domain/shared/gallery.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';

part '../product.model.freezed.dart';
part '../product.model.g.dart';

@freezed
class Product with _$Product {
  const Product._();
  const factory Product({
    String? id,
    List<LocalizedField>? name,
    List<LocalizedField>? displayName,
    List<LocalizedField>? description,
    Gallery? gallery,
    Business? business,
    List<String>? tag,
    int? minimumOrderQty,
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
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  String? getLocalizedProductName(String locale) {
    return name?.getLocalizedValue(locale);
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

enum CallToAction{
  Order, Call, Book, Reserve
}

