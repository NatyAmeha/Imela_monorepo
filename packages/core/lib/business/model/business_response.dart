import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/product/model/product.model.dart';

part 'business_response.freezed.dart';
part 'business_response.g.dart';

@freezed
class BusinessResponse with _$BusinessResponse {
  const BusinessResponse._();
  const factory BusinessResponse({
    bool? success,
    String? message,
    Business? business,
    List<Business>? businesses,
    List<Branch>? branches,
    List<Branch>? branchAdded,
    List<Branch>? branchUpdated,
    List<Product>? products,
  }) = _BusinessResponse;

  // JSON serialization
  factory BusinessResponse.fromJson(Map<String, dynamic> json) => _$BusinessResponseFromJson(json);

  bool isBusinessDetailFetchSuccessfull() {
    if (success == true && business?.sections?.isNotEmpty == true &&  products?.isNotEmpty == true) {
      return true;
    }
    return false;
  }
}
