import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/product/model/pricelist.model.dart';
import 'package:imela_core/product/model/product.model.dart';

part 'branch.response.freezed.dart';
part 'branch.response.g.dart';

@freezed
class BranchResponse with _$BranchResponse {
  const BranchResponse._();
  const factory BranchResponse({
    bool? success,
    String? message,
    Branch? branch,
    List<Product>? products,
    Business? business,
    List<PriceList>? priceLists,
    List<ProductBundle>? bundles,
    List<Branch>? branches,
  }) = _BranchResponse;

  factory BranchResponse.fromJson(Map<String, dynamic> json) => _$BranchResponseFromJson(json);
}