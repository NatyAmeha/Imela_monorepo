
import 'package:freezed_annotation/freezed_annotation.dart';
import 'pricelist.model.dart';
import 'product.model.dart';
import '../../shared/price.model.dart';

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