
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/product/model/pricelist.model.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/domain/shared/price.model.dart';

part 'product_price.model.freezed.dart';
part 'product_price.model.g.dart';

@freezed
class ProductPrice  with _$ProductPrice {
  const ProductPrice._();
  const factory ProductPrice({
    String? id,
    String? productId,
    String? branchId,
    String? priceListId,
    List<Price>? price,
    
    String? createdAt,
    String? updatedAt,
    bool? isActive,
    bool? isDefault,
    Product? product,

    PriceList? priceList,
  }) = _ProductPrice;

  factory ProductPrice.fromJson(Map<String, dynamic> json) => _$ProductPriceFromJson(json);
}