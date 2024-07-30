import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
part 'product_discovery.model.freezed.dart';
part 'product_discovery.model.g.dart';

@freezed
class ProductDiscoveryResponse with _$ProductDiscoveryResponse {
  const factory ProductDiscoveryResponse({
    required String title,
    String? subtitle,
    int? sequence,
    @Default([]) List<Product> items,
  }) = _ProductDiscoveryResponse;

  factory ProductDiscoveryResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductDiscoveryResponseFromJson(json);
}