import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/product/model/product_price.model.dart';
import 'package:imela_core/product/model/pricelist.model.dart';

part 'product_price.response.freezed.dart';
part 'product_price.response.g.dart';

@freezed
class ProductPriceResponse with _$ProductPriceResponse {
  const ProductPriceResponse._();
  const factory ProductPriceResponse({
    bool? success,
    String? message,
    List<ProductPrice>? productPrices,
    List<PriceList>? priceLists,
    ProductPrice? productPrice,
  }) = _ProductPriceResponse;

  factory ProductPriceResponse.fromJson(Map<String, dynamic> json) => _$ProductPriceResponseFromJson(json);

  bool isPriceListsSuccessful() {
    return success == true && priceLists != null;
  }

  bool isProductPricesSuccessful() {
    return success == true;
  }

  bool isProductPriceUpdateSuccessful() {
    return success == true && productPrice != null;
  }
} 