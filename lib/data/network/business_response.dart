import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/data/base_response.dart';
import 'package:melegna_customer/domain/branch/model/branch.model.dart';
import 'package:melegna_customer/domain/business/model/business.model.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';

part 'business_response.g.dart';
part 'business_response.freezed.dart';

@freezed
class BusinessResponse with _$BusinessResponse {
  const factory BusinessResponse({
    Business? business,
    List<Business>? businesses,
    List<Branch>? branches,
    List<Branch>? branchAdded,
    List<Branch>? branchUpdated,
    List<Product>? products,
  }) = _BusinessResponse;

  // JSON serialization
  factory BusinessResponse.fromJson(Map<String, dynamic> json) => _$BusinessResponseFromJson(json);
}
