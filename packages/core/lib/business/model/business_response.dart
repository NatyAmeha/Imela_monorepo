import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/business/model/business.section.dart';
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
    List<ProductBundle>? bundles,
    List<BusinessSection>? sections,
  }) = _BusinessResponse;

  // JSON serialization
  factory BusinessResponse.fromJson(Map<String, dynamic> json) => _$BusinessResponseFromJson(json);

  bool isBusinessDetailFetchSuccessfull() {
    if (success == true && business?.sections?.isNotEmpty == true) {
      return true;
    }
    return false;
  }

  bool isBusinessSectionDetailsFetchSuccessfull() {
    if (success == true && sections?.isNotEmpty == true) {
      return true;
    }
    return false;
  }

  bool isBusinessListFetchSuccessfull() {
    if (success == true) {
      return true;
    }
    return false;
  }
}

extension BusinessResponseX on BusinessResponse? {
  bool get isBusinessFetchForPOSSuccessfull {
    if (this == null) {
      return false;
    }
    if (this!.success == true && this!.business != null) {
      return true;
    }
    return false;
  }
}
