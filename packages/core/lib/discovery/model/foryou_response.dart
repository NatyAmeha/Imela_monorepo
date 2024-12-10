import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/discovery/model/bundle_discovery.model.dart';
import 'package:imela_core/discovery/model/product_discovery.model.dart';
import 'package:imela_core/product/model/product.model.dart';

part 'foryou_response.freezed.dart';
part 'foryou_response.g.dart';

@freezed
class ForYouResponse with _$ForYouResponse {
  const ForYouResponse._();
  const factory ForYouResponse({
    required bool success,

    List<Business>? favoriteBusinesses,
    List<ProductDiscoveryResponse>? topProductsByBusiness, 
    List<BundleDiscovery>? bundles,
  }) = _ForYouResponse;

  factory ForYouResponse.fromJson(Map<String, dynamic> json) => _$ForYouResponseFromJson(json);

  bool isForYouDataFetchSuccessfull() {
    if (success == true && favoriteBusinesses != null && favoriteBusinesses!.isNotEmpty) {
      return true;
    }
    return false;
  }
}
