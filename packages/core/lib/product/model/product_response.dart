import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/branch/model/inventory.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/product/model/product.model.dart';

part 'product_response.freezed.dart';
part 'product_response.g.dart';

@freezed
class ProductResponse with _$ProductResponse {
  const ProductResponse._();
  const factory ProductResponse({
    bool? success,
    String? message,
    Product? product,
    List<Inventory>? inventories,
    List<Product>? variants,
    List<Product>? products,
    List<Branch>? branches,
    Business? business,
  }) = _ProductResponse;

  factory ProductResponse.fromJson(Map<String, dynamic> json) => _$ProductResponseFromJson(json);

  bool get isSuccessfull {
    if (success == false || product == null) {
      return false;
    }
    return true;
  }
}
