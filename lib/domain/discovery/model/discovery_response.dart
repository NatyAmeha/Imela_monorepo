import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/discovery/model/bundle_discovery.model.dart';
import 'package:melegna_customer/domain/discovery/model/business_discovery.model.dart';
import 'package:melegna_customer/domain/discovery/model/product_discovery.model.dart';

part 'discovery_response.freezed.dart';
part 'discovery_response.g.dart';

@freezed
class DiscoveryResponse with _$DiscoveryResponse {
  const DiscoveryResponse._();
  const factory DiscoveryResponse({
    List<ProductDiscoveryResponse>? productsResponse,
    List<BusinessDiscovery>? businessesResponse,
    List<BundleDiscovery>? bundlesResponse,
  }) = _DiscoveryResponse;

  factory DiscoveryResponse.fromJson(Map<String, dynamic> json) => _$DiscoveryResponseFromJson(json);

  bool isBrowseDataFetchSuccessfull() {
    if (productsResponse?.isNotEmpty == true || businessesResponse?.isNotEmpty == true || bundlesResponse?.isNotEmpty == true) {
      return true;
    }
    return false;
  }
}
